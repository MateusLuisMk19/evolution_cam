import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/inner_components.dart';
import 'package:evolution_cam/pages/camera_overlay_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InnerCollestionScreen extends StatefulWidget {
  const InnerCollestionScreen({super.key});

  @override
  _InnerCollestionScreenState createState() => _InnerCollestionScreenState();
}

class _InnerCollestionScreenState extends State<InnerCollestionScreen> {
  final _firestore = FirebaseFirestore.instance;

  bool isAllSelected = true;

  late String collectionId;
  Map<String, dynamic>? collection;
  bool isLoading = true;

  final _picker = ImagePicker();
  bool isImageSelected = false;

  late List<dynamic> ImgsList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isImageSelected = false;
    collectionId = ModalRoute.of(context)!.settings.arguments as String;

    _loadCollectionData();

    _firestore.collection('colecoes').doc(collectionId).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          collection = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        myToast(context, 'Coleção não encontrada.');
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      myToast(context, 'Erro ao carregar dados: $error');
    });
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
        Navigator.of(context).pushNamed(
          '/addimage',
          arguments: {
            'collectionId': collectionId,
            'imagePath': photo.path,
          },
        );
      }
    } catch (e) {
      myToast(context, 'Erro ao capturar foto: $e');
    }
  }

  Future<void> _deleteImage(Map<String, dynamic> image) async {
    try {
      // Remove do Firestore primeiro
      await _firestore.collection('colecoes').doc(collectionId).update({
        'imgs': FieldValue.arrayRemove([image])
      });

      // Extrai a URL da imagem e tenta obter o caminho do Storage
      final String imageUrl = image['url'] as String;
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

      try {
        await storageRef.delete();
      } catch (storageError) {
        print('Erro ao deletar arquivo do storage: $storageError');
      }

      // Atualiza a UI
      setState(() {
        collection!['imgs'].removeWhere((img) => img['url'] == image['url']);
        ImgsList = collection!['imgs'].toList(); // Atualiza a lista do slide
      });

      myToast(context, 'Imagem excluída com sucesso.');
    } catch (e) {
      print('Erro ao excluir imagem: $e');
      myToast(context, 'Erro ao excluir imagem: $e');
    }
  }

  Future<void> _pickImageGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Navigator.of(context).pushNamed(
        '/addimage',
        arguments: {
          'collectionId': collectionId,
          'imagePath': pickedFile.path,
        },
      );
    }
  }

  Future<void> _loadCollectionData() async {
    try {
      final snapshot =
          await _firestore.collection('colecoes').doc(collectionId).get();
      if (snapshot.exists) {
        setState(() {
          collection = snapshot.data() as Map<String, dynamic>;
        });
      } else {
        myToast(context, 'Coleção não encontrada.');
      }
    } catch (error) {
      myToast(context, 'Erro ao carregar dados: $error');
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

    ImgsList = collection!['imgs'].toList();

    return ScaffoldMessenger(
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(collection!['titulo']),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  // Slideshow no topo
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    color: Colors.transparent,
                    child: ShowChangesSlide(
                      imageUrls: ImgsList,
                    ),
                  ),
                  // Galeria de imagens
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Column(
                        children: [
                          // Menu bar (opcional)
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Card(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Menu bar'),
                                  Row(
                                    children: [
                                      Text('All'),
                                      Checkbox(
                                        activeColor:
                                            Theme.of(context).primaryColor,
                                        value: isAllSelected,
                                        onChanged: (e) {
                                          setState(() {
                                            isAllSelected = e!;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          // Lista de imagens
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: ImageGallery(
                                images: collection!['imgs'],
                                onDelete: _deleteImage,
                                selectAll: isAllSelected,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Botões de ação
              ActionButtons(
                onGalleryTap: _pickImageGallery,
                onCameraTap: _pickImageCamera,
              ),
            ],
          ),
        );
      }),
    );
  }
}
