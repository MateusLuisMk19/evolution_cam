import 'dart:math' as math;

import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/components/feedback.dart';
import 'package:evolution_cam/components/inner_components.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/pages/camera_overlay_screen.dart';
import 'package:evolution_cam/pages/set_collection_screen.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum _ViewMode { slideshow, compare }

class InnerCollectionScreen extends StatefulWidget {
  const InnerCollectionScreen({super.key});

  @override
  State<InnerCollectionScreen> createState() => _InnerCollectionScreenState();
}

class _InnerCollectionScreenState extends State<InnerCollectionScreen> {
  final _service = CollectionService.instance;
  final _picker = ImagePicker();

  late String collectionId;
  bool _started = false;
  Map<String, dynamic>? collection;
  bool isLoading = true;

  // Fotos escolhidas na grelha; só estas entram na apresentação/comparação.
  Set<String> _selectedIds = {};
  final Set<String> _knownIds = {};
  _ViewMode _mode = _ViewMode.slideshow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    collectionId = ModalRoute.of(context)!.settings.arguments as String;
    _load();
  }

  // Fotos novas entram selecionadas; as que desapareceram saem da seleção.
  void _syncSelection(Map<String, dynamic>? data) {
    final ids = ((data?['imgs'] as List?) ?? const [])
        .map<String>((i) => i['id'] as String)
        .toSet();
    _selectedIds = {
      ..._selectedIds.intersection(ids),
      ...ids.difference(_knownIds),
    };
    _knownIds
      ..clear()
      ..addAll(ids);
  }

  Future<void> _load() async {
    try {
      final data = await _service.get(collectionId);
      if (!mounted) return;
      setState(() {
        collection = data;
        isLoading = false;
        _syncSelection(data);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showAppSnack(context, 'Erro ao carregar dados: ${errorMessage(error)}',
          error: true);
    }
  }

  Future<void> _addFromCamera() async {
    try {
      final imgs = collection!['imgs'] as List;
      final last = imgs.isEmpty ? null : imgs.last as Map<String, dynamic>;
      final CapturedPhoto? photo = await Navigator.push<CapturedPhoto>(
        context,
        MaterialPageRoute(
          builder: (context) => CameraOverlayScreen(
            collectionId: collectionId,
            imagemAntesUrl: last?['url'] as String?,
            refRoll: last?['tiltRoll'] as double?,
            refPitch: last?['tiltPitch'] as double?,
            refZoom: last?['zoom'] as double?,
          ),
        ),
      );
      if (photo == null || !mounted) return;
      await _review(photo.file.path, photo);
    } catch (e) {
      if (mounted) {
        showAppSnack(context, 'Erro ao capturar foto: ${errorMessage(e)}',
            error: true);
      }
    }
  }

  Future<void> _addFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2400,
      imageQuality: 88,
    );
    if (picked == null || !mounted) return;
    await _review(picked.path);
  }

  Future<void> _review(String path, [CapturedPhoto? shot]) async {
    await Navigator.of(context).pushNamed('/addimage', arguments: {
      'collectionId': collectionId,
      'imagePath': path,
      'tiltRoll': shot?.tiltRoll,
      'tiltPitch': shot?.tiltPitch,
      'zoom': shot?.zoom,
    });
    if (mounted) _load();
  }

  Future<void> _deleteImage(Map<String, dynamic> image) async {
    final ok = await confirmDialog(
      context,
      title: 'Excluir foto?',
      message: 'Esta foto será apagada para sempre.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await _service.deleteImage(image);
      if (!mounted) return;
      setState(() {
        (collection!['imgs'] as List)
            .removeWhere((img) => img['id'] == image['id']);
        _syncSelection(collection);
      });
      showAppSnack(context, 'Foto excluída');
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Erro ao excluir foto: ${errorMessage(e)}',
          error: true);
    }
  }

  Future<void> _editCollection() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SetCollectionScreen(collectionId: collectionId),
      ),
    );
    if (changed == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.folder_off_outlined,
          title: 'Coleção não encontrada',
          message: 'Ela pode ter sido excluída. Volte e atualize a lista.',
        ),
      );
    }

    final List<dynamic> imgs = collection!['imgs'];
    final title = collection!['titulo'] as String;

    final appBar = AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        IconButton(
          tooltip: 'Editar coleção',
          icon: const Icon(Icons.edit_outlined),
          onPressed: _editCollection,
        ),
      ],
    );

    if (imgs.isEmpty) {
      return Scaffold(
        appBar: appBar,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const EmptyState(
              icon: Icons.add_a_photo_outlined,
              title: 'Ainda sem fotos',
              message:
                  'Tire a primeira foto: ela passa a ser a referência para alinhar as seguintes.',
            ),
            ActionButtons(
              onGalleryTap: _addFromGallery,
              onCameraTap: _addFromCamera,
            ),
          ],
        ),
      );
    }

    final selected = imgs.where((i) => _selectedIds.contains(i['id'])).toList();
    final allSelected = _selectedIds.length == imgs.length;
    final viewerHeight = math.min(
      (MediaQuery.of(context).size.width - 40) * 1.15,
      MediaQuery.of(context).size.height * 0.48,
    );

    Widget viewer;
    if (_mode == _ViewMode.compare) {
      viewer = selected.length >= 2
          ? BeforeAfterSlider(
              before: selected.first,
              after: selected.last,
              height: viewerHeight,
            )
          : Container(
              height: viewerHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: const Text(
                'Selecione pelo menos 2 fotos para comparar o antes e o depois',
                textAlign: TextAlign.center,
              ),
            );
    } else {
      viewer = ShowChangesSlide(imageUrls: selected, height: viewerHeight);
    }

    return Scaffold(
      appBar: appBar,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          RefreshIndicator(
            onRefresh: _load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                collection!['categoria'] as String,
                                style: text.labelMedium?.copyWith(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const Spacer(),
                            SegmentedButton<_ViewMode>(
                              showSelectedIcon: false,
                              style: SegmentedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              segments: const [
                                ButtonSegment(
                                  value: _ViewMode.slideshow,
                                  icon: Icon(Icons.slideshow, size: 18),
                                  label: Text('Evolução'),
                                ),
                                ButtonSegment(
                                  value: _ViewMode.compare,
                                  icon: Icon(Icons.compare, size: 18),
                                  label: Text('Comparar'),
                                ),
                              ],
                              selected: {_mode},
                              onSelectionChanged: (s) =>
                                  setState(() => _mode = s.first),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        viewer,
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedIds.length} de ${imgs.length} selecionadas',
                            style: text.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _selectedIds = allSelected
                                ? {}
                                : imgs.map<String>((i) => i['id']).toSet();
                          }),
                          child:
                              Text(allSelected ? 'Limpar' : 'Selecionar todas'),
                        ),
                      ],
                    ),
                  ),
                ),
                ImageGallery(
                  images: imgs,
                  selectedIds: _selectedIds,
                  onSelectionChanged: (ids) =>
                      setState(() => _selectedIds = ids),
                  onOpen: (image) => Navigator.pushNamed(
                    context,
                    '/showimage',
                    arguments: image['url'],
                  ),
                  onDelete: _deleteImage,
                ),
              ],
            ),
          ),
          ActionButtons(
            onGalleryTap: _addFromGallery,
            onCameraTap: _addFromCamera,
          ),
        ],
      ),
    );
  }
}
