import 'package:evolution_cam/components/clickable_card.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShowChangesSlide extends StatefulWidget {
  /// Imagens a mostrar, por ordem cronológica. Cada item tem `id`, `url` e
  /// opcionalmente `createdAt` (DateTime).
  final List<dynamic> imageUrls;
  final int timerSeconds;

  const ShowChangesSlide({
    Key? key,
    required this.imageUrls,
    this.timerSeconds = 2,
  }) : super(key: key);

  @override
  State<ShowChangesSlide> createState() => _ShowChangesSlideState();
}

class _ShowChangesSlideState extends State<ShowChangesSlide> {
  Timer? _timer;
  int _currentPage = 0;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precache();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static List<Object?> _ids(List<dynamic> images) =>
      images.map((i) => i['id']).toList();

  @override
  void didUpdateWidget(ShowChangesSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Só reage a mudanças reais de conteúdo; reconstruções do pai não
    // devem fazer a apresentação voltar à primeira foto.
    if (!listEquals(_ids(widget.imageUrls), _ids(oldWidget.imageUrls))) {
      _currentPage = 0;
      _precache();
      _syncTimer();
    } else if (widget.timerSeconds != oldWidget.timerSeconds) {
      _syncTimer();
    }
  }

  void _precache() {
    for (final image in widget.imageUrls) {
      final url = image['url'] as String?;
      if (url != null && url.isNotEmpty) {
        precacheImage(NetworkImage(url), context, onError: (_, __) {});
      }
    }
  }

  // Um único temporizador, ativo só se estiver a tocar e houver >1 foto.
  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (!_isPlaying || widget.imageUrls.length < 2) return;
    _timer = Timer.periodic(Duration(seconds: widget.timerSeconds), (_) {
      if (!mounted) return;
      setState(() {
        _currentPage = (_currentPage + 1) % widget.imageUrls.length;
      });
    });
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    _syncTimer();
  }

  @override
  Widget build(BuildContext context) {
    final side = MediaQuery.of(context).size.width;
    final images = widget.imageUrls;

    if (images.isEmpty) {
      return SizedBox(
        height: side,
        width: side,
        child: Center(
          child: Text(
            'Seleciona pelo menos uma foto para ver a evolução',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final index = _currentPage.clamp(0, images.length - 1);
    final current = images[index];
    final createdAt = current['createdAt'];

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: side,
          width: side,
          child: Image.network(
            current['url'],
            key: ValueKey(current['id']),
            fit: BoxFit.contain,
            gaplessPlayback: true,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stack) =>
                Center(child: Icon(Icons.broken_image_outlined, size: 48)),
          ),
        ),
        if (createdAt is DateTime)
          Positioned(
            top: 12,
            left: 12,
            child: _Pill(text: createdAt.toString().substring(0, 10)),
          ),
        Positioned(
          bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (images.length > 1)
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.black54,
                    shape: CircleBorder(),
                    child: IconButton(
                      tooltip: _isPlaying ? 'Pausar' : 'Reproduzir',
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlay,
                    ),
                  ),
                ),
              _Pill(text: '${index + 1}/${images.length}'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

class ImageGallery extends StatelessWidget {
  /// Sliver: tem de ficar dentro de um CustomScrollView.
  /// Imagens por ordem cronológica; a grelha mostra as mais recentes primeiro.
  final List<dynamic> images;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final Function(Map<String, dynamic>) onDelete;

  const ImageGallery({
    Key? key,
    required this.images,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onDelete,
  }) : super(key: key);

  void _toggle(String id, bool selected) {
    final next = {...selectedIds};
    selected ? next.add(id) : next.remove(id);
    onSelectionChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final reversedImgs = images.reversed.toList();

    return SliverPadding(
      // margem inferior para os botões flutuantes não tapar as últimas fotos
      padding: EdgeInsets.fromLTRB(5, 0, 5, 110),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: reversedImgs.length,
          (context, index) {
            final image = reversedImgs[index];
            final id = image['id'] as String;
            final createdAt = image['createdAt'];

            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MyClickable(
                    onTap: () => Navigator.pushNamed(context, '/showimage',
                        arguments: image['url']),
                    items: [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                        onTap: () => onDelete(image),
                      ),
                    ],
                    child: Image.network(
                      image['url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Material(
                      color: Colors.black45,
                      shape: CircleBorder(),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: PopupMenuButton<String>(
                          tooltip: 'Opções',
                          padding: EdgeInsets.zero,
                          iconSize: 18,
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (_) => onDelete(image),
                          itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'delete', child: Text('Excluir')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Checkbox(
                      activeColor: Theme.of(context).primaryColor,
                      value: selectedIds.contains(id),
                      onChanged: (value) => _toggle(id, value ?? false),
                    ),
                  ),
                  if (createdAt is DateTime)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          createdAt.toString().substring(0, 16),
                          style: TextStyle(color: Colors.white, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const ActionButtons({
    Key? key,
    required this.onGalleryTap,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 4,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: SizedBox(
          width: 170,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 65,
                height: 60,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    elevation: 2,
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                  iconSize: 30,
                  onPressed: onGalleryTap,
                  icon: Icon(Icons.add_photo_alternate),
                ),
              ),
              SizedBox(
                width: 65,
                height: 60,
                child: IconButton.filled(
                  style: IconButton.styleFrom(
                    elevation: 2,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  iconSize: 30,
                  onPressed: onCameraTap,
                  icon: Icon(Icons.camera_alt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyCollectionView extends StatelessWidget {
  final String title;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const EmptyCollectionView({
    Key? key,
    required this.title,
    required this.onGalleryTap,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Coleção sem imagens.',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              ActionButtons(
                onGalleryTap: onGalleryTap,
                onCameraTap: onCameraTap,
              ),
            ],
          ),
        );
      }),
    );
  }
}
