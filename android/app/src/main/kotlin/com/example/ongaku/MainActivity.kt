package com.example.ongaku

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

// AudioServiceActivity keeps the Flutter engine alive for the background
// playback service (notification, lock screen, Bluetooth controls).
class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AudioDecoder.register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
