# Wava Chan
# Nov. 2025
# Convert images to 16-bit RGB565 binary files for embedded display and combine into 1 .bin file

from PIL import Image
import struct
from pathlib import Path
import sys

# If this script is inside the `images` folder, locate images relative to it.
here = Path(__file__).resolve().parent

# Input filenames (no leading slashes). The script will look for these in the same folder.
images = ['paper.png', 'rock_small.png', 'scissors.png', 'you_win.png', 'you_lose.png', 'tie.png']

# Load and convert to 16-bit RGB565
for name in images:
    input_path = here / name
    if not input_path.exists():
        print(f"Skipping: '{input_path}' not found", file=sys.stderr)
        continue

    try:
        img = Image.open(input_path).convert("RGB").resize((320, 240))
    except Exception as e:
        print(f"Failed to open '{input_path}': {e}", file=sys.stderr)
        continue

    pixels = img.load()

    output_path = input_path.with_suffix('.bin')
    with open(output_path, "wb") as f:
        for y in range(img.height):
            for x in range(img.width):
                r, g, b = pixels[x, y]

                # Convert 8-bit R,G,B to RGB565
                rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)

                # Write as big-endian (high byte first)
                f.write(struct.pack(">H", rgb565))


# img = Image.open(input_image).convert("RGB").resize((320, 240))
# pixels = img.load()

# with open(output_bin, "wb") as f:
#     for y in range(img.height):
#         for x in range(img.width):
#             r, g, b = pixels[x, y]

#             # Convert 8-bit R,G,B to RGB565
#             rgb565 = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)

#             # Write as big-endian (high byte first)
#             f.write(struct.pack(">H", rgb565))
