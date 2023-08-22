"""Generate the base sprites for block types"""

from PIL import Image, ImageDraw

from consts import COLORS


def generate_block(_type, upper_indent=True):
    """Generate a base block image"""
    event_im = Image.new("RGBA", (200, 60), tuple(list(COLORS[_type]) + [0]))
    event_draw = ImageDraw.Draw(event_im)
    event_draw.rounded_rectangle(
        ((0, 0), (200, 50)),
        12,
        COLORS[_type],
        corners=(False, False, False, False)
        if upper_indent
        else (True, True, False, False),
    )
    event_draw.rounded_rectangle(
        ((20, 50), (50, 60)), 5, COLORS[_type], corners=(False, False, True, True)
    )
    if upper_indent:
        event_draw.rounded_rectangle(
            ((20, 0), (50, 10)),
            5,
            tuple(list(COLORS[_type]) + [0]),
            corners=(False, False, True, True),
        )
    event_im.save(f"assets\\sprites\\base_blocks\\{_type}.png")


for block_type in COLORS:
    generate_block(block_type, False if block_type == "events" else True)
