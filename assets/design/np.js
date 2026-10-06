/* Reproductor inmersivo: aura reactiva, transición compartida de portada y letra sincronizada */
(function () {
  const D = window.DATA, P = window.Player, U = window.UI;
  const $ = s => document.querySelector(s), $$ = s => [...document.querySelectorAll(s)];
  const np = $('#np'), cv = $('#aura');
  const fluid = window.Liquid && Liquid.Aura(cv), g = fluid ? null : cv.getContext('2d');
  if (fluid) cv.classList.add('gl');
  let open = false, mode = 'cover', lines = [], active = -1, scrollY = 0, manualUntil = 0, isStatic = false, pal = [[90, 110, 160], [60, 70, 110], [30, 30, 40]];
  const motionOK = () => U.settings.motion === 'full' && !matchMedia('(prefers-reduced-motion: reduce)').matches;
  const reactive = () => U.settings.reactive && motionOK();

  /* ── abrir / cerrar con portada compartida (FLIP) ── */
  function openNP(m) {
    if (!P.current()) return;
    setMode(m || (open ? mode : 'cover'));
    if (open) return;
    open = true; np.classList.add('open'); np.setAttribute('aria-hidden', 'false');
    const from = $('#bar-cover').getBoundingClientRect(), wrap = $('#np-cover-wrap');
    requestAnimationFrame(() => {
      // posición final relativa a la hoja (la hoja aún está entrando)
      const r = wrap.getBoundingClientRect(), n = np.getBoundingClientRect();
      const fx = r.left - n.left, fy = r.top - n.top;
      if (motionOK() && from.width && r.width) {
        wrap.animate([
          { transform: `translate(${from.left - fx}px, ${from.top - fy - innerHeight}px) scale(${from.width / r.width})`, borderRadius: '40px' },
          { transform: 'none', borderRadius: '18px' }
        ], { duration: 600, easing: 'cubic-bezier(.2,.8,.2,1)' });
      }
      $('#np [data-act="close-np"]').focus();
    });
  }
  function closeNP() {
    if (!open) return;
    open = false; np.classList.remove('open'); np.setAttribute('aria-hidden', 'true'); np.style.transform = '';
    $('#bar .now').focus();
  }
  function setMode(m) {
    mode = m; np.dataset.mode = m;
    $$('#np-seg button').forEach(b => b.setAttribute('aria-pressed', b.dataset.mode === m));
    const sg = $('#np-seg'), on = sg.querySelector('[aria-pressed="true"]'), th = sg.querySelector('.thumb');
    if (on && on.offsetWidth) Liquid.stretch(th, { p: on.offsetLeft, s: on.offsetWidth });
    $('#np-lyr-btn').classList.toggle('on', m === 'lyrics'); $('#np-lyr-btn').setAttribute('aria-pressed', m === 'lyrics');
    $('#np-q-btn').classList.toggle('on', m === 'queue'); $('#np-q-btn').setAttribute('aria-pressed', m === 'queue');
    if (m === 'lyrics') { manualUntil = 0; scrollY = target(); }
  }

  /* ── pista ── */
  /* cambio de portada: la imagen se licúa, cambia en el punto máximo y vuelve a asentarse */
  const map = document.getElementById('liquify-map'), noise = document.getElementById('liquify-noise');
  let swapping = 0;
  function liquidSwap(src) {
    const wrap = $('#np-cover-wrap'), img = $('#np-cover'), id = ++swapping, t0 = performance.now(), D1 = 280, D2 = 520;
    noise.setAttribute('seed', 1 + Math.floor(Math.random() * 90));
    wrap.style.filter = 'url(#liquify)';
    let swapped = false;
    (function step(now) {
      if (id !== swapping) return;
      const e = now - t0;
      let k;
      if (e < D1) k = Math.sin((e / D1) * Math.PI / 2);
      else { if (!swapped) { img.src = src; swapped = true; } k = 1 - Math.min(1, (e - D1) / D2); k = k * k * (3 - 2 * k); }
      map.setAttribute('scale', (k * 90).toFixed(1));
      img.style.opacity = 1 - k * 0.35;
      if (e < D1 + D2) requestAnimationFrame(step); else { wrap.style.filter = ''; img.style.opacity = ''; map.setAttribute('scale', 0); }
    })(t0);
    const r = wrap.getBoundingClientRect(); if (fluid) fluid.ripple(r.left + r.width / 2, r.top + r.height / 2);
  }
  function loadTrack(t) {
    if (open && motionOK() && $('#np-cover').getAttribute('src') && !$('#np-cover').src.endsWith(t.cover)) liquidSwap(t.cover); else $('#np-cover').src = t.cover;
    $('#np-cover').alt = 'Portada de ' + t.album;
    $('#np-title').textContent = t.title;
    $('#np-artist').textContent = t.artist; $('#np-artist').href = '#/artista/' + t.artistId;
    $('#np-dur').textContent = U.fmt(t.dur);
    pal = t.palette;
    ['--c1', '--c2', '--c3'].forEach((k, i) => np.style.setProperty(k, pal[i].join(' ')));
    buildLyrics(t);
  }
  function buildLyrics(t) {
    const info = D.songInfo(t);
    lines = [];
    let prevEnd = 0;
    info.lines.forEach(l => { if (l.t - prevEnd > info.bar * 2) lines.push({ t: prevEnd, end: l.t, gap: true }); lines.push(l); prevEnd = l.end; });
    lines.push({ t: prevEnd, end: t.dur, gap: true });
    const box = $('#lyr');
    box.classList.toggle('static', isStatic);
    box.innerHTML = lines.map((l, i) => l.gap
      ? `<button class="ln gap" data-i="${i}" aria-label="Instrumental">${isStatic ? '' : '<span>•</span> <span>•</span> <span>•</span>'}</button>`
      : `<button class="ln" data-i="${i}">${l.text.split(' ').map(w => `<span class="w">${U.esc(w)}</span>`).join(' ')}</button>`).join('');
    lines.forEach((l, i) => { l.el = box.children[i]; if (!l.gap) { const ws = l.text.split(' '), tot = ws.reduce((s, w) => s + w.length + 1, 0); let acc = 0; l.words = ws.map((w, k) => { const a = acc / tot; acc += w.length + 1; return { el: l.el.children[k], a, b: acc / tot }; }); } });
    active = -1; scrollY = 0; manualUntil = 0;
    $('#lyr-kind').textContent = isStatic ? 'Estática' : 'Sincronizada';
  }
  const target = () => { const l = lines[Math.max(0, active)]; if (!l || !l.el) return 0; return Math.max(0, l.el.offsetTop - $('#lyr-wrap').clientHeight * 0.34); };

  $('#lyr').addEventListener('click', e => { const b = e.target.closest('.ln'); if (b && !isStatic) { P.seek(lines[+b.dataset.i].t); manualUntil = 0; } });
  $('#lyr-wrap').addEventListener('wheel', e => { e.preventDefault(); scrollY = Math.max(0, scrollY + e.deltaY); manualUntil = performance.now() + 3000; }, { passive: false });
  let ty = null;
  $('#lyr-wrap').addEventListener('touchstart', e => { ty = e.touches[0].clientY; }, { passive: true });
  $('#lyr-wrap').addEventListener('touchmove', e => { if (ty == null) return; const y = e.touches[0].clientY; scrollY = Math.max(0, scrollY + (ty - y)); ty = y; manualUntil = performance.now() + 3000; }, { passive: true });
  $('#lyr-kind').style.cursor = 'pointer';
  $('#lyr-kind').title = 'Alternar letra sincronizada o estática';
  $('#lyr-kind').addEventListener('click', () => { isStatic = !isStatic; buildLyrics(P.current()); });

  /* ── aura: manchas de color de la portada que respiran con graves y golpes ── */
  const W = 160, H = 100; cv.width = W; cv.height = H;
  const blobs = [0, 1, 2, 3, 4].map(i => ({ ph: i * 1.7, sp: .00011 + i * .000035, r: .42 + (i % 3) * .1, c: i % 3 }));
  let energy = 0, beatS = 0, auraT = 0, last = performance.now();
  function drawAura(L, dt) {
    const k = reactive() ? 1 : 0;
    energy += ((L.bass * .9 + L.mid * .4) * k - energy) * .12;
    beatS += (L.beat * k - beatS) * .35;
    auraT += dt * (P.state === 'playing' ? 1 + energy * 2.2 : .35);
    if (fluid) { fluid.draw(auraT / 1000, energy, beatS, pal); return; }
    if (!g) return;
    g.globalCompositeOperation = 'source-over';
    g.fillStyle = `rgb(${pal[2].map(v => Math.round(v * .35)).join(',')})`; g.fillRect(0, 0, W, H);
    g.globalCompositeOperation = 'screen';
    blobs.forEach((b, i) => {
      const t = auraT * b.sp * 1000;
      const x = W * (.5 + .36 * Math.sin(t * .9 + b.ph) * Math.cos(t * .37 + i));
      const y = H * (.5 + .34 * Math.cos(t * .7 + b.ph * 1.3));
      const r = W * b.r * (1 + energy * .5 + beatS * .18);
      const c = pal[b.c];
      const gr = g.createRadialGradient(x, y, 0, x, y, r);
      gr.addColorStop(0, `rgba(${c.join(',')},${.75 + beatS * .2})`); gr.addColorStop(1, `rgba(${c.join(',')},0)`);
      g.fillStyle = gr; g.beginPath(); g.arc(x, y, r, 0, 7); g.fill();
    });
  }

  /* ── bucle por cuadro ── */
  function frame(now) {
    const dt = Math.min(64, now - last); last = now;
    if (open) {
      const t = P.current(), L = P.levels();
      if (motionOK() || auraT === 0) drawAura(L, dt);
      np.style.setProperty('--pulse', reactive() ? (1 + beatS * .03 + energy * .02).toFixed(4) : 1);
      const seek = $('#np-seek'), pos = seek._drag ?? P.position(), pct = t ? Math.min(100, pos / t.dur * 100) : 0;
      seek.querySelector('.fill').style.width = pct + '%'; seek.querySelector('.knob').style.left = pct + '%';
      npWave(pct, P.state === 'playing' && seek._drag == null ? 2.2 + energy * 4 : 0, dt);
      seek.setAttribute('aria-valuetext', U.fmt(pos) + ' de ' + U.fmt(t ? t.dur : 0));
      $('#np-pos').textContent = U.fmt(pos);
      if (mode === 'lyrics' && lines.length && !isStatic) syncLyrics(pos, now);
    }
    requestAnimationFrame(frame);
  }
  function syncLyrics(pos, now) {
    let i = lines.findIndex((l, k) => pos >= l.t && (k === lines.length - 1 || pos < lines[k + 1].t));
    if (i < 0) i = 0;
    if (i !== active) {
      active = i;
      lines.forEach((l, k) => { l.el.classList.toggle('on', k === i); l.el.classList.toggle('past', k < i); l.el.classList.toggle('far', Math.abs(k - i) > 2); if (k !== i && l.words) l.words.forEach(w => { w.el.style.removeProperty('--w'); w.el.classList.remove('sing', 'sung'); }); });
    }
    const l = lines[active];
    if (l.words) { const p = Math.max(0, Math.min(1, (pos - l.t) / (l.end - l.t))); l.words.forEach(w => { const v = Math.max(0, Math.min(1, (p - w.a) / (w.b - w.a))); w.el.style.setProperty('--w', (v * 100).toFixed(1) + '%'); w.el.classList.toggle('sing', v > 0 && v < 1); w.el.classList.toggle('sung', v >= 1); }); l.el.style.setProperty('--glow', beatS.toFixed(3)); }
    if (l.gap) [...l.el.children].forEach((s, k) => s.style.transform = `scale(${1 + beatS * (k === 1 ? .9 : .5)})`);
    if (now > manualUntil) scrollY += (target() - scrollY) * (motionOK() ? .09 : 1);
    $('#lyr').style.transform = `translateY(${-scrollY}px)`;
  }

  /* ── controles ── */
  function renderCtrls() {
    Liquid.playBtn($('#np-play'), P.state); np.dataset.ps = P.state; $('#np-play').setAttribute('aria-label', P.state === 'playing' ? 'Pausar' : 'Reproducir');
    $('#np-shuffle').classList.toggle('on', P.shuffle); $('#np-shuffle').setAttribute('aria-pressed', P.shuffle);
    $('#np-repeat').classList.toggle('on', P.repeat !== 'off'); $('#np-repeat').innerHTML = U.ic(P.repeat === 'one' ? 'repeat1' : 'repeat');
    $('#np-repeat').setAttribute('aria-label', { off: 'Repetir: apagado', all: 'Repetir: todas', one: 'Repetir: una' }[P.repeat]);
    $('#np-timer').classList.toggle('on', !!P.sleep);
    $('#np-timer').setAttribute('aria-label', P.sleep ? (P.sleep === 'end' ? 'Temporizador: al terminar la canción' : `Temporizador: ${P.sleep} min`) : 'Temporizador de apagado');
    const on = P.current() && U.isFav(P.current().id); $('#np-fav').innerHTML = U.ic('heart', on ? 'fill' : ''); $('#np-fav').classList.toggle('on', on);
  }
  U.seekBar($('#np-seek'), () => P.duration());
  const npWave = Liquid.wave($('#np-seek'));

  async function timerMenu(btn) {
    const k = await U.menu(btn, [['15', 'timer', '15 minutos'], ['30', 'timer', '30 minutos'], ['45', 'timer', '45 minutos'], ['60', 'timer', '1 hora'], ['end', 'check', 'Al terminar la canción'], '-', ['off', 'x', 'Desactivar']]);
    if (!k) return;
    P.setSleep(k === 'off' ? null : k === 'end' ? 'end' : +k);
    U.toast(k === 'off' ? 'Temporizador desactivado' : k === 'end' ? 'Se pausará al terminar esta canción' : `Se pausará en ${k} minutos`);
  }
  document.addEventListener('click', async e => {
    const a = e.target.closest('[data-act]'); if (!a) return;
    const act = a.dataset.act;
    if (act === 'open-np') openNP('cover');
    if (act === 'open-lyrics') openNP('lyrics');
    if (act === 'close-np') closeNP();
    if (act === 'np-mode') setMode(mode === a.dataset.mode ? 'cover' : a.dataset.mode);
    if (act === 'timer') timerMenu(a);
    if (act === 'np-menu') {
      const t = P.current();
      const k = await U.menu(a, [['radio', 'radio', 'Iniciar radio'], ['pl', 'lib', 'Agregar a playlist…'], ['album', 'album', 'Ir al álbum'], ['artist', 'user', 'Ir al artista'], '-', ['timer', 'timer', 'Temporizador de apagado']]);
      if (k === 'radio') U.startRadio(t);
      if (k === 'pl') U.addToPlaylist(t.id);
      if (k === 'album') { closeNP(); location.hash = '#/album/' + t.albumId; }
      if (k === 'artist') { closeNP(); location.hash = '#/artista/' + t.artistId; }
      if (k === 'timer') timerMenu(a);
    }
  });
  $('#np-seg').addEventListener('click', e => { const b = e.target.closest('button'); if (b) setMode(b.dataset.mode); });
  $('#np-artist').addEventListener('click', closeNP);
  document.addEventListener('keydown', e => { if (e.key === 'Escape' && open && !document.querySelector('.menu,.dialog-wrap')) closeNP(); });

  // deslizar hacia abajo para cerrar (móvil)
  let sy = null;
  $('.np-head').addEventListener('pointerdown', e => { if (e.target.closest('button')) return; sy = e.clientY; np.style.transition = 'none'; });
  window.addEventListener('pointermove', e => { if (sy == null) return; np.style.transform = `translateY(${Math.max(0, e.clientY - sy)}px)`; });
  window.addEventListener('pointerup', e => { if (sy == null) return; np.style.transition = ''; const d = e.clientY - sy; sy = null; if (d > 110) closeNP(); else np.style.transform = ''; });

  const notes = { buffering: 'Almacenando en búfer…', completed: 'Terminó la cola', idle: 'Toca reproducir para continuar donde ibas' };
  let prevState = P.state;
  P.on('state', ({ state, message }) => {
    if (open && fluid && state === 'playing' && prevState === 'paused') { const r = $('#np-play').getBoundingClientRect(); fluid.ripple(r.left + r.width / 2, r.top + r.height / 2); }
    prevState = state;
    renderCtrls(); $('#np-note').textContent = state === 'error' ? message : notes[state] || ''; });
  P.on('track', t => { loadTrack(t); renderCtrls(); });
  P.on('modes', renderCtrls);
  document.addEventListener('click', e => { if (e.target.closest('[data-act="fav"],[data-act="fav-current"]')) setTimeout(renderCtrls, 0); });

  let fromLabel = 'Para TransMilenio';
  window.NP = { isOpen: () => open, close: closeNP, set from(v) { fromLabel = v; $('#np-from').textContent = v; } };
  $('#np-from').textContent = fromLabel;
  if (P.current()) { loadTrack(P.current()); renderCtrls(); $('#np-note').textContent = notes.idle; }
  requestAnimationFrame(frame);
})();
