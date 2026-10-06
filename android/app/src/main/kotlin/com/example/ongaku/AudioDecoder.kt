package com.example.ongaku

import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.ByteOrder
import java.util.concurrent.Executors

/// Decodes an audio file to mono 16-bit PCM at the requested rate for beat
/// analysis (`ongaku/audio_decoder`). Runs off the main thread.
object AudioDecoder {
    private val executor = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    fun register(messenger: BinaryMessenger) {
        MethodChannel(messenger, "ongaku/audio_decoder").setMethodCallHandler { call, result ->
            if (call.method != "decode") return@setMethodCallHandler result.notImplemented()
            val path = call.argument<String>("path")!!
            val rate = call.argument<Int>("sampleRate")!!
            executor.execute {
                try {
                    val pcm = decode(path, rate)
                    main.post { result.success(pcm) }
                } catch (e: Exception) {
                    main.post { result.error("DECODE_FAILED", e.message, null) }
                }
            }
        }
    }

    private fun decode(path: String, targetRate: Int): ByteArray {
        val extractor = MediaExtractor()
        extractor.setDataSource(path)
        val track = (0 until extractor.trackCount).firstOrNull {
            extractor.getTrackFormat(it).getString(MediaFormat.KEY_MIME)?.startsWith("audio/") == true
        } ?: throw IllegalArgumentException("No audio track")
        extractor.selectTrack(track)
        val format = extractor.getTrackFormat(track)
        val codec = MediaCodec.createDecoderByType(format.getString(MediaFormat.KEY_MIME)!!)
        codec.configure(format, null, null, 0)
        codec.start()

        val out = ByteArrayOutputStream()
        val resampler = Resampler(targetRate, out)
        var channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        var rate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        var float = false
        val info = MediaCodec.BufferInfo()
        var inputDone = false
        try {
            while (true) {
                if (!inputDone) {
                    val index = codec.dequeueInputBuffer(10_000)
                    if (index >= 0) {
                        val size = extractor.readSampleData(codec.getInputBuffer(index)!!, 0)
                        if (size < 0) {
                            codec.queueInputBuffer(index, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            inputDone = true
                        } else {
                            codec.queueInputBuffer(index, 0, size, extractor.sampleTime, 0)
                            extractor.advance()
                        }
                    }
                }
                val index = codec.dequeueOutputBuffer(info, 10_000)
                if (index == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    val f = codec.outputFormat
                    channels = f.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                    rate = f.getInteger(MediaFormat.KEY_SAMPLE_RATE)
                    float = f.containsKey(MediaFormat.KEY_PCM_ENCODING) &&
                        f.getInteger(MediaFormat.KEY_PCM_ENCODING) == AudioFormat.ENCODING_PCM_FLOAT
                } else if (index >= 0) {
                    val buffer = codec.getOutputBuffer(index)!!.order(ByteOrder.LITTLE_ENDIAN)
                    buffer.position(info.offset)
                    buffer.limit(info.offset + info.size)
                    val frames = info.size / (channels * if (float) 4 else 2)
                    for (i in 0 until frames) {
                        var sum = 0f
                        for (c in 0 until channels) {
                            sum += if (float) buffer.float else buffer.short / 32768f
                        }
                        resampler.add(sum / channels, rate)
                    }
                    codec.releaseOutputBuffer(index, false)
                    if (info.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) break
                }
            }
        } finally {
            codec.stop()
            codec.release()
            extractor.release()
        }
        return out.toByteArray()
    }

    /// Linear-interpolation resampler writing 16-bit little-endian samples.
    private class Resampler(private val target: Int, private val out: ByteArrayOutputStream) {
        private var previous = 0f
        private var phase = 0.0 // position of the next output sample, in input samples

        fun add(sample: Float, sourceRate: Int) {
            val step = sourceRate.toDouble() / target
            while (phase <= 1.0) {
                val v = previous + (sample - previous) * phase.toFloat()
                val s = (v.coerceIn(-1f, 1f) * 32767).toInt()
                out.write(s and 0xff)
                out.write((s shr 8) and 0xff)
                phase += step
            }
            phase -= 1.0
            previous = sample
        }
    }
}
