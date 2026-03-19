import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Green base background.
  img.fill(image, color: img.ColorRgb8(11, 74, 48));

  final center = size ~/ 2;

  // Gold outer ring.
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: 420,
    color: img.ColorRgb8(217, 180, 74),
  );
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: 394,
    color: img.ColorRgb8(11, 74, 48),
  );

  // Inner ring for depth.
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: 362,
    color: img.ColorRgb8(242, 220, 140),
  );
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: 354,
    color: img.ColorRgb8(11, 74, 48),
  );

  // Crescent moon (gold circle minus green circle).
  img.fillCircle(
    image,
    x: center,
    y: 250,
    radius: 64,
    color: img.ColorRgb8(217, 180, 74),
  );
  img.fillCircle(
    image,
    x: center + 22,
    y: 250,
    radius: 56,
    color: img.ColorRgb8(11, 74, 48),
  );

  // Open book pages.
  img.fillRect(
    image,
    x1: center - 250,
    y1: 420,
    x2: center - 8,
    y2: 705,
    color: img.ColorRgb8(226, 189, 90),
  );
  img.fillRect(
    image,
    x1: center + 8,
    y1: 420,
    x2: center + 250,
    y2: 705,
    color: img.ColorRgb8(245, 224, 161),
  );

  // Page top curve effect.
  img.fillCircle(
    image,
    x: center - 130,
    y: 420,
    radius: 120,
    color: img.ColorRgb8(226, 189, 90),
  );
  img.fillCircle(
    image,
    x: center + 130,
    y: 420,
    radius: 120,
    color: img.ColorRgb8(245, 224, 161),
  );

  // Spine.
  img.drawLine(
    image,
    x1: center,
    y1: 400,
    x2: center,
    y2: 720,
    color: img.ColorRgb8(185, 141, 38),
  );

  // Minimal page lines.
  for (var i = 0; i < 4; i++) {
    final y = 500 + (i * 42);
    img.drawLine(
      image,
      x1: center - 215,
      y1: y,
      x2: center - 35,
      y2: y,
      color: img.ColorRgb8(248, 234, 180),
    );
    img.drawLine(
      image,
      x1: center + 35,
      y1: y,
      x2: center + 215,
      y2: y,
      color: img.ColorRgb8(207, 160, 58),
    );
  }

  final outDir = Directory('assets/icon');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final outFile = File('assets/icon/app_icon.png');
  outFile.writeAsBytesSync(img.encodePng(image, level: 6));

  stdout.writeln('Generated assets/icon/app_icon.png');
}
