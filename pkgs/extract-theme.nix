{ writers, python3Packages, ... }:

writers.writePython3Bin "extract-theme" { libraries = [ python3Packages.pylette ]; } '' 
import sys
from Pylette import extract_colors

palette = extract_colors(image=sys.argv[1], palette_size=16)
with open(sys.argv[2] if len(sys.argv) > 2 else 'theme.yaml', 'w') as f:
    f.write('system: "base16"\n')
    f.write('name: "Residence"\n')
    f.write('variant: "custom"\n')
    f.write('palette:\n')
    for i, color in enumerate(palette):
        rgb = color.rgb
        hex_color = '#%02x%02x%02x' % (rgb[0], rgb[1], rgb[2])
        f.write(f'  base0{i:02d}: "{hex_color}"\n')
''
