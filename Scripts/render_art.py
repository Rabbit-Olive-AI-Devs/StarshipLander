#!/usr/bin/env python3
"""
Renders Starship Lander's realistic art assets into RocketLander/Assets.xcassets.

Everything is procedural (numpy noise + per-pixel lighting), so the art can be
re-rendered or tuned without external files:

  planet_<name>   lit spheres with surface detail and atmosphere (Earth, Moon,
                  Mars, Jupiter, Saturn + rings, Europa, Phobos, Sun)
  sky_stars       deep-space starfield with a Milky Way band (drawn additively)
  ground_detail   grayscale regolith/rock detail, tinted per world in game
  ship_<skin>     Starship body for each Hangar skin (legs rendered separately)
  ship_leg        right landing leg (left leg is mirrored in game)

Usage:  python3 Scripts/render_art.py [--only planet_earth,ship_stainless] [--preview DIR]
"""
import argparse
import json
import math
import os

import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "RocketLander", "Assets.xcassets")

LIGHT = np.array([-0.55, 0.5, 0.67])
LIGHT = LIGHT / np.linalg.norm(LIGHT)


# ---------------------------------------------------------------------------
# Noise
# ---------------------------------------------------------------------------

def _hash(ix, iy, iz, seed):
    h = (ix * 374761393 + iy * 668265263 + iz * 2147483647 + seed * 144665) & 0xFFFFFFFF
    h = ((h ^ (h >> 13)) * 1274126177) & 0xFFFFFFFF
    h = h ^ (h >> 16)
    return (h & 0xFFFFFF) / float(0xFFFFFF)


def value_noise3(x, y, z, seed=0):
    xi, yi, zi = np.floor(x).astype(np.int64), np.floor(y).astype(np.int64), np.floor(z).astype(np.int64)
    xf, yf, zf = x - xi, y - yi, z - zi
    u, v, w = xf * xf * (3 - 2 * xf), yf * yf * (3 - 2 * yf), zf * zf * (3 - 2 * zf)
    out = 0.0
    for dx in (0, 1):
        for dy in (0, 1):
            for dz in (0, 1):
                weight = (u if dx else 1 - u) * (v if dy else 1 - v) * (w if dz else 1 - w)
                out = out + weight * _hash(xi + dx, yi + dy, zi + dz, seed)
    return out


def fbm3(x, y, z, octaves=6, lacunarity=2.0, gain=0.5, seed=0):
    total, amp, freq, norm = 0.0, 1.0, 1.0, 0.0
    for o in range(octaves):
        total = total + amp * value_noise3(x * freq, y * freq, z * freq, seed + o * 17)
        norm += amp
        amp *= gain
        freq *= lacunarity
    return total / norm


def ridged3(x, y, z, octaves=5, seed=0):
    total, amp, freq, norm = 0.0, 1.0, 1.0, 0.0
    for o in range(octaves):
        n = value_noise3(x * freq, y * freq, z * freq, seed + o * 31)
        total = total + amp * (1 - abs(n * 2 - 1))
        norm += amp
        amp *= 0.5
        freq *= 2.1
    return total / norm


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)


def mix(a, b, t):
    return a * (1 - t) + b * t


def rgb(*c):
    return np.array(c, dtype=np.float64)


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def save_imageset(name, img):
    folder = os.path.join(ASSETS, f"{name}.imageset")
    os.makedirs(folder, exist_ok=True)
    img.save(os.path.join(folder, f"{name}.png"), optimize=True)
    contents = {
        "images": [{"filename": f"{name}.png", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
    }
    with open(os.path.join(folder, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    print(f"  wrote {name} {img.size}")


def to_image(rgb_arr, alpha, downsample=2):
    rgba = np.dstack([np.clip(rgb_arr, 0, 1), np.clip(alpha, 0, 1)])
    # premultiply for clean downsampling, then un-premultiply
    rgba[..., :3] *= rgba[..., 3:4]
    img = Image.fromarray((rgba * 255 + 0.5).astype(np.uint8), "RGBA")
    if downsample > 1:
        img = img.resize((img.width // downsample, img.height // downsample), Image.LANCZOS)
    arr = np.asarray(img).astype(np.float64) / 255
    a = arr[..., 3:4]
    arr[..., :3] = np.where(a > 0, arr[..., :3] / np.maximum(a, 1e-6), 0)
    return Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA")


# ---------------------------------------------------------------------------
# Planets
# ---------------------------------------------------------------------------

def sphere_grid(size, disk_fraction):
    """Pixel grid in planet-radius units; returns x, y (up), r, inside mask."""
    half = size / 2
    ys, xs = np.mgrid[0:size, 0:size]
    x = (xs + 0.5 - half) / (half * disk_fraction)
    y = -(ys + 0.5 - half) / (half * disk_fraction)
    r = np.sqrt(x * x + y * y)
    return x, y, r


def rotate(p, tilt=0.35, spin=0.6):
    x, y, z = p
    # spin about y, then tilt about z
    cs, ss = math.cos(spin), math.sin(spin)
    x, z = x * cs + z * ss, -x * ss + z * cs
    ct, st = math.cos(tilt), math.sin(tilt)
    x, y = x * ct - y * st, x * st + y * ct
    return x, y, z


def add_craters(p, albedo, count, seed, min_r=0.02, max_r=0.12, depth=0.25):
    """Bowl craters lit from LIGHT: the wall facing the light is bright, the other in shadow."""
    rng = np.random.default_rng(seed)
    x, y, z = p
    for _ in range(count):
        c = rng.normal(size=3)
        c /= np.linalg.norm(c)
        a = min_r + (max_r - min_r) * rng.random() ** 3  # many small, few large
        dot = x * c[0] + y * c[1] + z * c[2]
        d = np.arccos(np.clip(dot, -1, 1)) / a
        near = d < 1.6
        if not near.any():
            continue
        tx, ty, tz = x - c[0] * dot, y - c[1] * dot, z - c[2] * dot
        tl = np.sqrt(tx * tx + ty * ty + tz * tz) + 1e-9
        lt = (tx * LIGHT[0] + ty * LIGHT[1] + tz * LIGHT[2]) / tl  # +1 = this side faces away from light source
        wall = np.where(d < 1, d ** 1.5, 0)
        rim = np.exp(-((d - 1.0) / 0.14) ** 2)
        floor = np.where(d < 0.55, 1, 0) * 0.15
        relief = (-lt * wall * 0.9 + lt * rim * 0.6) * depth - floor * depth * 0.3
        albedo = albedo + np.where(near, relief, 0)
    return albedo


def render_planet(name, surface, size=768, disk=0.82, atmosphere=None, light_wrap=0.0, ss=2):
    S = size * ss
    x, y, r = sphere_grid(S, disk)
    inside = r <= 1.0
    z = np.sqrt(np.clip(1 - r * r, 0, 1))
    n = np.stack([x, y, z])
    p = rotate((x, y, z))
    color = surface(p, n)  # (S, S, 3)

    ndl = (n[0] * LIGHT[0] + n[1] * LIGHT[1] + n[2] * LIGHT[2])
    lit = np.clip((ndl + light_wrap) / (1 + light_wrap), 0, 1) ** 0.85
    limb = 0.75 + 0.25 * z
    shaded = color * (0.035 + 0.965 * lit * limb)[..., None]

    alpha = inside.astype(np.float64)
    out = shaded
    if atmosphere is not None:
        acol, strength, width = atmosphere
        acol = np.asarray(acol)
        # scattering inside the limb (lit side only)
        rim_in = (1 - z) ** 3 * np.clip(ndl + 0.35, 0, 1)
        out = out + acol * (rim_in * strength)[..., None] * inside[..., None]
        # glow outside the disk
        outside = ~inside
        glow = np.exp(-((r - 1) / width) ** 2) * np.clip(
            (x * LIGHT[0] + y * LIGHT[1]) / np.maximum(r, 1e-6) + 0.6, 0, 1.6) / 1.6
        glow = np.where(outside, glow * strength * 0.9, 0)
        out = np.where(outside[..., None], acol[None, None, :], out)
        alpha = np.where(outside, glow, alpha)
    return to_image(out, alpha, ss)


def moon_surface(p, n):
    x, y, z = p
    base = 0.62 + 0.18 * (fbm3(x * 3, y * 3, z * 3, 6, seed=3) - 0.5)
    maria = smoothstep(0.5, 0.64, fbm3(x * 1.3 + 4, y * 1.3, z * 1.3, 6, seed=9))
    albedo = base * (1 - 0.42 * maria)
    albedo = albedo + 0.07 * (fbm3(x * 24, y * 24, z * 24, 4, seed=5) - 0.5)
    albedo = add_craters(p, albedo, 260, 11, 0.012, 0.11, 0.22)
    return np.stack([albedo * 0.98, albedo * 0.97, albedo * 0.95], -1)


def mars_surface(p, n):
    x, y, z = p
    f = fbm3(x * 2.2, y * 2.2, z * 2.2, 7, seed=21)
    dark = smoothstep(0.5, 0.62, fbm3(x * 1.4 + 2, y * 1.4, z * 1.4, 5, seed=33))
    rust = rgb(0.78, 0.4, 0.22)
    darkc = rgb(0.38, 0.2, 0.13)
    light = rgb(0.9, 0.6, 0.4)
    col = mix(rust, light, smoothstep(0.45, 0.7, f)[..., None])
    col = mix(col, darkc, (dark * 0.75)[..., None])
    col = col * (0.9 + 0.2 * fbm3(x * 20, y * 20, z * 20, 3, seed=7))[..., None]
    shade = add_craters(p, np.ones_like(x), 45, 21, 0.015, 0.06, 0.25)
    col = col * shade[..., None]
    cap = smoothstep(0.88, 0.93, y + 0.04 * fbm3(x * 9, y * 9, z * 9, 3, seed=2))
    col = mix(col, rgb(0.96, 0.95, 0.94), cap[..., None])
    return col


def earth_surface(p, n):
    x, y, z = p
    h = fbm3(x * 1.6 + 1.3, y * 1.6, z * 1.6, 7, seed=41)
    land = smoothstep(0.495, 0.515, h)
    lat = np.abs(y)
    ocean = mix(rgb(0.02, 0.08, 0.24), rgb(0.05, 0.25, 0.45), smoothstep(0.42, 0.495, h)[..., None])
    veg = mix(rgb(0.13, 0.3, 0.09), rgb(0.42, 0.36, 0.2), smoothstep(0.55, 0.7, fbm3(x * 4, y * 4, z * 4, 5, seed=4))[..., None])
    desert = rgb(0.72, 0.6, 0.4)
    landc = mix(veg, desert, (smoothstep(0.15, 0.35, 0.35 - np.abs(lat - 0.3)) * smoothstep(0.5, 0.65, h))[..., None])
    col = mix(ocean, landc, land[..., None])
    ice = smoothstep(0.88, 0.93, lat + 0.05 * fbm3(x * 6, y * 6, z * 6, 3, seed=8))
    col = mix(col, rgb(0.93, 0.95, 0.98), ice[..., None])
    # clouds
    c = fbm3(x * 2.6 + 9, y * 5.0, z * 2.6, 7, seed=55)
    swirl = fbm3(x * 7 + c * 2, y * 7, z * 7, 4, seed=66)
    clouds = smoothstep(0.5, 0.68, c * 0.7 + swirl * 0.3)
    col = mix(col, rgb(0.97, 0.97, 0.98), (clouds * 0.92)[..., None])
    # sun glint on water
    hvec = LIGHT + np.array([0, 0, 1.0])
    hvec /= np.linalg.norm(hvec)
    spec = np.clip(n[0] * hvec[0] + n[1] * hvec[1] + n[2] * hvec[2], 0, 1) ** 60
    col = col + (spec * (1 - land) * (1 - clouds) * 0.6)[..., None]
    return col


def jupiter_surface(p, n):
    x, y, z = p
    turb = fbm3(x * 4, y * 14, z * 4, 6, seed=71) - 0.5
    eddies = fbm3(x * 16, y * 40, z * 16, 4, seed=73) - 0.5
    lat = n[1] + 0.035 * turb + 0.01 * eddies
    bands = [rgb(0.92, 0.87, 0.78), rgb(0.8, 0.66, 0.5), rgb(0.9, 0.84, 0.72), rgb(0.7, 0.53, 0.4),
             rgb(0.94, 0.9, 0.82), rgb(0.76, 0.6, 0.46), rgb(0.87, 0.79, 0.66), rgb(0.66, 0.5, 0.38)]
    B = np.stack(bands)
    t = (lat + 1) * 6.5
    i = np.floor(t).astype(int) % len(bands)
    j = (i + 1) % len(bands)
    f = smoothstep(0.25, 0.75, t - np.floor(t))
    col = B[i] * (1 - f)[..., None] + B[j] * f[..., None]
    col = col * (0.94 + 0.12 * fbm3(x * 20, y * 50, z * 20, 4, seed=72))[..., None]
    sx, sy = (n[0] - 0.22) / 0.16, (n[1] + 0.32) / 0.075
    spot = np.exp(-(sx * sx + sy * sy) ** 1.4)
    col = mix(col, rgb(0.78, 0.42, 0.28), (spot * 0.8)[..., None])
    pole = smoothstep(0.8, 0.98, np.abs(n[1]))
    return mix(col, rgb(0.55, 0.5, 0.45), (pole * 0.5)[..., None])


def saturn_surface(p, n):
    x, y, z = p
    lat = n[1] + 0.02 * (fbm3(x * 3, y * 10, z * 3, 4, seed=81) - 0.5)
    t = np.sin(lat * 22) * 0.5 + 0.5
    col = mix(rgb(0.9, 0.82, 0.62), rgb(0.78, 0.66, 0.46), (t * 0.6)[..., None])
    pole = smoothstep(0.75, 0.95, np.abs(n[1]))
    return mix(col, rgb(0.62, 0.62, 0.55), (pole * 0.6)[..., None])


def europa_surface(p, n):
    x, y, z = p
    base = mix(rgb(0.92, 0.88, 0.8), rgb(0.78, 0.7, 0.6), smoothstep(0.45, 0.7, fbm3(x * 2, y * 2, z * 2, 5, seed=91))[..., None])
    lines = np.zeros_like(x)
    for k, s in ((5, 101), (9, 102), (15, 103)):
        rr = ridged3(x * k, y * k, z * k, 3, seed=s)
        lines = np.maximum(lines, smoothstep(0.9, 0.97, rr) * (0.9 if k == 5 else 0.6))
    col = mix(base, rgb(0.55, 0.32, 0.2), (lines * 0.75)[..., None])
    return col


def phobos_surface(p, n):
    x, y, z = p
    a = 0.42 + 0.12 * (fbm3(x * 4, y * 4, z * 4, 6, seed=111) - 0.5)
    a = add_craters(p, a, 60, 113, 0.03, 0.14, 0.35)
    # Stickney
    a = add_craters(p, a, 1, 7, 0.32, 0.33, 0.45)
    return np.stack([a * 1.02, a * 0.94, a * 0.86], -1)


def render_sun(size=768, ss=2):
    S = size * ss
    x, y, r = sphere_grid(S, 0.42)
    inside = r <= 1
    mu = np.sqrt(np.clip(1 - r * r, 0, 1))
    gran = fbm3(x * 40, y * 40, 0.5, 3, seed=121)
    core = rgb(1.0, 0.97, 0.88)
    col = core * (0.55 + 0.45 * mu)[..., None] * (0.94 + 0.12 * gran)[..., None]
    col = mix(col, rgb(1.0, 0.75, 0.4), ((1 - mu) ** 2 * 0.6)[..., None])
    corona = np.exp(-(r - 1) * 2.4) * 0.8 * smoothstep(2.3, 1.6, r)
    alpha = np.where(inside, 1.0, np.clip(corona, 0, 1))
    col = np.where(inside[..., None], col, rgb(1.0, 0.85, 0.55)[None, None, :])
    return to_image(col, alpha, ss)


def render_saturn(ss=2):
    w, h = 1536, 768
    W, H = w * ss, h * ss
    R = H * 0.3  # planet radius in px
    ys, xs = np.mgrid[0:H, 0:W]
    x = (xs + 0.5 - W / 2) / R
    y = -(ys + 0.5 - H / 2) / R
    ratio = 0.28
    r = np.sqrt(x * x + y * y)
    inside = r <= 1
    z = np.sqrt(np.clip(1 - r * r, 0, 1))
    n = np.stack([x, y, z])
    p = rotate((x, y, z), tilt=0.12)
    col = saturn_surface(p, n)
    ndl = n[0] * LIGHT[0] + n[1] * LIGHT[1] + n[2] * LIGHT[2]
    planet = col * (0.02 + 0.98 * np.clip(ndl, 0, 1) ** 1.1 * (0.65 + 0.35 * z))[..., None]

    # rings in the tilted plane
    ry = y / ratio
    rr = np.sqrt(x * x + ry * ry)
    band = np.interp(rr, [1.2, 1.25, 1.5, 1.55, 1.95, 2.0, 2.05, 2.25, 2.3],
                     [0, 0.35, 0.55, 0.8, 0.85, 0.05, 0.6, 0.5, 0])
    band = band * (0.8 + 0.4 * value_noise3(rr * 60, 0.3, 0.2, seed=131))
    ring_col = mix(rgb(0.78, 0.7, 0.55), rgb(0.95, 0.88, 0.72), np.clip(rr - 1.2, 0, 1)[..., None])
    ring_lit = 0.55 + 0.45 * np.clip(-x * 0.4 + 0.6, 0, 1)
    ring_rgb = ring_col * ring_lit[..., None]
    front = y < 0  # near half of the ring plane is below the planet's center
    ring_visible = band * np.where(inside & ~front, 0, 1)

    out = np.where(inside[..., None], planet, 0)
    alpha = inside.astype(np.float64)
    a_ring = np.clip(ring_visible, 0, 1)
    out = out * (1 - a_ring[..., None]) + ring_rgb * a_ring[..., None]
    alpha = alpha + a_ring * (1 - alpha)
    return to_image(out, alpha, ss)


# ---------------------------------------------------------------------------
# Sky
# ---------------------------------------------------------------------------

def render_starfield(w=1024, h=2048, seed=7):
    rng = np.random.default_rng(seed)
    img = np.zeros((h, w, 3))
    ys, xs = np.mgrid[0:h, 0:w]
    u, v = xs / w, ys / h
    # Milky Way band: diagonal
    d = (u * 0.85 - v * 0.45 + 0.05) / 0.16
    band = np.exp(-d * d)
    neb = fbm3(u * 4, v * 8, 0.3, 7, seed=141)
    dust = smoothstep(0.6, 0.78, ridged3(u * 4, v * 8, 0.7, 6, seed=142))
    glow = band * (0.45 + 0.55 * neb) * (1 - 0.6 * dust)
    tint = mix(rgb(0.55, 0.62, 0.85), rgb(0.95, 0.8, 0.62), smoothstep(0.3, 1.0, band)[..., None])
    img += tint * (glow * 0.32)[..., None]
    # faint colored nebulae
    for (cx, cy, rad, col) in ((0.25, 0.3, 0.12, (0.5, 0.15, 0.35)), (0.75, 0.68, 0.1, (0.1, 0.25, 0.5))):
        g = np.exp(-(((u - cx) / rad) ** 2 + ((v - cy) / rad / 0.6) ** 2)) * fbm3(u * 9, v * 9, 1.1, 4, seed=150)
        img += np.array(col) * (g * 0.25)[..., None]

    def splat(cx, cy, radius, color, intensity):
        x0, x1 = int(max(0, cx - radius * 4)), int(min(w, cx + radius * 4 + 1))
        y0, y1 = int(max(0, cy - radius * 4)), int(min(h, cy + radius * 4 + 1))
        if x0 >= x1 or y0 >= y1:
            return
        yy, xx = np.mgrid[y0:y1, x0:x1]
        g = np.exp(-(((xx - cx) ** 2 + (yy - cy) ** 2) / (2 * radius * radius)))
        img[y0:y1, x0:x1] += np.array(color) * (g * intensity)[..., None]

    def star_color(t):
        return mix(rgb(1.0, 0.75, 0.55), rgb(0.7, 0.8, 1.0), t)

    # field stars (denser in the band)
    count = 9000
    sx = rng.uniform(0, w, count)
    sy = rng.uniform(0, h, count)
    keep = rng.uniform(0, 1, count) < (0.35 + 0.65 * np.exp(-((sx / w * 0.85 - sy / h * 0.45 + 0.05) / 0.2) ** 2))
    for x0, y0 in zip(sx[keep], sy[keep]):
        mag = rng.pareto(2.2) * 0.25 + 0.08
        splat(x0, y0, 0.55 + min(mag, 1.2) * 0.4, star_color(rng.uniform(0.2, 1)), min(mag, 1.6))
    # bright stars with soft halo and faint spikes
    for _ in range(26):
        x0, y0 = rng.uniform(0, w), rng.uniform(0, h)
        c = star_color(rng.uniform(0, 1))
        splat(x0, y0, 1.1, c, 2.2)
        splat(x0, y0, 5.0, c, 0.12)
        for dx, dy in ((1, 0), (0, 1)):
            for k in range(1, 14):
                splat(x0 + dx * k, y0 + dy * k, 0.7, c, 0.25 * (1 - k / 14))
                splat(x0 - dx * k, y0 - dy * k, 0.7, c, 0.25 * (1 - k / 14))
    img = 1 - np.exp(-img * 1.4)  # soft tone-map
    return Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8), "RGB")


def render_ground(w=1024, h=512):
    ys, xs = np.mgrid[0:h, 0:w]
    u, v = xs / w * 8, ys / h * 4
    height = fbm3(u, v, 0.5, 7, seed=161)
    height += 0.35 * ridged3(u * 2, v * 3, 1.5, 4, seed=162)
    rng = np.random.default_rng(163)
    for _ in range(70):  # small craters
        cx, cy, rad = rng.uniform(0, w), rng.uniform(0, h), rng.uniform(4, 22)
        d = np.sqrt((xs - cx) ** 2 + ((ys - cy) * 2.2) ** 2) / rad
        height += np.where(d < 1, -(1 - d * d) * 0.25, 0) + np.exp(-((d - 1) / 0.18) ** 2) * 0.08
    for _ in range(260):  # pebbles
        cx, cy, rad = rng.uniform(0, w), rng.uniform(0, h), rng.uniform(1.5, 5)
        d = np.sqrt((xs - cx) ** 2 + ((ys - cy) * 1.6) ** 2) / rad
        height += np.where(d < 1, np.sqrt(np.clip(1 - d * d, 0, 1)) * 0.12, 0)
    gy, gx = np.gradient(height)
    shade = np.clip(0.75 - gx * 18 - gy * 22, 0, 1.3)
    strata = 0.06 * np.sin(v * 9 + 2 * fbm3(u * 2, v, 2, 3, seed=164))
    depth = 1 - 0.55 * (ys / h) ** 1.3  # darker deeper underground
    val = (0.62 + 0.25 * (height - 0.5) + strata) * shade * depth
    val = val * (0.92 + 0.12 * fbm3(u * 30, v * 30, 3, 2, seed=165))
    val = np.clip(val / max(val.max(), 1e-6) * 1.05, 0, 1)
    return Image.fromarray((val * 255 + 0.5).astype(np.uint8), "L").convert("RGB")


# ---------------------------------------------------------------------------
# Starship
# ---------------------------------------------------------------------------

SHIP_SCALE = 6           # px per point at final resolution
SHIP_X = (-30.0, 30.0)   # point extents in ship space (see StarshipArt.swift)
SHIP_Y = (-46.0, 44.0)
HULL_R = 9.5             # hull radius (pts)
HULL_BOTTOM = -30.0
NOSE_START = 18.0
NOSE_LEN = 22.0          # nose apex at y = 40
LEG_HINGE = (7.0, -31.0)  # right leg hinge (left is mirrored)

SKINS = {
    "stainless": dict(paint=None, metal=(0.9, 0.92, 0.95), tiles="side", accent=None),
    "nightOps": dict(paint=None, metal=(0.9, 0.92, 0.95), tiles="all", accent=(1.0, 0.55, 0.1)),
    "redPlanet": dict(paint=None, metal=(0.95, 0.7, 0.55), tiles="side", accent=None, dust=True),
    "lunarGold": dict(paint=None, metal=(1.0, 0.8, 0.45), tiles="side", accent=None),
    "europaIce": dict(paint=(0.9, 0.93, 0.97), metal=None, tiles="side", accent=(0.3, 0.85, 1.0), tile_tint=(0.08, 0.12, 0.18)),
    "synthwave": dict(paint=(0.2, 0.1, 0.32), metal=None, tiles="side", accent=(0.2, 0.95, 1.0), neon=(1.0, 0.3, 0.8)),
    "legend": dict(paint=(0.05, 0.05, 0.06), metal=None, tiles="side", accent=(1.0, 0.8, 0.35), gold_flaps=True),
}


def ship_grid(ss, xr=SHIP_X, yr=SHIP_Y):
    s = SHIP_SCALE * ss
    W = int(round((xr[1] - xr[0]) * s))
    H = int(round((yr[1] - yr[0]) * s))
    ys, xs = np.mgrid[0:H, 0:W]
    x = xr[0] + (xs + 0.5) / s
    y = yr[1] - (ys + 0.5) / s
    return x, y, W, H


def hull_radius(y):
    """Ogive nose on a cylinder; returns radius and dr/dy."""
    u = np.clip((y - NOSE_START) / NOSE_LEN, 0, 0.999)
    k = 0.62
    base = np.clip(1 - u * u, 1e-4, 1)
    r = HULL_R * base ** k
    dr = HULL_R * k * base ** (k - 1) * (-2 * u) / NOSE_LEN
    nose = y > NOSE_START
    return np.where(nose, r, HULL_R), np.where(nose, np.clip(dr, -6, 0), 0)


def env_reflection(rx, ry):
    """Sky above, dark ground below, two soft studio lights: what polished steel mirrors."""
    sky = mix(rgb(0.45, 0.47, 0.52), rgb(0.88, 0.9, 0.93), smoothstep(-0.05, 0.85, ry)[..., None])
    ground = mix(rgb(0.08, 0.07, 0.07), rgb(0.26, 0.23, 0.21), smoothstep(-1, -0.05, ry)[..., None])
    env = np.where((ry > -0.05)[..., None], sky, ground)
    softbox = np.exp(-((rx + 0.62) / 0.1) ** 2) * 0.75 + np.exp(-((rx - 0.42) / 0.06) ** 2) * 0.25
    return env + softbox[..., None]


def hex_tiles(x, y, size=1.0, seed=0):
    """Hex tile pattern in point units: (per-tile random value, gap mask)."""
    q = (x * math.sqrt(3) / 3 - y / 3) / size
    r = (2 * y / 3) / size
    cx, cz = q, r
    cy = -cx - cz
    rx, ry, rz = np.round(cx), np.round(cy), np.round(cz)
    dx, dy, dz = np.abs(rx - cx), np.abs(ry - cy), np.abs(rz - cz)
    fixx = (dx > dy) & (dx > dz)
    fixz = ~fixx & ~(dy > dz)
    rx = np.where(fixx, -ry - rz, rx)
    rz = np.where(fixz, -rx - ry, rz)
    fx, fz = cx - rx, cz - rz
    fy = -fx - fz
    dist = np.maximum(np.maximum(np.abs(fx), np.abs(fy)), np.abs(fz))
    gap = smoothstep(0.4, 0.5, dist)
    ident = _hash(rx.astype(np.int64) + 1000, rz.astype(np.int64) + 1000, 3, seed)
    return ident, gap


def polygon_mask(x, y, pts):
    inside = np.zeros_like(x, dtype=bool)
    n = len(pts)
    for i in range(n):
        x1, y1 = pts[i]
        x2, y2 = pts[(i + 1) % n]
        cond = ((y1 > y) != (y2 > y)) & (x < (x2 - x1) * (y - y1) / (y2 - y1 + 1e-12) + x1)
        inside ^= cond
    return inside


def edge_distance(x, y, pts):
    best = np.full_like(x, 1e9)
    n = len(pts)
    for i in range(n):
        x1, y1 = pts[i]
        x2, y2 = pts[(i + 1) % n]
        vx, vy = x2 - x1, y2 - y1
        t = np.clip(((x - x1) * vx + (y - y1) * vy) / (vx * vx + vy * vy), 0, 1)
        d = np.hypot(x - (x1 + t * vx), y - (y1 + t * vy))
        best = np.minimum(best, d)
    return best


def tile_surface(x, y, light_term, tint, seed):
    ident, gap = hex_tiles(x, y, 0.95, seed)
    base = np.array(tint)[None, None, :] * (0.8 + 0.45 * ident)[..., None]
    base = base * (1 - 0.6 * gap)[..., None]
    return base * (0.55 + 0.8 * np.clip(light_term, 0, 1))[..., None] + (np.clip(light_term, 0, 1) ** 14 * 0.12)[..., None]


def render_ship(skin_name, ss=2):
    cfg = SKINS[skin_name]
    x, y, W, H = ship_grid(ss)
    out = np.zeros((H, W, 3))
    alpha = np.zeros((H, W))

    def paint(mask, color):
        nonlocal out, alpha
        m = mask.astype(np.float64)
        out = out * (1 - m[..., None]) + color * m[..., None]
        alpha = alpha + m * (1 - alpha)

    tile_tint = cfg.get("tile_tint", (0.075, 0.078, 0.085))
    r, dr = hull_radius(y)

    # ---- flaps (swept fins; drawn first, hull overlaps the roots) ----
    for side in (-1, 1):
        r22 = float(hull_radius(np.array([22.0]))[0][0])
        r33 = float(hull_radius(np.array([33.0]))[0][0])
        fins = [
            [(side * (r22 - 0.5), 21.5), (side * 16.5, 24.5), (side * 14.0, 31.0), (side * (r33 - 0.5), 33.0)],
            [(side * (HULL_R - 0.5), -7.0), (side * 20.0, -14.0), (side * 22.0, -28.5), (side * (HULL_R - 0.5), -28.5)],
        ]
        for k, pts in enumerate(fins):
            m = polygon_mask(x, y, pts)
            span = np.clip((np.abs(x) - HULL_R) / 12, 0, 1)
            light_term = 0.55 + 0.25 * (-side) * 0.6 - 0.25 * span + 0.1 * (y - pts[0][1]) / 20
            if cfg.get("gold_flaps"):
                col = rgb(0.86, 0.64, 0.25)[None, None, :] * (0.45 + 0.7 * np.clip(light_term, 0, 1))[..., None]
            else:
                col = tile_surface(x, y, light_term, tile_tint, 7 + k + (side > 0) * 3)
            ed = edge_distance(x, y, pts)
            col = col + (smoothstep(0.45, 0.0, ed) * 0.22)[..., None]  # steel edge trim
            col = col * (1 - 0.35 * smoothstep(3, 0, np.abs(x) - HULL_R))[..., None]  # root occlusion
            paint(m, col)

    # ---- engine skirt + Raptors ----
    skirt_pts = [(-HULL_R, HULL_BOTTOM), (-11.0, -39.5), (11.0, -39.5), (HULL_R, HULL_BOTTOM)]
    skirt = polygon_mask(x, y, skirt_pts)
    sr = HULL_R + (HULL_BOTTOM - y) / 9.5 * 1.5
    snx = np.clip(x / np.maximum(sr, 1), -1, 1)
    snz = np.sqrt(np.clip(1 - snx ** 2, 0, 1))
    sl = np.clip(snx * LIGHT[0] + snz * LIGHT[2] - 0.2 * LIGHT[1], 0, 1)
    skirt_col = rgb(0.16, 0.16, 0.17)[None, None, :] * (0.4 + 0.9 * sl)[..., None] + (sl ** 30 * 0.2)[..., None]
    skirt_col = skirt_col * (0.9 + 0.2 * value_noise3(x * 3, y * 3, 0.1, seed=9))[..., None]
    paint(skirt, skirt_col)
    for bx in (-5.2, 0.0, 5.2):
        top, bot = -38.5, -45.0
        hw = 2.1 + (top - y) / (top - bot) * 1.3
        bell = (y < top) & (y > bot) & (np.abs(x - bx) < hw)
        bnx = np.clip((x - bx) / np.maximum(hw, 0.1), -1, 1)
        bl = np.clip(bnx * LIGHT[0] + np.sqrt(np.clip(1 - bnx ** 2, 0, 1)) * LIGHT[2], 0, 1)
        heat = smoothstep(top, bot, y)
        bell_col = mix(rgb(0.3, 0.27, 0.25), rgb(0.42, 0.3, 0.24), heat[..., None])
        bell_col = bell_col * (0.3 + 0.9 * bl)[..., None] + (bl ** 25 * 0.3)[..., None]
        paint(bell, bell_col)
        mouth = (np.abs(y - bot - 0.45) < 0.55) & (np.abs(x - bx) < hw - 0.3)
        paint(mouth, rgb(0.02, 0.02, 0.02))

    # ---- hull ----
    hull = (np.abs(x) < r) & (y > HULL_BOTTOM - 0.3) & (y < NOSE_START + NOSE_LEN)
    dent = value_noise3(x * 1.2, y * 0.35, 0.7, seed=201) - 0.5
    nx = np.clip(x / np.maximum(r, 1e-3) + 0.05 * dent, -1, 1)
    nz = np.sqrt(np.clip(1 - nx * nx, 0, 1))
    ny = -dr * nz
    nl = np.sqrt(nx * nx + ny * ny + nz * nz)
    nx, ny, nz = nx / nl, ny / nl, nz / nl
    ndl = nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]
    rx, ry = 2 * nz * nx, 2 * nz * ny
    hvec = LIGHT + np.array([0, 0, 1.0])
    hvec /= np.linalg.norm(hvec)
    spec = np.clip(nx * hvec[0] + ny * hvec[1] + nz * hvec[2], 0, 1) ** 90

    ring_y = np.arange(HULL_BOTTOM + 3.5, NOSE_START + 10, 6.5)
    ring_d = np.min(np.abs(y[..., None] - ring_y[None, None, :]), axis=-1)
    band = np.floor((y - HULL_BOTTOM) / 6.5)
    col_idx = np.floor((np.arcsin(np.clip(x / np.maximum(r, 1e-3), -1, 1)) + 2) * 2.2 + band * 0.5)
    panel_var = _hash((band * 31 + col_idx).astype(np.int64) + 100, 7, 2, 5) - 0.5
    brushed = value_noise3(x * 14, y * 0.3, 0.5, seed=181) - 0.5

    if cfg["metal"] is not None:
        metal = np.array(cfg["metal"])
        env = env_reflection(rx, ry)
        hull_col = env * metal * (0.85 + 0.16 * panel_var + 0.05 * brushed)[..., None]
        hull_col = hull_col * (0.6 + 0.4 * np.clip(ndl + 0.3, 0, 1))[..., None] + (spec * 0.85)[..., None]
    else:
        paint_c = np.array(cfg["paint"])
        env = env_reflection(rx, ry)
        hull_col = paint_c * (0.22 + 0.9 * np.clip(ndl, 0, 1))[..., None] + env * 0.1 + (spec * 0.6)[..., None]
        hull_col = hull_col * (0.97 + 0.04 * panel_var)[..., None]

    if cfg.get("dust"):
        dust = smoothstep(0.45, 0.75, fbm3(x * 0.6, y * 0.25, 0.4, 5, seed=191))
        hull_col = mix(hull_col, rgb(0.62, 0.36, 0.22) * (0.5 + 0.6 * np.clip(ndl, 0, 1))[..., None], (dust * 0.5)[..., None])

    weld = smoothstep(0.28, 0.0, ring_d)
    hull_col = hull_col * (1 - 0.3 * weld)[..., None]
    seam = np.abs(((np.arcsin(np.clip(x / np.maximum(r, 1e-3), -1, 1)) + 2) * 2.2 + band * 0.5) % 1 - 0.5) > 0.47
    hull_col = np.where((seam & (y < NOSE_START))[..., None], hull_col * 0.88, hull_col)

    # heat-shield tiles on the windward (right) half, jagged per-tile edge
    tile_id, _ = hex_tiles(x, y, 0.95, 11)
    if cfg["tiles"] == "all":
        tiled = hull
    else:
        tiled = hull & (x / np.maximum(r, 1e-3) > 0.05 + 0.22 * tile_id) & (y < NOSE_START + NOSE_LEN * 0.82)
    tcol = tile_surface(x, y, ndl + 0.15, tile_tint, 11)
    hull_col = np.where(tiled[..., None], tcol, hull_col)

    soot = smoothstep(-14, -30, y) * (0.5 + 0.5 * fbm3(x * 1.5, y * 0.3, 0.2, 4, seed=193))
    hull_col = hull_col * (1 - 0.5 * soot)[..., None]
    hull_col = hull_col * (0.45 + 0.55 * nz ** 0.5)[..., None]

    if cfg.get("accent") is not None:
        stripe = (np.abs(y - 6) < 0.8) & (hull if cfg["tiles"] == "all" else ~tiled)
        hull_col = np.where(stripe[..., None], np.array(cfg["accent"]) * (0.6 + 0.6 * np.clip(ndl + 0.3, 0, 1))[..., None], hull_col)
    if cfg.get("neon") is not None:
        hull_col = np.where(((ring_d < 0.22) & ~tiled)[..., None], np.array(cfg["neon"]), hull_col)

    paint(hull, hull_col)
    return to_image(out, alpha, ss)


LEG_X = (-3.0, 21.0)
LEG_Y = (-25.0, 3.0)


def render_leg(ss=2):
    """Right landing leg in hinge-relative points; foot center at (16.5, -22.0)."""
    x, y, W, H = ship_grid(ss, LEG_X, LEG_Y)
    out = np.zeros((H, W, 3))
    alpha = np.zeros((H, W))
    a0, a1 = np.array([0.0, 0.0]), np.array([15.5, -21.0])
    v = a1 - a0
    L = np.linalg.norm(v)
    t = np.clip(((x - a0[0]) * v[0] + (y - a0[1]) * v[1]) / (L * L), 0, 1)
    px, py = a0[0] + t * v[0], a0[1] + t * v[1]
    d = np.hypot(x - px, y - py)
    width = 1.35 - 0.35 * t
    strut = d < width
    across = ((x - px) * (-v[1]) + (y - py) * v[0]) / L / np.maximum(width, 1e-3)
    shade = np.clip(0.55 + 0.45 * np.sqrt(np.clip(1 - across ** 2, 0, 1)) - 0.25 * across, 0, 1.2)
    col = rgb(0.5, 0.51, 0.54)[None, None, :] * shade[..., None] + (shade ** 20 * 0.2)[..., None]
    out = np.where(strut[..., None], col, out)
    alpha = np.where(strut, 1.0, alpha)
    foot = (np.abs(x - 16.5) < 4.0) & (np.abs(y + 22.0) < 1.25)
    fshade = 0.7 + 0.5 * smoothstep(-23.25, -20.75, y)
    out = np.where(foot[..., None], rgb(0.16, 0.16, 0.18)[None, None, :] * fshade[..., None], out)
    alpha = np.where(foot, 1.0, alpha)
    return to_image(out, alpha, ss)


# ---------------------------------------------------------------------------

def jobs():
    return {
        "planet_moon": lambda: render_planet("moon", moon_surface),
        "planet_mars": lambda: render_planet("mars", mars_surface, atmosphere=((0.95, 0.6, 0.45), 0.35, 0.03)),
        "planet_earth": lambda: render_planet("earth", earth_surface, atmosphere=((0.35, 0.6, 1.0), 0.75, 0.05), light_wrap=0.08),
        "planet_jupiter": lambda: render_planet("jupiter", jupiter_surface, atmosphere=((0.9, 0.8, 0.65), 0.25, 0.03)),
        "planet_europa": lambda: render_planet("europa", europa_surface),
        "planet_phobos": lambda: render_planet("phobos", phobos_surface),
        "planet_saturn": render_saturn,
        "planet_sun": render_sun,
        "sky_stars": render_starfield,
        "ground_detail": render_ground,
        "ship_leg": render_leg,
        **{f"ship_{k}": (lambda k=k: render_ship(k)) for k in SKINS},
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--preview", default="")
    args = ap.parse_args()
    wanted = set(filter(None, args.only.split(",")))
    for name, fn in jobs().items():
        if wanted and name not in wanted:
            continue
        print(f"rendering {name}...", flush=True)
        img = fn()
        if args.preview:
            os.makedirs(args.preview, exist_ok=True)
            img.save(os.path.join(args.preview, f"{name}.png"))
            print(f"  preview {name} {img.size}")
        else:
            save_imageset(name, img)


if __name__ == "__main__":
    main()
