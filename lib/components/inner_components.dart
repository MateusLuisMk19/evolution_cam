import 'dart:async';

import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/functions/format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Círculo escuro e translúcido para ícones por cima de fotografias.
class _Scrim extends StatelessWidget {
  final Widget child;
  final double size;
  const _Scrim({required this.child, this.size = 30});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: child,
      );
}

/// Etiqueta de texto por cima de fotografias (sempre sobre fundo escuro).
class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Moldura arredondada onde as fotografias são apresentadas.
class _PhotoFrame extends StatelessWidget {
  final double height;
  final Widget child;
  const _PhotoFrame({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        height: height,
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: child,
      ),
    );
  }
}

Widget _networkPhoto(String url, {BoxFit fit = BoxFit.cover, int? cacheWidth}) {
  return Image.network(
    url,
    fit: fit,
    gaplessPlayback: true,
    cacheWidth: cacheWidth,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Center(
        child: CircularProgressIndicator(
          value: progress.expectedTotalBytes != null
              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
              : null,
        ),
      );
    },
    errorBuilder: (context, error, stack) => Center(
      child: Icon(Icons.broken_image_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

/// Apresentação automática das fotos selecionadas, da mais antiga à mais nova.
class ShowChangesSlide extends StatefulWidget {
  /// Imagens por ordem cronológica. Cada item tem `id`, `url` e
  /// opcionalmente `createdAt` (DateTime).
  final List<dynamic> imageUrls;
  final int timerSeconds;
  final double? height;

  const ShowChangesSlide({
    Key? key,
    required this.imageUrls,
    this.timerSeconds = 2,
    this.height,
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
    final height = widget.height ?? MediaQuery.of(context).size.width;
    final images = widget.imageUrls;

    if (images.isEmpty) {
      return _PhotoFrame(
        height: height,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Selecione pelo menos uma foto para ver a evolução',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final index = _currentPage.clamp(0, images.length - 1);
    final current = images[index];
    final createdAt = current['createdAt'];

    return _PhotoFrame(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          KeyedSubtree(
            key: ValueKey(current['id']),
            child: _networkPhoto(current['url'], fit: BoxFit.contain),
          ),
          if (createdAt is DateTime)
            Positioned(
              top: 14,
              left: 14,
              child: _Pill(text: formatDate(createdAt)),
            ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (images.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
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
      ),
    );
  }
}

/// Compara a primeira e a última foto: arraste a linha para revelar.
class BeforeAfterSlider extends StatefulWidget {
  final Map<String, dynamic> before;
  final Map<String, dynamic> after;
  final double height;

  const BeforeAfterSlider({
    Key? key,
    required this.before,
    required this.after,
    required this.height,
  }) : super(key: key);

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _RevealClipper extends CustomClipper<Rect> {
  final double fraction;
  _RevealClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_RevealClipper old) => old.fraction != fraction;
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _fraction = 0.5;

  void _setFromDx(double dx, double width) =>
      setState(() => _fraction = (dx / width).clamp(0.0, 1.0));

  String _label(String prefix, Map<String, dynamic> image) {
    final d = image['createdAt'];
    return d is DateTime ? '$prefix · ${formatDate(d)}' : prefix;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _PhotoFrame(
      height: widget.height,
      child: LayoutBuilder(builder: (context, c) {
        final x = c.maxWidth * _fraction;
        return Semantics(
          label: 'Comparação entre a primeira e a última foto',
          value: '${(_fraction * 100).round()}% da foto de antes visível',
          increasedValue: '${((_fraction + 0.1).clamp(0, 1) * 100).round()}%',
          decreasedValue: '${((_fraction - 0.1).clamp(0, 1) * 100).round()}%',
          onIncrease: () =>
              setState(() => _fraction = (_fraction + 0.1).clamp(0.0, 1.0)),
          onDecrease: () =>
              setState(() => _fraction = (_fraction - 0.1).clamp(0.0, 1.0)),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) =>
                _setFromDx(d.localPosition.dx, c.maxWidth),
            onTapDown: (d) => _setFromDx(d.localPosition.dx, c.maxWidth),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _networkPhoto(widget.after['url'], fit: BoxFit.contain),
                ClipRect(
                  clipper: _RevealClipper(_fraction),
                  child:
                      _networkPhoto(widget.before['url'], fit: BoxFit.contain),
                ),
                Positioned(
                  left: x - 1.5,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 3, color: Colors.white),
                ),
                Positioned(
                  left: x - 24,
                  top: widget.height / 2 - 24,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 8),
                      ],
                    ),
                    child: Icon(Icons.swap_horiz,
                        color: scheme.onPrimary, size: 22),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: _Pill(text: _label('Antes', widget.before)),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: _Pill(text: _label('Depois', widget.after)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Grelha de fotos com seleção. É um sliver: tem de estar num CustomScrollView.
/// `images` por ordem cronológica; a grelha mostra as mais recentes primeiro.
class ImageGallery extends StatelessWidget {
  final List<dynamic> images;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final ValueChanged<Map<String, dynamic>> onDelete;

  const ImageGallery({
    Key? key,
    required this.images,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onOpen,
    required this.onDelete,
  }) : super(key: key);

  void _toggle(String id) {
    final next = {...selectedIds};
    next.contains(id) ? next.remove(id) : next.add(id);
    onSelectionChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final reversed = images.reversed.toList();
    final scheme = Theme.of(context).colorScheme;

    return SliverPadding(
      // margem inferior para a barra de ações não tapar as últimas fotos
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: reversed.length,
          (context, index) {
            final image = reversed[index] as Map<String, dynamic>;
            final id = image['id'] as String;
            final selected = selectedIds.contains(id);
            final createdAt = image['createdAt'];

            return ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _networkPhoto(image['url'], cacheWidth: 360),
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(onTap: () => onOpen(image)),
                    ),
                  ),
                  // Borda de seleção.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color:
                                selected ? scheme.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (createdAt is DateTime)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black87, Colors.transparent],
                            ),
                          ),
                          child: Text(
                            formatDate(createdAt),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  // Menu (alvo de toque de 48dp, círculo visível de 28dp).
                  Positioned(
                    top: -6,
                    left: -6,
                    child: PopupMenuButton<String>(
                      tooltip: 'Opções da foto',
                      padding: EdgeInsets.zero,
                      onSelected: (_) => onDelete(image),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading:
                                Icon(Icons.delete_outline, color: scheme.error),
                            title: Text('Excluir',
                                style: TextStyle(color: scheme.error)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: _Scrim(
                            size: 28,
                            child: Icon(Icons.more_vert,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Marcador de seleção.
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: selected ? 'Foto selecionada' : 'Selecionar foto',
                      child: InkResponse(
                        key: ValueKey('select-$id'),
                        onTap: () => _toggle(id),
                        radius: 24,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    selected ? scheme.primary : Colors.black45,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: selected
                                  ? Icon(Icons.check,
                                      size: 16, color: scheme.onPrimary)
                                  : null,
                            ),
                          ),
                        ),
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

/// Barra flutuante com as duas formas de juntar uma foto.
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
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          elevation: 8,
          color: scheme.surfaceContainerHigh,
          shadowColor: Colors.black54,
          shape: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: 'Galeria',
                  icon: Icons.add_photo_alternate_outlined,
                  variant: AppButtonVariant.tonal,
                  expand: false,
                  onPressed: onGalleryTap,
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Câmera',
                  icon: Icons.photo_camera_outlined,
                  expand: false,
                  onPressed: onCameraTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
