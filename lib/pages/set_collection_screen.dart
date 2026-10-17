import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/custom_select_field.dart';
import 'package:flutter/material.dart';

class SetColectionScreen extends StatefulWidget {
  final String? collectionId;
  const SetColectionScreen({Key? key, this.collectionId}) : super(key: key);

  @override
  _SetColectionScreenState createState() => _SetColectionScreenState();
}

class _SetColectionScreenState extends State<SetColectionScreen> {
  final _service = CollectionService.instance;

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _newCategoryController = TextEditingController();

  bool _isOutherCategory = false;
  String _message = '';
  List<String> _categories = [];
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
      final categories = await _service.categories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro ao carregar categorias: ${errorMessage(e)}';
      });
    }
  }

  Future<void> _loadCollection() async {
    try {
      final data = await _service.get(widget.collectionId!);
      if (data != null && mounted) {
        setState(() {
          _titleController.text = data['titulo'] ?? '';
          _categoryController.text = data['categoria'] ?? '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro ao carregar coleção: ${errorMessage(e)}';
      });
    }
  }

  Future<void> _addCollection() async {
    if (_titleController.text.trim().isEmpty ||
        _categoryController.text.isEmpty) {
      setState(() {
        _message = 'Preenche o título e escolhe uma categoria';
      });
      return;
    }
    try {
      await _service.create(
        title: _titleController.text,
        category: _categoryController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro: ${errorMessage(e)}';
      });
    }
  }

  Future<void> _addCategory() async {
    if (_newCategoryController.text.isEmpty) return;

    try {
      final updated = [..._categories, _newCategoryController.text];
      await _service.saveCategories(updated);
      if (!mounted) return;

      setState(() {
        _categories = updated;
        _categoryController.text = _newCategoryController.text;
        _newCategoryController.clear();
        _isOutherCategory = false;
        _message = 'Categoria adicionada com sucesso';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro ao adicionar categoria: ${errorMessage(e)}';
      });
    }
  }

  Future<void> _updateCollection() async {
    if (_titleController.text.trim().isEmpty ||
        _categoryController.text.isEmpty) {
      setState(() {
        _message = 'Preenche o título e escolhe uma categoria';
      });
      return;
    }
    try {
      await _service.update(
        widget.collectionId!,
        title: _titleController.text,
        category: _categoryController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro ao atualizar: ${errorMessage(e)}';
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
