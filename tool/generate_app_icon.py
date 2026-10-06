#!/usr/bin/env python3
"""Generates every platform's app icon from the Ongaku brand mark
(OngakuBrand: ink tile with the wave glyph). Needs rsvg-convert and magick.

    python3 tool/generate_app_icon.py
"""

import pathlib
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
INK = "#0E1217"  # OngakuColors.light.fg
PAPER = "#FBFCFD"  # OngakuColors.light.bg
WAVE = "M3 12c2 0 2-5 4.5-5S10 17 12 17s2.5-10 4.5-10S19 12 21 12"


def tile_svg(canvas, tile, radius, stroke=1.7):
    """Ink tile of side [tile] centred on [canvas]; glyph is 62% of the tile."""
    offset = (canvas - tile) / 2
    glyph = tile * 0.62
    scale = glyph / 24
    g = (canvas - glyph) / 2
    shadow = ""
    if tile < canvas:  # macOS: soft drop shadow under the inset tile
        shadow = (
            '<filter id="s" x="-20%" y="-20%" width="140%" height="140%">'
            f'<feDropShadow dx="0" dy="{canvas * 0.01}" stdDeviation="{canvas * 0.012}" '
            'flood-opacity="0.3"/></filter>'
        )
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{canvas}" height="{canvas}" '
        f'viewBox="0 0 {canvas} {canvas}"><defs>{shadow}</defs>'
        f'<rect x="{offset}" y="{offset}" width="{tile}" height="{tile}" '
        f'rx="{radius}" fill="{INK}"{" filter=\"url(#s)\"" if shadow else ""}/>'
        f'<g transform="translate({g} {g}) scale({scale})" fill="none" stroke="{PAPER}" '
        f'stroke-width="{stroke}" stroke-linecap="round" stroke-linejoin="round">'
        f'<path d="{WAVE}"/></g></svg>'
    )


def render(svg, out, size):
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", suffix=".svg") as f:
        f.write(svg)
        f.flush()
        subprocess.run(
            ["rsvg-convert", "-w", str(size), "-h", str(size), "-o", str(out), f.name],
            check=True,
        )


def full_tile(size):
    # Thicker stroke keeps the wave legible at 16–32 px.
    return tile_svg(1024, 1024, 1024 * 0.31, stroke=1.7 if size > 32 else 2.4)


def android():
    res = ROOT / "android/app/src/main/res"
    for density, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        render(full_tile(size), res / f"mipmap-{density}/ic_launcher.png", size)
    # Adaptive icon (API 26+): ink background, wave in the 66 dp safe zone.
    # The same foreground doubles as the themed (monochrome) icon.
    (res / "values/ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        f'    <color name="ic_launcher_background">{INK}</color>\n</resources>\n'
    )
    (res / "drawable/ic_launcher_foreground.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
        '    android:width="108dp" android:height="108dp"\n'
        '    android:viewportWidth="108" android:viewportHeight="108">\n'
        '    <group android:translateX="30" android:translateY="30"\n'
        '        android:scaleX="2" android:scaleY="2">\n'
        f'        <path android:pathData="{WAVE}"\n'
        f'            android:strokeColor="{PAPER}" android:strokeWidth="1.7"\n'
        '            android:strokeLineCap="round" android:strokeLineJoin="round" />\n'
        '    </group>\n</vector>\n'
    )
    anydpi = res / "mipmap-anydpi-v26"
    anydpi.mkdir(exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@drawable/ic_launcher_foreground" />\n'
        '    <monochrome android:drawable="@drawable/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n'
    )


def macos():
    # Apple's grid: 824 pt tile on a 1024 canvas, ~185 pt corner radius.
    svg = tile_svg(1024, 824, 185)
    for size in [16, 32, 64, 128, 256, 512, 1024]:
        render(svg, ROOT / f"macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_{size}.png", size)


def windows():
    with tempfile.TemporaryDirectory() as d:
        pngs = []
        for size in [16, 24, 32, 48, 64, 128, 256]:
            p = pathlib.Path(d) / f"{size}.png"
            render(full_tile(size), p, size)
            pngs.append(str(p))
        subprocess.run(["magick", *pngs, str(ROOT / "windows/runner/resources/app_icon.ico")], check=True)


def source():
    (ROOT / "assets/icon").mkdir(parents=True, exist_ok=True)
    (ROOT / "assets/icon/app_icon.svg").write_text(full_tile(1024))
    render(full_tile(1024), ROOT / "assets/icon/app_icon.png", 512)


if __name__ == "__main__":
    source()
    android()
    macos()
    windows()
