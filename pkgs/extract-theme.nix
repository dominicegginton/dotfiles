{ writers, python3Packages, ... }:

let
  pyletteNoTests = python3Packages.pylette.overridePythonAttrs (_: {
    doCheck = false;
  });
in

writers.writePython3Bin "extract-theme" { libraries = [ pyletteNoTests ]; } ''
  import argparse
  from Pylette import extract_colors

  parser = argparse.ArgumentParser(description="Extract a color palette.")
  parser.add_argument("image", help="Path to the input image file.")
  parser.add_argument("output", default="theme.yaml", help="Output path.")
  parser.add_argument("--colors", type=int, default=16, help="Number of colors.")
  args = parser.parse_args()

  palette = extract_colors(
      image=args.image,
      palette_size=args.colors,
      resize=True,
      sort_mode="frequency",
  )

  with open(args.output, "w") as theme_file:
      theme_file.write('system: "base16"\n')
      theme_file.write('name: "Residence"\n')
      theme_file.write('author: "Dominic Egginton"\n')
      theme_file.write('variant: "custom"\n')
      theme_file.write('palette:\n')
      for i, color in list(enumerate(palette)):
          rgb = color.rgb
          hex_color = '#%02x%02x%02x' % (rgb[0], rgb[1], rgb[2])
          index_as_hex = hex(i)[2:].zfill(2)
          last_two_digits = hex(i)[2:].zfill(2)[-2:]
          last_two_digits_as_upper = (hex(i)[2:].zfill(2)[-2:]).upper()
          theme_file.write(f'  base{last_two_digits_as_upper}: "{hex_color}"\n')
''
