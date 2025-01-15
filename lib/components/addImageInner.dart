import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Addimageinner extends StatefulWidget {
  const Addimageinner({super.key});

  @override
  _AddimageinnerState createState() => _AddimageinnerState();
}

class _AddimageinnerState extends State<Addimageinner> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  late String collectionId;
  Map<String, dynamic>? collection;
  bool isLoading = true;

  File? _myImage;
  bool isImageSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    collectionId = args['collectionId'];
    final imagePath = args['imagePath'];
    _myImage = File(imagePath);

    // Carregar os dados da coleção
    _loadCollectionData();
  }

  Future<void> _loadCollectionData() async {
    try {
      final snapshot =
          await _firestore.collection('colecoes').doc(collectionId).get();
      if (snapshot.exists) {
        setState(() {
          collection = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
          isImageSelected = true;
        });
      } else {
        throw Exception('Coleção não encontrada');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados da coleção')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_myImage == null || collection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor aguarde o carregamento dos dados')),
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

      await uploadTask;
      final url = await ref.getDownloadURL();

      // Inicializa o array imgs se não existir
      if (!collection!.containsKey('imgs')) {
        collection!['imgs'] = [];
      }

      await _firestore.collection('colecoes').doc(collectionId).update({
        'imgs': FieldValue.arrayUnion([
          {
            'url': url,
            'name': 'image_${DateTime.now().toIso8601String()}.jpg',
            'position': collection!['imgs'].length,
            'createdAt': Timestamp.fromDate(DateTime.now()),
          }
        ]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload concluído!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Erro durante o upload: $e');
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
    } else {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      child: Column(
                        children: [
                          Image.file(_myImage!),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomBtn(
                          numWidth: 2.5,
                          onPressedFunc: () {
                            Navigator.of(context).pop();
                          },
                          label: 'Cancelar',
                          context: context,
                          rgbBgColor: Theme.of(context).secondaryHeaderColor,
                          rgbColor:
                              Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                        CustomBtn(
                          numWidth: 2.5,
                          onPressedFunc: _uploadImage,
                          label: 'Adicionar',
                          context: context,
                          rgbBgColor: Theme.of(context).primaryColor,
                          rgbColor: Theme.of(context).cardColor,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
