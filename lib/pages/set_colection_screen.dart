import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/customSelectField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetColectionScreen extends StatefulWidget {
  const SetColectionScreen({Key? key}) : super(key: key);

  @override
  _SetColectionScreenState createState() => _SetColectionScreenState();
}

class _SetColectionScreenState extends State<SetColectionScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _newCategoryController = TextEditingController();

  bool _isOutherCategory = false;
  String _message = '';
  List<String> _categories = [];
  String _categoryId = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categorias')
          .where('uid', isEqualTo: _auth.currentUser?.uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _categories = List<String>.from(snapshot.docs[0]['list']);
          _categoryId = snapshot.docs[0].id;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erro ao carregar categorias: $e';
      });
    }
  }

  Future<void> _addCollection() async {
    if (_titleController.text.isEmpty || _categoryController.text.isEmpty) {
      return;
    }
    try {
      await _firestore.collection('colecoes').add({
        'uid': _auth.currentUser?.uid,
        'titulo': _titleController.text,
        'categoria': _categoryController.text,
        'imgs': [],
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      _titleController.clear();
      _categoryController.clear();
      setState(() {
        _message = 'Success! Coleção added successfully';
      });
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      setState(() {
        _message = 'Erro: ${e.toString()}';
      });
    }
  }

  Future<void> _addCategory() async {
    if (_newCategoryController.text.isEmpty) return;

    try {
      // Adiciona a nova categoria
      _categories.add(_newCategoryController.text);

      // Atualiza a coleção no Firestore
      await _firestore.collection("categorias").doc(_categoryId).update({
        "list": _categories,
      });

      setState(() {
        _categoryController.clear();
        _categoryController.text = _newCategoryController.text;
        _newCategoryController.clear();
        _isOutherCategory = false;
        _message = 'Categoria adicionada com sucesso';
      });
    } catch (e) {
      setState(() {
        _message = 'Erro ao adicionar categoria: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adiciona Coleção'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CustomTextField(
                  fieldController: _titleController,
                  placeholder: 'Titulo',
                  radius: 5,
                  context: context,
                ),
                CustomSelectField(
                  marginTop: 10,
                  marginBottom: 20,
                  options: [..._categories, 'Outra Categoria'],
                  hint: 'Selecione uma categoria',
                  onChanged: (value) {
                    if (value == "Outra Categoria") {
                      setState(() {
                        _isOutherCategory = true;
                      });
                      return;
                    }
                    _categoryController.text = value!;
                  },
                  invisible: _isOutherCategory,
                ),
                CustomTextField(
                  marginTop: 10,
                  marginBottom: 20,
                  fieldController: _newCategoryController,
                  placeholder: 'Nova Categoria',
                  radius: 5,
                  context: context,
                  inviseble: !_isOutherCategory,
                ),
                CustomBtn(
                  context: context,
                  label: _isOutherCategory
                      ? 'Adicionar Categoria'
                      : 'Adicionar Coleção',
                  onPressedFunc:
                      _isOutherCategory ? _addCategory : _addCollection,
                  rgbBgColor: !_isOutherCategory
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).secondaryHeaderColor,
                  rgbColor: const Color.fromRGBO(249, 249, 249, 1),
                ),
              ],
            ),
          ),
          Text(_message),
        ],
      ),
    );
  }
}
