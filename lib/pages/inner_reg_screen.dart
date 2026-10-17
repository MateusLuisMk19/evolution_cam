import 'dart:io';

import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/inner_components.dart';
import 'package:evolution_cam/functions/modal.dart';
import 'package:evolution_cam/pages/camera_overlay_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InnerCollestionScreen extends StatefulWidget {
  const InnerCollestionScreen({super.key});

  @override
  _InnerCollestionScreenState createState() => _InnerCollestionScreenState();
}

class _InnerCollestionScreenState extends State<InnerCollestionScreen> {
  final _service = CollectionService.instance;

  // Fotos escolhidas na galeria; só estas entram no slideshow.
  Set<String> _selectedIds = {};
  final Set<String> _knownIds = {};

  late String collectionId;
  bool _started = false;
  Map<String, dynamic>? collection;
  bool isLoading = true;

  final _picker = ImagePicker();
  bool isImageSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    collectionId = ModalRoute.of(context)!.settings.arguments as String;
    _loadCollectionData();
  }

  Future<void> _pickImageCamera() async {
    try {
      final File? photo = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraOverlayScreen(
            collectionId: collectionId,
            imagemAntesUrl: collection!['imgs'].isEmpty
                ? null
                : collection!['imgs'].last['url'],
          ),
        ),
      );

      if (photo != null && mounted) {
        await Navigator.of(context).pushNamed(
          '/addimage',
          arguments: {
            'collectionId': collectionId,
            'imagePath': photo.path,
          },
        );
        if (mounted) _loadCollectionData();
      }
    } catch (e) {
      if (mounted) myToast(context, 'Erro ao capturar foto: $e');
    }
  }

  Future<void> _deleteImage(Map<String, dynamic> image) async {
    try {
      await _service.deleteImage(image);

      if (!mounted) return;
      setState(() {
        collection!['imgs'].removeWhere((img) => img['id'] == image['id']);
        _syncSelection(collection);
      });

      myToast(context, 'Imagem excluída com sucesso.');
    } catch (e) {
      if (!mounted) return;
      myToast(context, 'Erro ao excluir imagem: ${errorMessage(e)}');
    }
  }

  Future<void> _pickImageGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      await Navigator.of(context).pushNamed(
        '/addimage',
        arguments: {
          'collectionId': collectionId,
          'imagePath': pickedFile.path,
        },
      );
      if (mounted) _loadCollectionData();
    }
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

  void _confirmDeleteImage(Map<String, dynamic> image) {
    modalConfirm(
      context: context,
      content: 'Deseja realmente excluir esta foto?',
      actions: () => _deleteImage(image),
    );
  }

  Future<void> _loadCollectionData() async {
    try {
      final data = await _service.get(collectionId);
      if (!mounted) return;
      setState(() {
        collection = data;
        isLoading = false;
        _syncSelection(data);
      });
      if (data == null) myToast(context, 'Coleção não encontrada.');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      myToast(context, 'Erro ao carregar dados: ${errorMessage(error)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Carregando...'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Erro'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(child: Text('Coleção não encontrada.')),
      );
    }

    if (collection!['imgs'].isEmpty) {
      return EmptyCollectionView(
        title: collection!['titulo'],
        onGalleryTap: _pickImageGallery,
        onCameraTap: _pickImageCamera,
      );
    }

    final List<dynamic> imgs = collection!['imgs'];
    final selected = imgs.where((i) => _selectedIds.contains(i['id'])).toList();
    final allSelected = _selectedIds.length == imgs.length;
    final noneSelected = _selectedIds.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(collection!['titulo']),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          RefreshIndicator(
            onRefresh: _loadCollectionData,
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                // Slideshow das fotos selecionadas
                SliverToBoxAdapter(
                  child: ShowChangesSlide(imageUrls: selected),
                ),
                // Barra de seleção
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${_selectedIds.length}/${imgs.length} selecionadas'),
                        Row(
                          children: [
                            Text('Todas'),
                            Checkbox(
                              tristate: true,
                              activeColor: Theme.of(context).primaryColor,
                              value: allSelected
                                  ? true
                                  : (noneSelected ? false : null),
                              onChanged: (_) {
                                setState(() {
                                  _selectedIds = allSelected
                                      ? {}
                                      : imgs
                                          .map<String>((i) => i['id'])
                                          .toSet();
                                });
                              },
                            ),
                          ],
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
                  onDelete: _confirmDeleteImage,
                ),
              ],
            ),
          ),
          // Botões de ação
          ActionButtons(
            onGalleryTap: _pickImageGallery,
            onCameraTap: _pickImageCamera,
          ),
        ],
      ),
    );
  }
}
