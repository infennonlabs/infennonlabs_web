#!/usr/bin/env python3
"""Render web/share-square.jpg (1200x1200) for search-result thumbnails.

Google crops thumbnails to a square, so this is a tight crop of the boy peeking over the book
from web/icons/infennon-source.png: everything inside the blue circle's black ring is kept,
the circle frame is dropped, and the corners are filled with the circle's own blue.
Run: python3 tool/brand/make_square.py
"""
import statistics
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "web/icons/infennon-source.png"
OUT = ROOT / "web/share-square.jpg"

src = Image.open(SRC).convert("RGB")
blue = tuple(int(statistics.median(src.getpixel(p)[i] for p in [(140, 500), (150, 420), (160, 600), (880, 500)])) for i in range(3))
cx, cy, r = 512, 500, 425   # interior of the circle, just inside the black ring
mask = Image.new("L", src.size, 0)
ImageDraw.Draw(mask).ellipse((cx - r, cy - r, cx + r, cy + r), fill=255)
canvas = Image.new("RGB", src.size, blue)
canvas.paste(src, (0, 0), mask)
square = canvas.crop((100, 92, 924, 916)).resize((1200, 1200), Image.LANCZOS)   # keeps hair top and book bottom
square.save(OUT, "JPEG", quality=88, optimize=True)
print(f"wrote {OUT} {square.size}")
