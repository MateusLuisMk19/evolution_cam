import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class InnerCollestionScreen extends StatefulWidget {
  const InnerCollestionScreen({super.key});

  @override
  _InnerCollestionScreenState createState() => _InnerCollestionScreenState();
}

class _InnerCollestionScreenState extends State<InnerCollestionScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  late String collectionId;
  Map<String, dynamic>? collection;
  bool isLoading = true;

  File? _myImage;
  final _picker = ImagePicker();
  bool isImageSelected = false;
  final _imageNameController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isImageSelected = false;
    collectionId = ModalRoute.of(context)!.settings.arguments as String;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coleção não encontrado.')),
        );
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar o coleção: $error')),
      );
    });
  }

  Future<void> _pickImageCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _myImage = File(pickedFile.path);
        isImageSelected = true;
      });
    }
  }

  Future<void> _pickImageGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _myImage = File(pickedFile.path);
        isImageSelected = true;
      });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coleção não encontrada.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $error')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_myImage == null || _imageNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Por favor selecione uma imagem e adicione um nome')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final ref = _storage
          .ref()
          .child('colecoes')
          .child(collectionId)
          .child('image_${DateTime.now().toIso8601String()}.jpg');

      final uploadTask = ref.putFile(_myImage!);

      // Monitorar o progresso do upload
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Progress: ${snapshot.bytesTransferred}/${snapshot.totalBytes}');
      }, onError: (error) {
        print('Erro durante upload: $error');
      });

      // Aguardar conclusão do upload
      await uploadTask;

      // Obter o URL da imagem
      final url = await ref.getDownloadURL();

      // Atualizar o Firestore com o URL
      await FirebaseFirestore.instance
          .collection('colecoes')
          .doc(collectionId)
          .update({
        'imgs': FieldValue.arrayUnion([
          {
            'url': url,
            'name': _imageNameController.text,
            'position': collection!['imgs'].length,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          }
        ]), // Adiciona a URL ao array
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Recarrega os dados da coleção
      await _loadCollectionData();

      // Feedback ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload concluído!')),
      );

      setState(() {
        _myImage = null;
        _imageNameController.clear();
        isImageSelected = false;
      });
      setState(() {});
    } catch (e, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer upload: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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

    if (isImageSelected == true) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Adiciona imagem'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                children: [
                  Image.file(_myImage!),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      child: Column(
                        children: [
                          CustomTextField(
                              fieldController: _imageNameController,
                              placeholder: 'Nome da imagem',
                              radius: 10,
                              context: context,
                              marginBottom: 10,
                              marginTop: 10),
                          CustomBtn(
                            onPressedFunc: _uploadImage,
                            label: 'Adicionar',
                            context: context,
                            rgbBgColor: Theme.of(context).primaryColor,
                            rgbColor: Theme.of(context).cardColor,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (collection!['imgs'].isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(collection!['titulo']),
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
                  )),
            ),
            Card(
              margin: EdgeInsets.only(bottom: 50),
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
                          backgroundColor:
                              Theme.of(context).secondaryHeaderColor,
                        ),
                        iconSize: 30,
                        onPressed: _pickImageGallery,
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
                        onPressed: _pickImageCamera,
                        icon: Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(collection!['titulo']),
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
                  children: [
                    Expanded(
                      child: ListView.builder(
                        // Inverte a ordem da lista para exibir em ordem decrescente
                        itemCount: collection!['imgs'].length,
                        itemBuilder: (context, index) {
                          // Reverte a lista temporariamente
                          final reversedImgs =
                              collection!['imgs'].reversed.toList();
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Image.network(reversedImgs[index]['url']),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Card(
                                    color: Theme.of(context).cardColor,
                                    elevation: 2,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        reversedImgs[index]['createdAt']
                                            .toDate()
                                            .toString()
                                            .substring(0, 16),
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
                  ],
                )),
          ),
          // galeria de imagens
          Card(
            margin: EdgeInsets.only(bottom: 50),
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
                      onPressed: _pickImageGallery,
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
                      onPressed: _pickImageCamera,
                      icon: Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
          )

          // botão de adicionar imagem
          // botão de capturar imagem
        ],
      ),
    );
  }
}
