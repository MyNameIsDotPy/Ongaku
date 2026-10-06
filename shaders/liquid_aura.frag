#version 460 core

#include <flutter/runtime_effect.glsl>

// The player's aura in one pass: five radial blobs composited with the
// `screen` blend over a dark base. Drawing them as separate circles with
// BlendMode.screen costs an extra GPU pass per blob on phones.

uniform vec3 uBase;
uniform float uAlpha;
// Per blob: centre x, centre y, radius (logical pixels), then its colour.
uniform vec3 uBlob0;
uniform vec3 uBlob1;
uniform vec3 uBlob2;
uniform vec3 uBlob3;
uniform vec3 uBlob4;
uniform vec3 uColor0;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;

out vec4 fragColor;

// Linear radial gradient from uAlpha at the centre to 0 at the edge,
// premultiplied, then screen: s + d - s·d.
vec3 screenBlob(vec3 dst, vec2 p, vec3 blob, vec3 color) {
  float a = uAlpha * (1.0 - clamp(distance(p, blob.xy) / blob.z, 0.0, 1.0));
  vec3 src = color * a;
  return src + dst - src * dst;
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec3 col = uBase;
  col = screenBlob(col, p, uBlob0, uColor0);
  col = screenBlob(col, p, uBlob1, uColor1);
  col = screenBlob(col, p, uBlob2, uColor2);
  col = screenBlob(col, p, uBlob3, uColor3);
  col = screenBlob(col, p, uBlob4, uColor4);
  // Dither: smooth gradients on a dark base band without it.
  float n = fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
  fragColor = vec4(col + (n - 0.5) / 255.0, 1.0);
}
