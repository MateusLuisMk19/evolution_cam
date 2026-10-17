import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:evolution_cam/components/alignment_aids.dart';
import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/components/camera_components.dart';
import 'package:evolution_cam/components/camera_grid.dart';
import 'package:evolution_cam/configs/camera_settings.dart';
import 'package:evolution_cam/functions/image_tools.dart';
import 'package:flutter/material.dart';

/// Foto tirada, com a posição do telemóvel nesse momento.
class CapturedPhoto {
  final File file;
  final double? tiltRoll, tiltPitch, zoom;
  const CapturedPhoto(this.file, {this.tiltRoll, this.tiltPitch, this.zoom});
}

/// Câmara com a foto anterior sobreposta para alinhar o enquadramento.
/// Devolve a foto tirada, ou `null` se o utilizador voltar.
class CameraOverlayScreen extends StatefulWidget {
  final String collectionId;
  final String? imagemAntesUrl;

  /// Posição do telemóvel na foto anterior (nula se não foi guardada).
  final double? refRoll, refPitch, refZoom;

  const CameraOverlayScreen({
    super.key,
    required this.collectionId,
    this.imagemAntesUrl,
    this.refRoll,
    this.refPitch,
    this.refZoom,
  });

  @override
  State<CameraOverlayScreen> createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen> {
  final _settings = CameraSettings();
  final _tilt = TiltTracker();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  String? _cameraError;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isBusy = false;
  double _baseZoom = 1.0;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 4.0;
  int _currentTimerValue = 0;
  bool _isCountingDown = false;
  Offset? _focusPoint;
  bool _showFocusPoint = false;

  Uint8List? _refBytes;
  ui.Image? _edgeImage;
  bool _refFailed = false;

  bool get _hasReference => widget.imagemAntesUrl != null;

  CameraDescription _pick(CameraLensDirection direction) => _cameras.firstWhere(
        (c) => c.lensDirection == direction,
        orElse: () => _cameras.first,
      );

  bool get _hasBothLenses =>
      _cameras.any((c) => c.lensDirection == CameraLensDirection.front) &&
      _cameras.any((c) => c.lensDirection == CameraLensDirection.back);

  @override
  void initState() {
    super.initState();
    _settings.load();
    _initializeCamera();
    _loadReference();
  }

  Future<void> _loadReference() async {
    final url = widget.imagemAntesUrl;
    if (url == null) return;
    try {
      final bytes = await fetchBytes(url);
      if (!mounted) return;
      setState(() => _refBytes = bytes);
      final edges = await buildEdgeImage(bytes);
      if (!mounted) {
        edges.dispose();
        return;
      }
      setState(() => _edgeImage = edges);
    } catch (_) {
      if (mounted) setState(() => _refFailed = true);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException('noCamera', 'Nenhuma câmera encontrada');
      }
      await _setupCamera(_pick(CameraLensDirection.back));
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _cameraError = e.code == 'CameraAccessDenied'
          ? 'Sem permissão para usar a câmera. Ative-a nas configurações do celular.'
          : 'Não foi possível abrir a câmera (${e.description ?? e.code}).');
    } catch (e) {
      if (!mounted) return;
      setState(() => _cameraError = 'Não foi possível abrir a câmera.');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    final previous = _controller;
    final controller = CameraController(camera, ResolutionPreset.high);
    _controller = controller;
    if (mounted) setState(() => _isCameraInitialized = false);
    await previous?.dispose();

    await controller.initialize();
    _minZoomLevel = await controller.getMinZoomLevel();
    _maxZoomLevel = await controller.getMaxZoomLevel();
    // Repete o zoom da foto anterior, se o conhecermos.
    final wanted = widget.refZoom;
    _currentZoomLevel =
        (wanted ?? _minZoomLevel).clamp(_minZoomLevel, _maxZoomLevel);
    if (wanted != null) await controller.setZoomLevel(_currentZoomLevel);
    _isFlashOn = false;

    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _toggleCamera() async {
    if (!_hasBothLenses) return;
    final isFront = !_isFrontCamera;
    setState(() => _isFrontCamera = isFront);
    try {
      await _setupCamera(_pick(
        isFront ? CameraLensDirection.front : CameraLensDirection.back,
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _cameraError = 'Não foi possível trocar de câmera.');
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !_isCameraInitialized) return;
    final mode = _isFlashOn ? FlashMode.off : FlashMode.torch;
    try {
      await controller.setFlashMode(mode);
      if (mounted) setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {
      // câmeras sem lanterna (ex.: frontal) ignoram o pedido
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (!_isCameraInitialized || controller == null || _isBusy) return;
    setState(() => _isBusy = true);

    try {
      final seconds = _settings.timer;
      for (var i = seconds; i >= 1; i--) {
        if (!mounted) return;
        setState(() {
          _currentTimerValue = i;
          _isCountingDown = true;
        });
        await Future.delayed(const Duration(seconds: 1));
      }
      if (mounted) setState(() => _isCountingDown = false);

      // A posição é lida mesmo antes do disparo, não depois.
      final tilt = _tilt.hasReading ? _tilt.value.value : null;
      final zoom = _currentZoomLevel;
      final photo = await controller.takePicture();
      var file = File(photo.path);
      if (_isFrontCamera) {
        // O preview da frontal é espelhado, a foto gravada não: espelha-a
        // para ficar como o utilizador a viu.
        try {
          file = await mirrorPhoto(file);
        } catch (_) {
          // se falhar, mantém-se a foto original
        }
      }
      if (!mounted) return;
      Navigator.pop(
        context,
        CapturedPhoto(
          file,
          tiltRoll: tilt?.roll,
          tiltPitch: tilt?.pitch,
          zoom: zoom,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _isCountingDown = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao tirar a foto. Tente de novo.')),
      );
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final controller = _controller;
    if (controller == null || !_isCameraInitialized) return;
    final zoom =
        (_baseZoom * details.scale).clamp(_minZoomLevel, _maxZoomLevel);
    controller.setZoomLevel(zoom);
    setState(() => _currentZoomLevel = zoom);
  }

  Future<void> _handleTapToFocus(TapUpDetails details, Size box) async {
    final controller = _controller;
    if (controller == null || !_isCameraInitialized) return;

    final point = Offset(
      details.localPosition.dx / box.width,
      details.localPosition.dy / box.height,
    );
    try {
      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);
      setState(() {
        _focusPoint = details.localPosition;
        _showFocusPoint = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _showFocusPoint = false);
    } catch (_) {
      // foco manual não suportado nesta câmera
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _edgeImage?.dispose();
    _tilt.dispose();
    _settings.dispose();
    super.dispose();
  }

  List<Widget> _reference() {
    switch (_settings.mode) {
      case RefMode.edges:
        final edges = _edgeImage;
        if (edges == null) return const [];
        return [
          IgnorePointer(
            child: Opacity(opacity: 0.9, child: EdgeOverlay(image: edges)),
          ),
        ];
      case RefMode.ghost:
        return [
          IgnorePointer(
            child: Opacity(
              opacity: _settings.ghostOpacity,
              child: Image.memory(_refBytes!, fit: BoxFit.cover),
            ),
          ),
        ];
      case RefMode.split:
        return [SplitReference(bytes: _refBytes!)];
    }
  }

  Widget _preview(CameraController controller) {
    // A foto anterior e o preview partilham a mesma caixa, por isso o
    // alinhamento visto no ecrã é o que fica na fotografia.
    final aspect = 1 / controller.value.aspectRatio;
    final target = widget.refRoll == null || widget.refPitch == null
        ? null
        : Tilt(widget.refRoll!, widget.refPitch!);
    return Center(
      child: AspectRatio(
        aspectRatio: aspect,
        child: LayoutBuilder(builder: (context, c) {
          final box = Size(c.maxWidth, c.maxHeight);
          return GestureDetector(
            onScaleStart: (_) => _baseZoom = _currentZoomLevel,
            onScaleUpdate: _handleScaleUpdate,
            onTapUp: (d) => _handleTapToFocus(d, box),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(controller),
                if (_hasReference && _refBytes != null) ..._reference(),
                if (_settings.grid)
                  IgnorePointer(
                    child: CustomPaint(painter: GridPainter()),
                  ),
                if (_settings.angles || _settings.arrows)
                  LevelOverlay(
                    tracker: _tilt,
                    target: target,
                    showAngles: _settings.angles,
                    showArrows: _settings.arrows,
                  ),
                if (_showFocusPoint && _focusPoint != null)
                  Positioned(
                    left: _focusPoint!.dx - 20,
                    top: _focusPoint!.dy - 20,
                    child: const FocusIndicator(),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String get _status {
    if (_refFailed) return 'Não foi possível carregar a foto anterior';
    final loading = _refBytes == null ||
        (_settings.mode == RefMode.edges && _edgeImage == null);
    return loading
        ? 'A preparar a foto anterior…'
        : 'Alinhe com a foto anterior';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_cameraError != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.no_photography_outlined,
                          color: Colors.white70, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        _cameraError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Voltar',
                        expand: false,
                        variant: AppButtonVariant.tonal,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isCameraInitialized && controller != null)
              _preview(controller)
            else
              const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            if (_cameraError == null) ...[
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_settings.timer > 0)
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 4),
                                Text('${_settings.timer} s',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        CamButton(
                          icon: Icons.settings_outlined,
                          tooltip: 'Definições da câmera',
                          onPressed: () => showCameraSettings(
                            context,
                            _settings,
                            hasReference: _hasReference,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_hasReference)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _status,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        CameraActionBar(
                          busy: _isBusy,
                          isFlashOn: _isFlashOn,
                          onCapture: _capturePhoto,
                          onToggleCamera: _toggleCamera,
                          onToggleFlash: _toggleFlash,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (_isCountingDown) TimerOverlay(seconds: _currentTimerValue),
          ],
        ),
      ),
    );
  }
}
