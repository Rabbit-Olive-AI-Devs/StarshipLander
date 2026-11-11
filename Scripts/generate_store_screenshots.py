#!/usr/bin/env python3
"""
Build the App Store screenshot set from raw simulator captures.

    python3 Scripts/generate_store_screenshots.py <captures-dir>

<captures-dir> holds the PNGs produced by Scripts/ci_screenshots.sh. Each output
is a 1284x2778 PNG in Screenshots/appstore-v2.3.0/: headline on top, the capture
in a rounded frame below. The frame runs off the bottom edge, which also crops
the ad banner area out of the capture.

Requires: Pillow, numpy
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "Screenshots" / "appstore-v2.3.0"
FONT_PATH = ROOT / "RocketLander" / "Fonts" / "Orbitron-VariableFont_wght.ttf"

CANVAS = (1284, 2778)
FRAME_WIDTH = 1088
FRAME_TOP = 660
FRAME_RADIUS = 96
CAPTURE_KEEP = 0.895  # fraction of capture height kept (drops the ad banner)

# (output name, capture file, headline lines, kicker, accent RGB)
SHOTS = [
    ("01_land_the_starship", "11_mars_f2.png", ["LAND THE", "STARSHIP"], "PRECISION BEATS LUCK", (255, 140, 40)),
    ("02_perfect_landing", "20_result.png", ["STICK IT.", "SCORE IT."], "EVERY LANDING IS RATED", (70, 220, 120)),
    ("03_ten_worlds", "12_jupiter_f2.png", ["10 WORLDS", "10 GRAVITIES"], "MOON TO JUPITER CAMPAIGN", (255, 190, 90)),
    ("04_pilot_rank", "01_menu.png", ["CADET TO", "LEGEND"], "EARN XP ON EVERY FLIGHT", (90, 170, 255)),
    ("05_hangar", "02_hangar.png", ["BUILD YOUR", "FLEET"], "7 STARSHIPS TO UNLOCK", (200, 110, 255)),
    ("06_daily_challenge", "16_daily_f2.png", ["NEW MISSION", "EVERY DAY"], "DAILY CHALLENGE", (60, 220, 230)),
]


def font(size, weight=900):
    f = ImageFont.truetype(str(FONT_PATH), size)
    f.set_variation_by_axes([weight])
    return f


def background(accent, seed):
    w, h = CANVAS
    rng = np.random.default_rng(seed)
    y = np.linspace(0, 1, h)[:, None]
    x = np.linspace(0, 1, w)[None, :]
    base = np.array([6, 8, 20], dtype=float)
    img = np.ones((h, w, 3)) * base
    # accent glow behind the headline and a softer one low on the canvas
    for cx, cy, radius, strength in ((0.5, 0.10, 0.55, 0.55), (0.5, 0.95, 0.8, 0.22)):
        d = np.sqrt(((x - cx) * w / h) ** 2 + (y - cy) ** 2)
        glow = np.clip(1 - d / radius, 0, 1) ** 2 * strength
        img += glow[..., None] * np.array(accent, dtype=float)
    canvas = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB")
    draw = ImageDraw.Draw(canvas)
    for _ in range(260):
        sx, sy = rng.integers(0, w), rng.integers(0, h)
        r = rng.choice([1, 1, 1, 2, 2, 3])
        a = int(rng.integers(90, 230))
        draw.ellipse((sx - r, sy - r, sx + r, sy + r), fill=(a, a, min(255, a + 20)))
    return canvas


def fit_font(lines, max_width, start=150):
    size = start
    while size > 60:
        f = font(size)
        if max(f.getlength(line) for line in lines) <= max_width:
            return f
        size -= 4
    return font(60)


def draw_headline(canvas, lines, kicker, accent):
    draw = ImageDraw.Draw(canvas)
    w, _ = CANVAS
    kicker_font = font(44, 700)
    kw = kicker_font.getlength(kicker)
    pad = 34
    pill = (w / 2 - kw / 2 - pad, 118, w / 2 + kw / 2 + pad, 118 + 84)
    draw.rounded_rectangle(pill, radius=42, fill=tuple(int(c * 0.28) for c in accent), outline=accent, width=3)
    draw.text((w / 2, 160), kicker, font=kicker_font, fill=(255, 255, 255), anchor="mm")

    head_font = fit_font(lines, w - 150)
    y = 250
    for i, line in enumerate(lines):
        fill = (255, 255, 255) if i == 0 else accent
        draw.text((w / 2, y), line, font=head_font, fill=fill, anchor="ma")
        y += int(head_font.size * 1.16)


def framed_capture(path):
    shot = Image.open(path).convert("RGB")
    shot = shot.crop((0, 0, shot.width, int(shot.height * CAPTURE_KEEP)))
    height = round(shot.height * FRAME_WIDTH / shot.width)
    shot = shot.resize((FRAME_WIDTH, height), Image.LANCZOS)
    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, FRAME_WIDTH, height + FRAME_RADIUS * 2), radius=FRAME_RADIUS, fill=255
    )
    return shot, mask


def compose(name, capture, lines, kicker, accent, seed):
    canvas = background(accent, seed)
    draw_headline(canvas, lines, kicker, accent)
    shot, mask = framed_capture(capture)
    x = (CANVAS[0] - FRAME_WIDTH) // 2
    border = 10

    glow = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle(
        (x - 30, FRAME_TOP - 30, x + FRAME_WIDTH + 30, CANVAS[1] + 200),
        radius=FRAME_RADIUS + 30, fill=accent + (120,),
    )
    canvas.paste(glow.filter(ImageFilter.GaussianBlur(60)), (0, 0), glow.filter(ImageFilter.GaussianBlur(60)))
    ImageDraw.Draw(canvas).rounded_rectangle(
        (x - border, FRAME_TOP - border, x + FRAME_WIDTH + border, CANVAS[1] + 200),
        radius=FRAME_RADIUS + border, fill=(28, 30, 44), outline=(120, 126, 150), width=3,
    )
    canvas.paste(shot, (x, FRAME_TOP), mask)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out = OUT_DIR / f"{name}.png"
    canvas.save(out, "PNG")
    assert canvas.size == CANVAS
    print(f"{out.name}  <- {capture.name}")


def main():
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    captures = Path(sys.argv[1])
    for seed, (name, capture, lines, kicker, accent) in enumerate(SHOTS):
        compose(name, captures / capture, lines, kicker, accent, seed)


if __name__ == "__main__":
    main()
