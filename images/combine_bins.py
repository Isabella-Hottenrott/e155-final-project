from pathlib import Path
import sys

# This script concatenates .bin files produced by convertimages.py
# It uses the same logical order as the images list in convertimages.py.

here = Path(__file__).resolve().parent

# If you want alphabetical order, set use_ordered=False
use_ordered = False

# Logical base names (keep in sync with convertimages.py)
ordered_names = ['paper.bin', 'rock.bin', 'scissors.bin', 'you_win.bin', 'you_lose.bin', 'tie.bin']

# Collect files
if use_ordered:
    files = [here / name for name in ordered_names if (here / name).exists()]
    # If any ordered files are missing, also append any other .bin files found
    found_set = {p.name for p in files}
    extra = sorted([p for p in here.glob('*.bin') if p.name not in found_set])
    files.extend(extra)
else:
    files = sorted(here.glob('*.bin'))

if not files:
    print('No .bin files found in', here)
    sys.exit(1)

output_path = here / 'combined.bin'

total_bytes = 0
with open(output_path, 'wb') as out:
    for p in files:
        size = p.stat().st_size
        print(f'Appending {p.name} ({size} bytes)')
        with open(p, 'rb') as f:
            data = f.read()
            out.write(data)
            total_bytes += len(data)

print(f'Wrote {total_bytes} bytes to {output_path}')
