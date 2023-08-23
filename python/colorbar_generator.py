"""Generate colored bars for block tabs"""

from PIL import Image

from consts import COLORS

for color in COLORS.items():
    Image.new("RGB", (2, 16), color[1]).save(f"assets\\sprites\\color_bars\\{color[0]}.png")
