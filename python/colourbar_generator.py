"""Generate colored bars for block tabs"""

from PIL import Image

colors = {
    "events": (0x22, 0x91, 0x30),
    "operators": (0xe5, 0xd0, 0x40),
    "actions": (0xb0, 0x31, 0x1f),
    "control": (0x47, 0x62, 0xde),
    "variables": (0x3d, 0xb0, 0xed),
    "keys": (0xd4, 0x6d, 0x1d),
}

for color in colors.items():
    Image.new("RGB", (2, 16), color[1]).save(f"assets\\sprites\\color_bars\\{color[0]}.png")
