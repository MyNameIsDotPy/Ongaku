/* Motor del prototipo.
   - Sintetiza en el navegador una pista de demostración por canción (tempo, tonalidad y patrón
     derivados del id), para que el visualizador y la letra respondan a audio real.
   - En la app Flutter este lugar lo ocupa PlayerController (just_audio + audio_service)
     con el stream del backend; aquí solo se imita su contrato de estados. */
(function () {
  const D = window.DATA;
  const listeners = {};
  const emit = (ev, p) => (listeners[ev] || []).forEach(f => f(p));

  /* ─────────────── audio ─────────────── */
  let ctx, master, analyser, reverb, noiseBuf, freq, wave;
  let t0 = 0, timer = null, step = 0, nextT = 0, info = null;
  const kicks = [];

  function ensureCtx() {
    if (ctx) return;
    ctx = new (window.AudioContext || window.webkitAudioContext)();
    master = ctx.createGain(); master.gain.value = 0.7;
    const comp = ctx.createDynamicsCompressor(); comp.threshold.value = -14; comp.ratio.value = 4;
    analyser = ctx.createAnalyser(); analyser.fftSize = 1024; analyser.smoothingTimeConstant = 0.8;
    master.connect(comp); comp.connect(analyser);
    // Pasar por un <audio> habilita MediaSession (controles de bloqueo / notificación) en Chrome Android
    try {
      const dest = ctx.createMediaStreamDestination();
      analyser.connect(dest);
      const el = new Audio(); el.srcObject = dest.stream;
      el.play().catch(() => analyser.connect(ctx.destination));
    } catch (e) { analyser.connect(ctx.destination); }
    freq = new Uint8Array(analyser.frequencyBinCount);
    wave = new Uint8Array(analyser.fftSize);
    noiseBuf = ctx.createBuffer(1, ctx.sampleRate, ctx.sampleRate);
    const d = noiseBuf.getChannelData(0); for (let i = 0; i < d.length; i++) d[i] = Math.random() * 2 - 1;
    reverb = ctx.createConvolver();
    const ir = ctx.createBuffer(2, ctx.sampleRate * 2.4, ctx.sampleRate);
    for (let c = 0; c < 2; c++) { const x = ir.getChannelData(c); for (let i = 0; i < x.length; i++) x[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / x.length, 3); }
    reverb.buffer = ir;
    const rg = ctx.createGain(); rg.gain.value = 0.32; reverb.connect(rg); rg.connect(master);
  }
  const mtof = m => 440 * Math.pow(2, (m - 69) / 12);
  function env(g, t, a, peak, dec) { g.gain.setValueAtTime(0.0001, t); g.gain.exponentialRampToValueAtTime(peak, t + a); g.gain.exponentialRampToValueAtTime(0.0001, t + a + dec); }

  function kick(t, v = 1) {
    const o = ctx.createOscillator(), g = ctx.createGain();
    o.frequency.setValueAtTime(150, t); o.frequency.exponentialRampToValueAtTime(42, t + 0.13);
    env(g, t, 0.004, 0.9 * v, 0.36); o.connect(g); g.connect(master); o.start(t); o.stop(t + 0.45);
    kicks.push(t); if (kicks.length > 16) kicks.shift();
  }
  function noise(t, type, f, peak, dec, send) {
    const s = ctx.createBufferSource(); s.buffer = noiseBuf;
    const fl = ctx.createBiquadFilter(); fl.type = type; fl.frequency.value = f;
    const g = ctx.createGain(); env(g, t, 0.002, peak, dec);
    s.connect(fl); fl.connect(g); g.connect(master); if (send) g.connect(reverb);
    s.start(t, Math.random() * 0.5); s.stop(t + dec + 0.05);
  }
  function tone(t, m, type, len, peak, cutoff, send, a = 0.005) {
    const o = ctx.createOscillator(), fl = ctx.createBiquadFilter(), g = ctx.createGain();
    o.type = type; o.frequency.value = mtof(m); fl.type = 'lowpass'; fl.frequency.value = cutoff; fl.Q.value = 2;
    env(g, t, a, peak, len); o.connect(fl); fl.connect(g); g.connect(master); if (send) g.connect(reverb);
    o.start(t); o.stop(t + a + len + 0.05);
  }

  function sectionAt(bar) { return (info.sections.find(s => bar >= s.from && bar < s.to) || { name: 'outro' }).name; }
  function scheduleStep(i, t) {
    const sd = info.bar / 16, bar = Math.floor(i / 16), s = i % 16, sec = sectionAt(bar);
    const prog = info.minor ? [0, 8, 3, 10] : [0, 7, 9, 5];
    const root = info.root + prog[bar % 4];
    const third = info.minor ? ([0, 3].includes(prog[bar % 4]) ? 3 : 4) : ([0, 5, 7].includes(prog[bar % 4]) ? 4 : 3);
    const chord = [root + 12, root + 12 + third, root + 19];
    const full = sec === 'ch', drums = ['v1', 'v2', 'ch', 'br'].includes(sec);
    const dembow = info.seed % 2 === 1;
    const fade = sec === 'outro' ? Math.max(0.15, 1 - (bar - info.sections[info.sections.length - 1].from) / 8) : 1;
    if (drums) {
      if (dembow ? [0, 8].includes(s) || (s === 4 && full) || s === 12 : s % 4 === 0) kick(t, sec === 'br' ? 0.6 : 1);
      if (dembow ? [3, 6, 11, 14].includes(s) : (s === 4 || s === 12)) noise(t, 'bandpass', 1700, full ? 0.45 : 0.3, 0.16, true);
    }
    if (sec !== 'br' && s % 2 === 0) noise(t, 'highpass', 7500, (s % 4 === 2 ? 0.12 : 0.06) * fade, 0.035);
    if (drums && sec !== 'br' && [0, 3, 6, 10, 12].includes(s)) tone(t, root - 12, 'sawtooth', sd * 2.2, 0.32, 420);
    if (s === 0) chord.forEach(m => { tone(t, m, 'triangle', info.bar * 0.95, 0.05 * fade, 1800, true, 0.35); tone(t, m + 0.08, 'triangle', info.bar * 0.95, 0.04 * fade, 1500, true, 0.4); });
    if (full || sec === 'inter' || sec === 'intro') {
      const pat = [0, 1, 2, 1, 2, 0, 1, 2];
      if (full || s % 4 === 0) tone(t, chord[pat[s % 8]] + 12, 'square', 0.18, (full ? 0.05 : 0.035) * fade, 2600, true);
    }
  }
  function scheduler() {
    const sd = info.bar / 16;
    while (nextT < ctx.currentTime + 0.12) { scheduleStep(step, nextT); step++; nextT += sd; }
  }
  function startClock(pos) {
    ensureCtx(); info = D.songInfo(P.current());
    t0 = ctx.currentTime - pos;
    const sd = info.bar / 16;
    step = Math.ceil(pos / sd); nextT = t0 + step * sd;
    clearInterval(timer); timer = setInterval(() => { if (P.state === 'playing') { scheduler(); tick(); } }, 25);
  }

  /* ─────────────── estado del reproductor ─────────────── */
  const saved = JSON.parse(localStorage.getItem('onda.player') || 'null');
  const P = {
    state: 'idle', queue: [], index: 0, upNext: 0, shuffle: false, repeat: 'off', pausedAt: 0, original: null, sleep: null,
    on(ev, f) { (listeners[ev] = listeners[ev] || []).push(f); },
    current() { return D.TRACKS[this.queue[this.index]] || null; },
    position() {
      if (!this.current()) return 0;
      if (this.state === 'playing' && ctx) return Math.max(0, ctx.currentTime - t0);
      return this.pausedAt;
    },
    duration() { return this.current() ? this.current().dur : 0; },
    setState(s, extra) { this.state = s; emit('state', { state: s, ...extra }); updateSession(); },

    play(ids, start = 0) {
      this.queue = ids.slice(); this.index = start; this.upNext = 0; this.original = null;
      if (this.shuffle) shuffleRest();
      this.load(0);
      emit('queue');
    },
    playTrack(id) {
      const i = this.queue.indexOf(id);
      if (i >= 0) { this.index = i; this.load(0); emit('queue'); } else this.play([id]);
    },
    load(pos) {
      const tr = this.current(); if (!tr) return;
      ensureCtx(); ctx.resume();
      emit('track', tr);
      this.pausedAt = pos;
      this.setState('loading');
      clearTimeout(this._lt);
      this._lt = setTimeout(() => {
        if (tr.unavailable) {
          this.setState('error', { code: 'UNAVAILABLE', message: `“${tr.title}” no está disponible. Saltando a la siguiente.` });
          this._lt = setTimeout(() => this.next(true), 1600);
          return;
        }
        startClock(pos); this.setState('playing');
      }, 420);
    },
    toggle() {
      if (!this.current()) return;
      if (this.state === 'playing') { this.pausedAt = this.position(); this.setState('paused'); ctx.suspend(); }
      else if (this.state === 'paused' || this.state === 'idle') {
        ensureCtx();
        if (!info || this.state === 'idle') { this.load(this.pausedAt); return; }
        ctx.resume().then(() => { t0 = ctx.currentTime - this.pausedAt; const sd = info.bar / 16; step = Math.ceil(this.pausedAt / sd); nextT = t0 + step * sd; this.setState('playing'); });
      } else if (this.state === 'completed') { this.index = 0; this.load(0); }
    },
    seek(sec) {
      sec = Math.max(0, Math.min(this.duration() - 0.5, sec));
      if (this.state !== 'playing') { this.pausedAt = sec; emit('tick', sec); return; }
      this.setState('buffering'); this.pausedAt = sec;
      setTimeout(() => { startClock(sec); this.setState('playing'); }, 240);
    },
    next(auto) {
      if (this.repeat === 'one' && auto === 'end') return this.load(0);
      if (this.upNext > 0) this.upNext--;
      if (this.index < this.queue.length - 1) { this.index++; this.load(0); }
      else if (this.repeat === 'all') { this.index = 0; this.load(0); }
      else { this.pausedAt = 0; this.setState('completed'); }
      emit('queue');
    },
    prev() {
      if (this.position() > 3 || this.index === 0) { if (this.state === 'playing') this.seek(0); else this.load(0); return; }
      this.index--; this.load(0); emit('queue');
    },
    toggleShuffle() {
      this.shuffle = !this.shuffle;
      if (this.shuffle) shuffleRest();
      else if (this.original) { const cur = this.queue[this.index]; this.queue = this.original; this.index = this.queue.indexOf(cur); this.original = null; }
      emit('queue'); emit('modes');
    },
    cycleRepeat() { this.repeat = { off: 'all', all: 'one', one: 'off' }[this.repeat]; emit('modes'); },
    playNext(id) {
      if (!this.queue.length) return this.play([id]);
      this.queue.splice(this.index + 1 + this.upNext, 0, id); this.upNext++; emit('queue');
    },
    addToQueue(id) { if (!this.queue.length) return this.play([id]); this.queue.push(id); emit('queue'); },
    remove(i) {
      if (i === this.index) return;
      this.queue.splice(i, 1); if (i < this.index) this.index--; else if (i <= this.index + this.upNext) this.upNext = Math.max(0, this.upNext - 1);
      emit('queue');
    },
    move(from, to) {
      const [x] = this.queue.splice(from, 1); this.queue.splice(to, 0, x);
      if (from === this.index) this.index = to;
      else if (from < this.index && to >= this.index) this.index--;
      else if (from > this.index && to <= this.index) this.index++;
      emit('queue');
    },
    clear() { this.queue = this.queue.slice(0, this.index + 1); this.upNext = 0; emit('queue'); },
    setSleep(v) {
      clearTimeout(this._sleep); this.sleep = v;
      if (typeof v === 'number') this._sleep = setTimeout(() => { if (this.state === 'playing') this.toggle(); this.sleep = null; emit('modes'); }, v * 60000);
      emit('modes');
    },

    /* niveles para las animaciones (0–1) */
    levels() {
      if (!ctx || this.state !== 'playing') return { bass: 0, mid: 0, high: 0, beat: 0, bands: null };
      analyser.getByteFrequencyData(freq);
      const avg = (a, b) => { let s = 0; for (let i = a; i < b; i++) s += freq[i]; return s / (b - a) / 255; };
      let beat = 0;
      for (let i = kicks.length - 1; i >= 0; i--) { const dt = ctx.currentTime - kicks[i]; if (dt >= 0) { beat = Math.exp(-dt * 7); break; } }
      return { bass: avg(1, 6), mid: avg(8, 60), high: avg(60, 200), beat, bands: freq };
    },
    info() { return info; },
  };

  function shuffleRest() {
    P.original = P.queue.slice();
    const head = P.queue.slice(0, P.index + 1), rest = P.queue.slice(P.index + 1);
    for (let i = rest.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [rest[i], rest[j]] = [rest[j], rest[i]]; }
    P.queue = head.concat(rest);
  }
  function tick() {
    const pos = P.position();
    if (P.sleep === 'end' && pos >= P.duration() - 0.3) { P.pausedAt = 0; P.setState('paused'); ctx.suspend(); P.sleep = null; emit('modes'); return; }
    if (pos >= P.duration()) { P.next('end'); return; }
  }
  function updateSession() {
    const ms = navigator.mediaSession, tr = P.current(); if (!ms || !tr) return;
    try {
      ms.metadata = new MediaMetadata({ title: tr.title, artist: tr.artist, album: tr.album, artwork: [{ src: tr.cover, sizes: '600x600', type: 'image/jpeg' }] });
      ms.playbackState = P.state === 'playing' ? 'playing' : 'paused';
    } catch (e) {}
  }
  if (navigator.mediaSession) {
    const ms = navigator.mediaSession;
    [['play', () => P.toggle()], ['pause', () => P.toggle()], ['nexttrack', () => P.next()], ['previoustrack', () => P.prev()], ['seekto', d => P.seek(d.seekTime)]]
      .forEach(([a, f]) => { try { ms.setActionHandler(a, f); } catch (e) {} });
  }

  /* RF-16 · restaurar cola, canción y posición */
  if (saved && saved.queue && saved.queue.every(id => D.TRACKS[id])) {
    Object.assign(P, { queue: saved.queue, index: saved.index, pausedAt: saved.pos || 0, shuffle: !!saved.shuffle, repeat: saved.repeat || 'off', state: 'idle' });
  } else {
    Object.assign(P, { queue: D.PLAYLISTS[0].tracks.slice(), index: 0, pausedAt: 0, state: 'idle' });
  }
  setInterval(() => localStorage.setItem('onda.player', JSON.stringify({ queue: P.queue, index: P.index, pos: P.position(), shuffle: P.shuffle, repeat: P.repeat })), 2000);

  window.Player = P;
})();
