import 'dart:io';

import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:flutter/material.dart';

class Addimageinner extends StatefulWidget {
  const Addimageinner({super.key});

  @override
  _AddimageinnerState createState() => _AddimageinnerState();
}

class _AddimageinnerState extends State<Addimageinner> {
  final _service = CollectionService.instance;

  late String collectionId;
  Map<String, dynamic>? collection;
  bool isLoading = true;

  File? _myImage;
  bool _started = false;
  bool isImageSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    collectionId = args['collectionId'];
    final imagePath = args['imagePath'];
    _myImage = File(imagePath);

    // Carregar os dados da coleção (só na primeira vez)
    if (!_started) {
      _started = true;
      _loadCollectionData();
    }
  }

  Future<void> _loadCollectionData() async {
    try {
      final data = await _service.get(collectionId);
      if (data == null) throw Exception('Coleção não encontrada');
      if (!mounted) return;
      setState(() {
        collection = data;
        isLoading = false;
        isImageSelected = true;
      });
    } catch (e) {
      if (!mounted) return;
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

      await _service.addImage(collectionId, _myImage!);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload concluído!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer upload: ${errorMessage(e)}')),
      );
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
        body: SafeArea(
          child: Column(
            children: [
              // A foto ocupa o espaço que sobra; os botões ficam sempre visíveis.
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _myImage!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 16),
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
                      rgbColor: Theme.of(context).textTheme.bodyLarge!.color,
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
            ],
          ),
        ),
      );
    }
  }
}
