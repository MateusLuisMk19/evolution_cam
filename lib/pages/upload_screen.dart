import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  final String collectionId;

  const UploadScreen({Key? key, required this.collectionId}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final ref = _storage
          .ref()
          .child('colecoes')
          .child(widget.collectionId)
          .child('foto_${DateTime.now().toIso8601String()}.jpg');

      await ref.putFile(_image!);

      final url = await ref.getDownloadURL();

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload concluído! URL: $url')),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer upload: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload de Imagem')),
      body: Column(
        children: [
          if (_image != null) Image.file(_image!, height: 200),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Capturar Foto'),
          ),
          ElevatedButton(
            onPressed: _uploadImage,
            child: Text('Fazer Upload'),
          ),
        ],
      ),
    );
  }
}
