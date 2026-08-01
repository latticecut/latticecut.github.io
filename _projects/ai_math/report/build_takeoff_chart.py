from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "cumulative_takeoff_jan2025.source.png"
OUTPUT = ROOT / "cumulative_takeoff_jan2025.png"

# Original chart series and their microsite-theme replacements.
SERIES = (
    ((68, 134, 137), (42, 122, 226)),   # teal bars -> link blue
    ((23, 54, 93), (66, 66, 66)),       # navy cumulative line -> charcoal
)


def blended(base: tuple[int, int, int], opacity: float) -> tuple[float, float, float]:
    return tuple(255 - opacity * (255 - component) for component in base)


def recolor(pixel: tuple[int, int, int]) -> tuple[int, int, int]:
    best: tuple[float, tuple[int, int, int]] | None = None
    for old, new in SERIES:
        opacity = sum((255 - pixel[i]) / (255 - old[i]) for i in range(3)) / 3
        opacity = max(0.0, min(1.0, opacity))
        expected = blended(old, opacity)
        error = sum((pixel[i] - expected[i]) ** 2 for i in range(3)) ** 0.5
        if opacity > 0.08 and error < 8:
            replacement = tuple(round(value) for value in blended(new, opacity))
            if best is None or error < best[0]:
                best = (error, replacement)
    return best[1] if best else pixel


image = Image.open(SOURCE).convert("RGB")
image.putdata([recolor(pixel) for pixel in image.get_flattened_data()])
image.save(OUTPUT, optimize=True)
