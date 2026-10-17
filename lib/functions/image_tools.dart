import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Espelha a foto na horizontal e reduz-a a 2400px no lado maior. A câmera
/// frontal mostra o preview espelhado mas grava a foto sem espelho; assim a
/// foto fica igual ao que o utilizador viu ao enquadrar.
Future<File> mirrorPhoto(File source) async {
  final bytes = await source.readAsBytes();
  final out = await compute(_mirror, bytes);
  final target = File('${source.path}.espelhada.jpg');
  await target.writeAsBytes(out, flush: true);
  return target;
}

Uint8List _mirror(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  var image = img.bakeOrientation(decoded);
  const maxSide = 2400;
  if (image.width > maxSide || image.height > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide)
        : img.copyResize(image, height: maxSide);
  }
  image = img.flipHorizontal(image);
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}
