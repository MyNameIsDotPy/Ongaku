#version 460 core

#include <flutter/runtime_effect.glsl>

// The player's aura in one pass: a slow fluid of domain-warped noise tinted
// by the cover, with a rim of light and a shockwave after a track change.
// Ported from the design's WebGL aura (assets/design/liquid.js).

uniform vec2 uSize;
uniform float uTime;   // seconds, faster while playing
uniform float uBass;   // 0–1, stirs the fluid
uniform float uBeat;   // 0–1, lights it up on each kick
uniform float uRipT;   // seconds since the shockwave, < 0 when none
uniform vec2 uRipC;    // shockwave centre, in the aura's normalised space
uniform vec3 uC1;
uniform vec3 uC2;
uniform vec3 uC3;

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
             mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  mat2 m = mat2(1.6, 1.2, -1.2, 1.6);
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p = m * p;
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 p = (frag - 0.5 * uSize) / uSize.y;

  // Shockwave: a ring that pushes the fluid outwards, then fades.
  vec2 d = p - uRipC;
  float dist = length(d);
  if (uRipT > 0.0) {
    float rip = sin(dist * 26.0 - uRipT * 12.0)
        * exp(-uRipT * 1.8) * exp(-dist * 1.6) * 0.07;
    p += d / (dist + 1e-3) * rip;
  }

  float t = uTime * 0.05;
  vec2 q = vec2(fbm(p * 1.5 + t), fbm(p * 1.5 + vec2(5.2, 1.3) - t));
  vec2 s = vec2(
      fbm(p * 1.5 + 3.6 * q + vec2(1.7, 9.2) + t * 1.3 + uBass * 0.8),
      fbm(p * 1.5 + 3.6 * q + vec2(8.3, 2.8) - t * 1.1));
  float f = fbm(p * 1.5 + 3.9 * s + uBeat * 0.25);

  vec3 col = mix(uC3 * 0.3, uC2 * 0.9, smoothstep(0.15, 0.7, f));
  col = mix(col, uC1, smoothstep(0.35, 0.95,
      length(q) * f * 1.5 + uBeat * 0.12));
  col += uC1 * pow(f, 4.0) * (0.5 + uBeat * 0.9);
  float rim = smoothstep(0.6, 0.64, f) - smoothstep(0.64, 0.74, f);
  col += vec3(rim * 0.10 * (1.0 + uBeat));

  // Dither: smooth gradients on a dark base band without it.
  float n = hash(frag);
  fragColor = vec4(col + (n - 0.5) / 255.0, 1.0);
}
