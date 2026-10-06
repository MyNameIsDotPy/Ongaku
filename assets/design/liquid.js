/* Onda — capa líquida.
   1. stretch(): indicadores que se estiran como una gota entre la posición vieja y la nueva.
   2. playBtn(): el ícono de play se derrite en pausa (morph de trazos).
   3. wave(): barra de progreso ondulada; la onda crece con el audio y se aplana en pausa.
   4. Aura(): fluido WebGL (fbm con deformación de dominio) teñido por la portada, con ondas de choque. */
(function () {
  const reduced = () => document.documentElement.dataset.motion === 'reduced' || matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ── 1 · indicador elástico ── */
  function stretch(el, to, axis = 'x') {
    if (!el) return;
    const [pos, size] = axis === 'x' ? ['left', 'width'] : ['top', 'height'];
    const from = { p: parseFloat(el.style[pos]), s: parseFloat(el.style[size]) };
    const apply = () => { el.style[pos] = to.p + 'px'; el.style[size] = to.s + 'px'; el.style.opacity = to.hide ? 0 : 1; };
    if (reduced() || isNaN(from.p) || isNaN(from.s) || to.hide || el.style.opacity === '0' || (from.p === to.p && from.s === to.s)) { el.getAnimations().forEach(a => a.cancel()); apply(); return; }
    const lo = Math.min(from.p, to.p), hi = Math.max(from.p + from.s, to.p + to.s);
    const fwd = to.p > from.p;
    const cross = axis === 'x' ? 'scaleY' : 'scaleX';
    el.getAnimations().forEach(a => a.cancel());
    apply();
    el.animate([
      { [pos]: from.p + 'px', [size]: from.s + 'px', transform: `${cross}(1)` },
      { [pos]: (fwd ? from.p : lo) + 'px', [size]: (hi - lo) * 0.82 + 'px', transform: `${cross}(.72)`, offset: 0.42 },
      { [pos]: to.p + 'px', [size]: to.s + 'px', transform: `${cross}(1.08)`, offset: 0.78 },
      { [pos]: to.p + 'px', [size]: to.s + 'px', transform: `${cross}(1)` }
    ], { duration: 560, easing: 'cubic-bezier(.3,.7,.2,1)' });
  }

  /* ── 2 · play ↔ pausa que se derrite ── */
  const SHAPES = { play: ['M7 4.8L13 8.4L13 15.6L7 19.2Z', 'M13 8.4L20 12L20 12L13 15.6Z'], pause: ['M6 4.5L10.5 4.5L10.5 19.5L6 19.5Z', 'M13.5 4.5L18 4.5L18 19.5L13.5 19.5Z'] };
  function playBtn(btn, state) {
    if (!btn.querySelector('.morph')) btn.innerHTML = '<svg class="morph" viewBox="0 0 24 24" aria-hidden="true"><path class="a"/><path class="b"/></svg><span class="spin" aria-hidden="true"></span>';
    // atributo d como respaldo para navegadores sin la propiedad CSS d (Safari)
    const sh = SHAPES[state === 'playing' ? 'pause' : 'play'];
    btn.querySelector('.a').setAttribute('d', sh[0]); btn.querySelector('.b').setAttribute('d', sh[1]);
    btn.dataset.ps = state;
  }

  /* relleno líquido: el círculo nace donde entra el cursor */
  document.addEventListener('pointerover', e => {
    const el = e.target.closest('.btn-secondary, .chip');
    if (!el || el.contains(e.relatedTarget)) return;
    const r = el.getBoundingClientRect();
    el.style.setProperty('--mx', (e.clientX - r.left) + 'px'); el.style.setProperty('--my', (e.clientY - r.top) + 'px');
    el.style.setProperty('--d', Math.max(r.width, r.height) * 2.4 + 'px');
  });

  /* ── 3 · progreso ondulado ── */
  function wave(track) {
    const NS = 'http://www.w3.org/2000/svg';
    const svg = document.createElementNS(NS, 'svg'); svg.setAttribute('class', 'wave'); svg.setAttribute('aria-hidden', 'true');
    const path = document.createElementNS(NS, 'path'); svg.append(path); track.prepend(svg);
    track.classList.add('has-wave');
    let amp = 0, phase = 0;
    return function update(pct, target, dt) {
      const w = track.clientWidth, h = track.clientHeight || 16, y0 = h / 2;
      amp += ((reduced() ? 0 : target) - amp) * 0.08;
      phase += dt * 0.006 * (0.6 + amp / 3);
      const x1 = Math.max(0, w * pct / 100 - 2);
      let d = `M0 ${y0}`;
      const k = (Math.PI * 2) / 22;
      for (let x = 2; x <= x1; x += 2) {
        const fade = Math.min(1, x / 12, (x1 - x) / 10 + 0.15);
        d += ` L${x} ${(y0 + Math.sin(x * k - phase) * amp * Math.max(0, fade)).toFixed(2)}`;
      }
      path.setAttribute('d', d);
      track.style.setProperty('--pct', pct + '%');
    };
  }

  /* ── 4 · aura de fluido ── */
  const FRAG = `#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
uniform vec2 r; uniform float t, bass, beat, ripT; uniform vec2 ripC; uniform vec3 c1, c2, c3;
float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(h(i),h(i+vec2(1,0)),f.x),mix(h(i+vec2(0,1)),h(i+1.),f.x),f.y);}
float fbm(vec2 p){float v=0.,a=.5;mat2 m=mat2(1.6,1.2,-1.2,1.6);for(int i=0;i<5;i++){v+=a*n(p);p=m*p;a*=.5;}return v;}
void main(){
  vec2 p=(gl_FragCoord.xy-.5*r)/r.y;
  vec2 d=p-ripC; float dist=length(d);
  float rip=ripT>0.?sin(dist*26.-ripT*12.)*exp(-ripT*1.8)*exp(-dist*1.6)*.07:0.;
  p+=d/(dist+1e-3)*rip;
  float tt=t*.05;
  vec2 q=vec2(fbm(p*1.5+tt),fbm(p*1.5+vec2(5.2,1.3)-tt));
  vec2 s=vec2(fbm(p*1.5+3.6*q+vec2(1.7,9.2)+tt*1.3+bass*.8),fbm(p*1.5+3.6*q+vec2(8.3,2.8)-tt*1.1));
  float f=fbm(p*1.5+3.9*s+beat*.25);
  vec3 col=mix(c3*.3,c2*.9,smoothstep(.15,.7,f));
  col=mix(col,c1,smoothstep(.35,.95,length(q)*f*1.5+beat*.12));
  col+=c1*pow(f,4.)*(.5+beat*.9);
  float rim=smoothstep(.6,.64,f)-smoothstep(.64,.74,f);
  col+=vec3(rim*.10*(1.+beat));
  gl_FragColor=vec4(col,1.);
}`;
  function Aura(canvas) {
    const gl = canvas.getContext('webgl', { antialias: false, premultipliedAlpha: false });
    if (!gl) return null;
    const sh = (type, src) => { const s = gl.createShader(type); gl.shaderSource(s, src); gl.compileShader(s); return s; };
    const pr = gl.createProgram();
    gl.attachShader(pr, sh(gl.VERTEX_SHADER, 'attribute vec2 a;void main(){gl_Position=vec4(a,0.,1.);}'));
    gl.attachShader(pr, sh(gl.FRAGMENT_SHADER, FRAG));
    gl.linkProgram(pr);
    if (!gl.getProgramParameter(pr, gl.LINK_STATUS)) return null;
    gl.useProgram(pr);
    const buf = gl.createBuffer(); gl.bindBuffer(gl.ARRAY_BUFFER, buf);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
    const loc = gl.getAttribLocation(pr, 'a'); gl.enableVertexAttribArray(loc); gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
    const U = {}; ['r', 't', 'bass', 'beat', 'ripT', 'ripC', 'c1', 'c2', 'c3'].forEach(k => U[k] = gl.getUniformLocation(pr, k));
    let rip = { t: -1, x: 0, y: 0 };
    function size() {
      const s = 0.32, w = Math.max(64, Math.round(canvas.clientWidth * s)), h = Math.max(48, Math.round(canvas.clientHeight * s));
      if (canvas.width !== w || canvas.height !== h) { canvas.width = w; canvas.height = h; gl.viewport(0, 0, w, h); }
    }
    return {
      draw(time, bass, beat, pal) {
        size();
        gl.uniform2f(U.r, canvas.width, canvas.height);
        gl.uniform1f(U.t, time); gl.uniform1f(U.bass, bass); gl.uniform1f(U.beat, beat);
        if (rip.t >= 0) { rip.t += 1 / 60; if (rip.t > 3) rip.t = -1; }
        gl.uniform1f(U.ripT, rip.t); gl.uniform2f(U.ripC, rip.x, rip.y);
        pal.forEach((c, i) => gl.uniform3f(U['c' + (i + 1)], c[0] / 255, c[1] / 255, c[2] / 255));
        gl.drawArrays(gl.TRIANGLES, 0, 3);
      },
      // onda de choque desde un punto de la pantalla (p. ej. el centro de la portada)
      ripple(clientX, clientY) {
        const b = canvas.getBoundingClientRect();
        const px = (clientX - b.left) / b.width * canvas.width, py = (1 - (clientY - b.top) / b.height) * canvas.height;
        rip = { t: 0, x: (px - canvas.width / 2) / canvas.height, y: (py - canvas.height / 2) / canvas.height };
      }
    };
  }

  window.Liquid = { stretch, playBtn, wave, Aura, reduced };
})();
