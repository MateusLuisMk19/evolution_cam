import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/components/feedback.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:flutter/material.dart';

class SetCollectionScreen extends StatefulWidget {
  final String? collectionId;
  const SetCollectionScreen({Key? key, this.collectionId}) : super(key: key);

  @override
  State<SetCollectionScreen> createState() => _SetCollectionScreenState();
}

class _SetCollectionScreenState extends State<SetCollectionScreen> {
  final _service = CollectionService.instance;
  final _titleController = TextEditingController();

  List<String> _categories = [];
  String? _category;
  bool _isLoading = true;
  bool _isSaving = false;
  String _error = '';

  bool get _isEditing => widget.collectionId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final categories = await _service.categories();
      Map<String, dynamic>? meta;
      if (_isEditing) meta = await _service.getMeta(widget.collectionId!);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        if (meta != null) {
          _titleController.text = meta['titulo'] as String;
          _category = meta['categoria'] as String;
          // Uma categoria já apagada continua a aparecer na coleção.
          if (!_categories.contains(_category)) {
            _categories = [..._categories, _category!];
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Erro ao carregar: ${errorMessage(e)}';
      });
    }
  }

  Future<void> _addCategory() async {
    final name = await promptDialog(
      context,
      title: 'Nova categoria',
      label: 'Nome da categoria',
      confirmLabel: 'Adicionar',
      icon: Icons.label_outline,
    );
    if (name == null || !mounted) return;
    if (_categories.any((c) => c.toLowerCase() == name.toLowerCase())) {
      showAppSnack(context, 'Essa categoria já existe', error: true);
      return;
    }
    try {
      final updated = [..._categories, name];
      await _service.saveCategories(updated);
      if (!mounted) return;
      setState(() {
        _categories = updated;
        _category = name;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Erro ao adicionar categoria: ${errorMessage(e)}',
          error: true);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (_titleController.text.trim().isEmpty || _category == null) {
      setState(() => _error = 'Preencha o título e escolha uma categoria');
      return;
    }
    setState(() {
      _isSaving = true;
      _error = '';
    });
    try {
      if (_isEditing) {
        await _service.update(
          widget.collectionId!,
          title: _titleController.text.trim(),
          category: _category!,
        );
      } else {
        await _service.create(
          title: _titleController.text.trim(),
          category: _category!,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = 'Erro ao salvar: ${errorMessage(e)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar coleção' : 'Nova coleção'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(
                    'Dê um nome ao que vai acompanhar, por exemplo "Treino de verão" ou "Obra da cozinha".',
                    style: text.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _titleController,
                    label: 'Título',
                    icon: Icons.title,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  Text('Categoria',
                      style: text.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _categories)
                        ChoiceChip(
                          label: Text(c),
                          selected: _category == c,
                          showCheckmark: false,
                          onSelected: (_) => setState(() {
                            _category = c;
                            _error = '';
                          }),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('Nova categoria'),
                        onPressed: _addCategory,
                      ),
                    ],
                  ),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: scheme.onErrorContainer, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_error,
                                style:
                                    TextStyle(color: scheme.onErrorContainer)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  AppButton(
                    label: _isEditing ? 'Salvar alterações' : 'Criar coleção',
                    loading: _isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
