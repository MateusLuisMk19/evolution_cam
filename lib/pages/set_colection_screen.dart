import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/customSelectField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetColectionScreen extends StatefulWidget {
  final String? collectionId;
  const SetColectionScreen({Key? key, this.collectionId}) : super(key: key);

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
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.collectionId != null) {
      isEditing = true;
      _loadCollection();
    }
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

  Future<void> _loadCollection() async {
    try {
      final doc = await _firestore
          .collection('colecoes')
          .doc(widget.collectionId)
          .get();

      if (doc.exists) {
        setState(() {
          _titleController.text = doc.data()?['titulo'] ?? '';
          _categoryController.text = doc.data()?['categoria'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erro ao carregar coleção: $e';
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

  Future<void> _updateCollection() async {
    if (_titleController.text.isEmpty || _categoryController.text.isEmpty) {
      return;
    }
    try {
      await _firestore.collection('colecoes').doc(widget.collectionId).update({
        'titulo': _titleController.text,
        'categoria': _categoryController.text,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      setState(() {
        _message = 'Coleção atualizada com sucesso!';
      });
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      setState(() {
        _message = 'Erro ao atualizar: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Coleção' : 'Adicionar Coleção'),
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
                  marginBottom: 10,
                ),
                CustomSelectField(
                  marginTop: 10,
                  marginBottom: 20,
                  options: [..._categories, 'Outra Categoria'],
                  hint: isEditing
                      ? _categoryController.text
                      : 'Selecione uma categoria',
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
                      : isEditing
                          ? 'Atualizar Coleção'
                          : 'Adicionar Coleção',
                  onPressedFunc: _isOutherCategory
                      ? _addCategory
                      : (isEditing ? _updateCollection : _addCollection),
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
