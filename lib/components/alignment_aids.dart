import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

const _levelOk = Color(0xFF5CE08A);
const _levelOff = Colors.white;

/// Descarrega os bytes da foto de referência.
Future<Uint8List> fetchBytes(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}');
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  } finally {
    client.close(force: true);
  }
}

/// Extrai os contornos da foto (filtro de Sobel) e devolve-os como uma imagem
/// transparente com linhas ciano, do mesmo formato que a foto original.
Future<ui.Image> buildEdgeImage(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: 540);
  final frame = await codec.getNextFrame();
  final source = frame.image;
  final w = source.width, h = source.height;
  final data = await source.toByteData(format: ui.ImageByteFormat.rawRgba);
  source.dispose();
  if (data == null) throw StateError('Imagem sem pixels');

  final pixels = await compute(
    _sobel,
    _SobelInput(data.buffer.asUint8List(), w, h),
  );

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
      pixels, w, h, ui.PixelFormat.rgba8888, completer.complete);
  return completer.future;
}

class _SobelInput {
  final Uint8List rgba;
  final int w, h;
  const _SobelInput(this.rgba, this.w, this.h);
}

Uint8List _sobel(_SobelInput input) {
  final w = input.w, h = input.h, src = input.rgba;

  // Cinzento, com um desfoque 3x3 para ignorar o ruído fino.
  final gray = Float32List(w * h);
  for (var i = 0; i < w * h; i++) {
    final p = i * 4;
    gray[i] = 0.299 * src[p] + 0.587 * src[p + 1] + 0.114 * src[p + 2];
  }
  final blur = Float32List(w * h);
  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      var sum = 0.0;
      for (var dy = -1; dy <= 1; dy++) {
        for (var dx = -1; dx <= 1; dx++) {
          sum += gray[(y + dy) * w + x + dx];
        }
      }
      blur[y * w + x] = sum / 9;
    }
  }

  final mag = Float32List(w * h);
  var maxMag = 1.0;
  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      final i = y * w + x;
      final gx = -blur[i - w - 1] -
          2 * blur[i - 1] -
          blur[i + w - 1] +
          blur[i - w + 1] +
          2 * blur[i + 1] +
          blur[i + w + 1];
      final gy = -blur[i - w - 1] -
          2 * blur[i - w] -
          blur[i - w + 1] +
          blur[i + w - 1] +
          2 * blur[i + w] +
          blur[i + w + 1];
      final m = math.sqrt(gx * gx + gy * gy);
      mag[i] = m;
      if (m > maxMag) maxMag = m;
    }
  }

  // Limiar por percentil: mantém só os ~8% de pixels com mais contraste.
  final hist = List<int>.filled(256, 0);
  for (final m in mag) {
    hist[(m / maxMag * 255).floor().clamp(0, 255)]++;
  }
  var keep = (w * h * 0.08).round(), cut = 255;
  for (var b = 255; b >= 0; b--) {
    keep -= hist[b];
    cut = b;
    if (keep <= 0) break;
  }
  final threshold = math.max(cut, 12) / 255 * maxMag;

  final out = Uint8List(w * h * 4);
  for (var y = 1; y < h - 1; y++) {
    for (var x = 1; x < w - 1; x++) {
      if (x < 4 || y < 4 || x >= w - 4 || y >= h - 4) continue;
      if (mag[y * w + x] < threshold) continue;
      // Engrossa a linha 1px para ficar visível por cima do vídeo.
      for (var dy = 0; dy <= 1; dy++) {
        for (var dx = 0; dx <= 1; dx++) {
          final p = ((y + dy) * w + x + dx) * 4;
          if (p + 3 >= out.length) continue;
          out[p] = 0x00;
          out[p + 1] = 0xE5;
          out[p + 2] = 0xFF;
          out[p + 3] = 0xFF;
        }
      }
    }
  }
  return out;
}

/// Contornos da foto anterior, desenhados na mesma caixa do preview.
class EdgeOverlay extends StatelessWidget {
  final ui.Image image;
  const EdgeOverlay({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return RawImage(
      image: image,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Modo cortina: a foto anterior à esquerda da linha, o vídeo à direita.
/// Arrastar a linha ajuda a casar pormenores entre as duas metades.
class SplitReference extends StatefulWidget {
  final Uint8List bytes;
  const SplitReference({super.key, required this.bytes});

  @override
  State<SplitReference> createState() => _SplitReferenceState();
}

class _SplitClipper extends CustomClipper<Rect> {
  final double fraction;
  _SplitClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_SplitClipper old) => old.fraction != fraction;
}

class _SplitReferenceState extends State<SplitReference> {
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final x = c.maxWidth * _split;
      return Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: ClipRect(
              clipper: _SplitClipper(_split),
              child: SizedBox.expand(
                child: Image.memory(widget.bytes,
                    fit: BoxFit.cover, gaplessPlayback: true),
              ),
            ),
          ),
          Positioned(
            left: x - 24,
            top: 0,
            bottom: 0,
            width: 48,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (d) => setState(() {
                _split = (_split + d.delta.dx / c.maxWidth).clamp(0.05, 0.95);
              }),
              child: Center(
                child: Container(
                  width: 3,
                  color: Colors.white,
                  // Acima do centro, para não ficar tapado pelo nível.
                  child: Align(
                    alignment: const Alignment(0, -0.25),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.swap_horiz,
                          size: 22, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Posição do telemóvel: inclinação lateral e para a frente/trás, em graus.
class Tilt {
  /// 0 = nivelado (também em paisagem); positivo = telemóvel rodado no
  /// sentido anti-horário.
  final double roll;

  /// 0 = telemóvel na vertical; positivo = câmera a apontar mais para baixo.
  final double pitch;
  const Tilt(this.roll, this.pitch);
}

/// Lê o acelerómetro e publica a inclinação já suavizada.
class TiltTracker {
  final value = ValueNotifier<Tilt>(const Tilt(0, 0));
  StreamSubscription<AccelerometerEvent>? _sub;
  bool available = true;
  bool _hasReading = false;

  TiltTracker() {
    try {
      _sub = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(_onEvent, onError: (_) => available = false);
    } catch (_) {
      available = false;
    }
  }

  bool get hasReading => _hasReading;

  void _onEvent(AccelerometerEvent e) {
    final angle = math.atan2(e.x, e.y) * 180 / math.pi;
    // Distância ao ângulo reto mais próximo (retrato ou paisagem).
    final roll = ((angle + 45) % 90 + 90) % 90 - 45;
    final pitch =
        math.atan2(e.z, math.sqrt(e.x * e.x + e.y * e.y)) * 180 / math.pi;
    final old = value.value;
    // Suaviza para a linha não tremer.
    value.value = _hasReading
        ? Tilt(old.roll * 0.7 + roll * 0.3, old.pitch * 0.7 + pitch * 0.3)
        : Tilt(roll, pitch);
    _hasReading = true;
  }

  void dispose() {
    _sub?.cancel();
    value.dispose();
  }
}

const _rollTolerance = 1.5;
const _pitchTolerance = 2.0;

/// Nível ao vivo. Sem alvo, ajuda a nivelar (linha verde = direito). Com alvo
/// (a inclinação da foto anterior) diz para onde inclinar para a repetir.
class LevelOverlay extends StatelessWidget {
  final TiltTracker tracker;
  final Tilt? target;

  /// Linha do nível e texto com os graus.
  final bool showAngles;

  /// Setas a indicar para onde inclinar.
  final bool showArrows;

  const LevelOverlay({
    super.key,
    required this.tracker,
    this.target,
    this.showAngles = true,
    this.showArrows = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!tracker.available) return const SizedBox.shrink();
    return IgnorePointer(
      child: ValueListenableBuilder<Tilt>(
        valueListenable: tracker.value,
        builder: (context, tilt, _) {
          final goalRoll = target?.roll ?? 0;
          final goalPitch = target?.pitch ?? 0;
          final dRoll = goalRoll - tilt.roll;
          final dPitch = goalPitch - tilt.pitch;
          final rollOk = dRoll.abs() < _rollTolerance;
          final pitchOk = dPitch.abs() < _pitchTolerance;
          final hints = <String>[
            if (!rollOk)
              dRoll > 0
                  ? 'Gire ${dRoll.abs().round()}° no sentido anti-horário'
                  : 'Gire ${dRoll.abs().round()}° no sentido horário',
            if (!pitchOk)
              dPitch > 0
                  ? 'Aponte ${dPitch.abs().round()}° mais para baixo'
                  : 'Aponte ${dPitch.abs().round()}° mais para cima',
          ];
          return Stack(
            fit: StackFit.expand,
            children: [
              if (showAngles)
                CustomPaint(
                  painter: _LevelPainter(tilt.roll, goalRoll, rollOk),
                ),
              if (showArrows) ...[
                // dPitch > 0: a câmera tem de apontar mais para baixo.
                if (!pitchOk)
                  Align(
                    alignment: dPitch > 0
                        ? const Alignment(0, 0.55)
                        : const Alignment(0, -0.55),
                    child: _DirectionArrow(
                      icon: dPitch > 0
                          ? Icons.keyboard_double_arrow_down
                          : Icons.keyboard_double_arrow_up,
                    ),
                  ),
                // dRoll > 0: rodar no sentido anti-horário.
                if (!rollOk)
                  Align(
                    alignment: dRoll > 0
                        ? const Alignment(-0.7, 0)
                        : const Alignment(0.7, 0),
                    child: _DirectionArrow(
                      icon: dRoll > 0 ? Icons.rotate_left : Icons.rotate_right,
                    ),
                  ),
                if (rollOk && pitchOk && target != null)
                  const Align(
                    alignment: Alignment(0, -0.55),
                    child: _DirectionArrow(
                        icon: Icons.check_circle_outline, ok: true),
                  ),
              ],
              if (showAngles)
                Align(
                  alignment: const Alignment(0, 0.35),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      hints.isEmpty
                          ? (target == null
                              ? 'Nivelado'
                              : 'Mesma inclinação da foto anterior')
                          : hints.join('\n'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: hints.isEmpty ? _levelOk : _levelOff,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LevelPainter extends CustomPainter {
  final double roll, goalRoll;
  final bool aligned;
  const _LevelPainter(this.roll, this.goalRoll, this.aligned);

  @override
  void paint(Canvas canvas, Size size) {
    final color = aligned ? _levelOk : _levelOff;
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Alvo: a linha fixa, inclinada como na foto anterior.
    final target = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(goalRoll * math.pi / 180);
    canvas.drawLine(const Offset(-90, 0), const Offset(-70, 0), target);
    canvas.drawLine(const Offset(70, 0), const Offset(90, 0), target);
    canvas.restore();

    // Linha móvel: o horizonte visto no ecrã roda no sentido do ângulo medido.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(roll * math.pi / 180);
    canvas.drawLine(const Offset(-60, 0), const Offset(-12, 0), paint);
    canvas.drawLine(const Offset(12, 0), const Offset(60, 0), paint);
    canvas.drawCircle(Offset.zero, 4, paint..style = PaintingStyle.stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LevelPainter old) =>
      old.roll != roll || old.goalRoll != goalRoll || old.aligned != aligned;
}

class _DirectionArrow extends StatelessWidget {
  final IconData icon;
  final bool ok;
  const _DirectionArrow({required this.icon, this.ok = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
        border: Border.all(color: ok ? _levelOk : _levelOff, width: 2),
      ),
      child: Icon(icon, size: 36, color: ok ? _levelOk : _levelOff),
    );
  }
}
