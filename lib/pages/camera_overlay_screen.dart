import 'dart:io';
import 'package:camera/camera.dart';
import 'package:evolution_cam/components/camera_components.dart';
import 'package:evolution_cam/components/camera_grid.dart';
import 'package:flutter/material.dart';

class CameraOverlayScreen extends StatefulWidget {
  final String collectionId;
  final String? imagemAntesUrl;

  const CameraOverlayScreen({
    Key? key,
    required this.collectionId,
    this.imagemAntesUrl,
  }) : super(key: key);

  @override
  _CameraOverlayScreenState createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isTimerOn = false;
  bool _isGridOn = false;
  bool _isOpacityOn = false;
  bool _isFrontCamera = false;
  double _currentZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 4.0;
  double _opacityLevel = 0.5;
  int _timerValue = 3;
  int _currentTimerValue = 0;
  bool _isCountingDown = false;
  Offset? _focusPoint;
  bool _showFocusPoint = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _setupCamera(_cameras!.first);
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    await _controller!.initialize();

    // Fetch zoom limits
    _minZoomLevel = await _controller!.getMinZoomLevel();
    _maxZoomLevel = await _controller!.getMaxZoomLevel();

    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _toggleCamera() async {
    if (_cameras != null) {
      final isFront = !_isFrontCamera;
      setState(() {
        _isFrontCamera = isFront;
      });
      _setupCamera(
        isFront ? _cameras!.last : _cameras!.first,
      );
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(newFlashMode);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  Future<void> _toggleTimer() async {
    setState(() {
      if (!_isTimerOn) {
        // Primeiro click - ativa o timer com valor inicial 3
        _isTimerOn = true;
        _timerValue = 3;
      } else {
        // Clicks subsequentes
        if (_timerValue == 3) {
          _timerValue = 5;
        } else if (_timerValue == 5) {
          _timerValue = 10;
        } else {
          // Reseta para o estado inicial
          _timerValue = 3;
          _isTimerOn = false;
        }
      }
    });
  }

  Future<void> _toggleGrid() async {
    setState(() {
      _isGridOn = !_isGridOn;
    });
  }

  Future<void> _toggleOpacity() async {
    setState(() {
      _isOpacityOn = !_isOpacityOn;
    });
  }

  void _handleOpacityChange(double value) {
    setState(() {
      _opacityLevel = value;
    });
  }

  Future<void> _capturePhoto() async {
    if (!_isCameraInitialized || _controller == null) return;

    try {
      if (_isTimerOn) {
        // Inicia contagem regressiva
        for (int i = _timerValue; i > 1; i--) {
          if (!mounted) return;

          // Atualiza o estado para mostrar o contador
          setState(() {
            _currentTimerValue = i;
            _isCountingDown = true;
          });

          await Future.delayed(Duration(seconds: 1));
        }

        // Remove o contador
        setState(() {
          _isCountingDown = false;
        });
      }

      final photo = await _controller!.takePicture();
      Navigator.pop(context, File(photo.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao capturar foto: $e')),
        );
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_controller != null) {
      double newZoomLevel = _currentZoomLevel * details.scale;
      newZoomLevel = newZoomLevel.clamp(_minZoomLevel, _maxZoomLevel);

      _controller!.setZoomLevel(newZoomLevel);
      setState(() {
        _currentZoomLevel = newZoomLevel;
      });
    }
  }

  Future<void> _handleTapToFocus(TapUpDetails details) async {
    if (_controller == null) return;

    final Size screenSize = MediaQuery.of(context).size;
    final Offset tapPosition = details.localPosition;

    // Converte a posição do toque para coordenadas normalizadas (0,0 a 1,1)
    final double x = tapPosition.dx / screenSize.width;
    final double y = tapPosition.dy / screenSize.height;

    // Define o ponto de foco
    try {
      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));

      // Atualiza a UI para mostrar o indicador de foco
      setState(() {
        _focusPoint = tapPosition;
        _showFocusPoint = true;
      });

      // Esconde o indicador após 2 segundos
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _showFocusPoint = false;
        });
      }
    } catch (e) {
      print('Erro ao definir ponto de foco: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onScaleUpdate: _handleScaleUpdate,
        onTapUp: _handleTapToFocus,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              if (_isCameraInitialized && _controller != null)
                CameraPreview(_controller!),
              if (widget.imagemAntesUrl != null)
                Positioned(
                  top: 0, // Alinha a imagem ao topo da tela
                  left: 0, // Alinha a imagem à esquerda da tela
                  right: 0, // Alinha a imagem à direita da tela
                  child: Opacity(
                    opacity: _opacityLevel, // Define a transparência da imagem
                    child: Image.network(
                      widget.imagemAntesUrl!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              // Exibe a grade se _isGridOn estiver ativado
              if (_isGridOn)
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridPainter(),
                  ),
                ),

              // Botão de configurações
              Positioned(
                top: 15,
                left: MediaQuery.of(context).size.width * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
                child: CameraSettingsBar(
                  isFlashOn: _isFlashOn,
                  onFlashToggle: _toggleFlash,
                  isTimerOn: _isTimerOn,
                  onTimerToggle: _toggleTimer,
                  isGridOn: _isGridOn,
                  onGridToggle: _toggleGrid,
                  isOpacityOn: _isOpacityOn,
                  onOpacityToggle: _toggleOpacity,
                  onOpacityChange: _handleOpacityChange,
                  opacityLevel: _opacityLevel,
                  timerValue: _timerValue,
                ),
              ),
              // Botões de ação da câmera
              Positioned(
                bottom: 25,
                left: MediaQuery.of(context).size.width * 0.01,
                right: MediaQuery.of(context).size.width * 0.01,
                child: CameraActionBar(
                  onCapture: _capturePhoto,
                  onToggleCamera: _toggleCamera,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),

              // Timer overlay
              if (_isCountingDown) TimerOverlay(seconds: _currentTimerValue),

              // Indicador de foco
              if (_showFocusPoint && _focusPoint != null)
                Positioned(
                  left: _focusPoint!.dx - 20,
                  top: _focusPoint!.dy - 20,
                  child: FocusIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
