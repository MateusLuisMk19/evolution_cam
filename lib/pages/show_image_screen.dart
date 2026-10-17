import 'package:flutter/material.dart';

/// Visualizador de uma foto: zoom por pinça e duplo toque.
class ShowImageScreen extends StatefulWidget {
  const ShowImageScreen({Key? key}) : super(key: key);

  @override
  State<ShowImageScreen> createState() => _ShowImageScreenState();
}

class _ShowImageScreenState extends State<ShowImageScreen> {
  late String imageUrl;
  final TransformationController _controller = TransformationController();
  Offset _doubleTapPosition = Offset.zero;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    imageUrl = ModalRoute.of(context)!.settings.arguments as String;
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      // Zoom de 2,5x no ponto tocado.
      final p = _doubleTapPosition;
      _controller.value = Matrix4.identity()
        ..translate(-p.dx * 1.5, -p.dy * 1.5)
        ..scale(2.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onDoubleTapDown: (d) => _doubleTapPosition = d.localPosition,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.8,
              maxScale: 5,
              child: Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_outlined,
                            size: 48, color: Colors.white70),
                        SizedBox(height: 12),
                        Text('Não foi possível carregar a imagem',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton.filled(
                  tooltip: 'Fechar',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    fixedSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
