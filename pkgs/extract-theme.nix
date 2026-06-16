{ writers, python3Packages, ... }:

let
  # Override Pylette to disable tests, which require additional dependencies and are not needed for the binary
  pyletteNoTests = python3Packages.pylette.overridePythonAttrs (_: {
    doCheck = false;
  });
in

# Define a Python script to extract a color palette from an image and write it in a Base16 theme format
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

      # Always output 16 colors, padding with the last color if necessary
      for i in range(16):
          if i < len(palette):
              color = palette[i]
              rgb = color.rgb
          elif len(palette) > 0:
              color = palette[-1]
              rgb = color.rgb
          else:
              rgb = (0, 0, 0)

          hex_color = '#%02x%02x%02x' % (rgb[0], rgb[1], rgb[2])
          index_as_hex = hex(i)[2:].zfill(2).upper()
          # Use uppercase for base16 compatibility (e.g. base0A)
          theme_file.write(f'base{index_as_hex}: "{hex_color}"\n')
''
