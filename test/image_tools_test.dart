import 'dart:io';

import 'package:evolution_cam/functions/image_tools.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('mirrorPhoto espelha na horizontal e reduz fotos grandes', () async {
    final dir = await Directory.systemTemp.createTemp('mirror_test');
    addTearDown(() => dir.delete(recursive: true));

    // Esquerda vermelha, direita azul; 3000px de largura para testar o limite.
    final source = img.Image(width: 3000, height: 1000);
    img.fill(source, color: img.ColorRgb8(0, 0, 255));
    img.fillRect(source,
        x1: 0, y1: 0, x2: 1499, y2: 999, color: img.ColorRgb8(255, 0, 0));
    final file = File('${dir.path}/foto.jpg')
      ..writeAsBytesSync(img.encodeJpg(source, quality: 95));

    final mirrored = await mirrorPhoto(file);
    final result = img.decodeJpg(await mirrored.readAsBytes())!;

    expect(result.width, 2400);
    expect(result.height, 800);
    final left = result.getPixel(100, 400);
    final right = result.getPixel(2300, 400);
    expect(left.b > 200 && left.r < 60, isTrue, reason: 'esquerda azul');
    expect(right.r > 200 && right.b < 60, isTrue, reason: 'direita vermelha');
  });
}
