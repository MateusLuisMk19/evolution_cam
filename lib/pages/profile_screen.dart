import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/components/feedback.dart';
import 'package:evolution_cam/components/my_drawer.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = CollectionService.instance;

  bool _isLoading = true;
  int _collections = 0;
  int _photos = 0;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _service.count(),
        _service.countImages(),
        _service.categories(),
      ]);
      if (!mounted) return;
      setState(() {
        _collections = results[0] as int;
        _photos = results[1] as int;
        _categories = results[2] as List<String>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppSnack(context, 'Erro ao carregar perfil: ${errorMessage(e)}',
          error: true);
    }
  }

  Future<void> _editName() async {
    final name = await promptDialog(
      context,
      title: 'Alterar nome',
      label: 'Nome',
      initial: AuthService.instance.displayName,
      icon: Icons.person_outline,
    );
    if (name == null || !mounted) return;
    try {
      await AuthService.instance.updateDisplayName(name);
      if (!mounted) return;
      setState(() {});
      showAppSnack(context, 'Nome atualizado');
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Erro ao salvar o nome: ${errorMessage(e)}',
          error: true);
    }
  }

  Future<void> _saveCategories(List<String> updated) async {
    try {
      await _service.saveCategories(updated);
      if (!mounted) return;
      setState(() => _categories = updated);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Erro ao salvar as categorias: ${errorMessage(e)}',
          error: true);
    }
  }

  bool _exists(String name, {int? except}) {
    for (var i = 0; i < _categories.length; i++) {
      if (i != except && _categories[i].toLowerCase() == name.toLowerCase()) {
        return true;
      }
    }
    return false;
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
    if (_exists(name)) {
      showAppSnack(context, 'Essa categoria já existe', error: true);
      return;
    }
    await _saveCategories([..._categories, name]);
  }

  Future<void> _renameCategory(int index) async {
    final name = await promptDialog(
      context,
      title: 'Renomear categoria',
      label: 'Nome da categoria',
      initial: _categories[index],
      icon: Icons.label_outline,
    );
    if (name == null || !mounted) return;
    if (_exists(name, except: index)) {
      showAppSnack(context, 'Essa categoria já existe', error: true);
      return;
    }
    await _saveCategories([..._categories]..[index] = name);
  }

  Future<void> _deleteCategory(int index) async {
    final ok = await confirmDialog(
      context,
      title: 'Excluir categoria?',
      message:
          '"${_categories[index]}" deixa de aparecer na lista. As coleções que já a usam não são afetadas.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _saveCategories([..._categories]..removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final auth = AuthService.instance;
    final name = auth.displayName;

    return Scaffold(
      drawer: const MyDrawer(page: 'profile'),
      appBar: AppBar(title: const Text('Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          UserAvatar(name: name, email: auth.email, radius: 36),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isEmpty ? 'Nome não definido' : name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  auth.email ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Alterar nome',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: _editName,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                            icon: Icons.photo_library_outlined,
                            value: '$_collections',
                            label: 'Coleções'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Stat(
                            icon: Icons.photo_camera_outlined,
                            value: '$_photos',
                            label: 'Fotos'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Stat(
                            icon: Icons.label_outline,
                            value: '${_categories.length}',
                            label: 'Categorias'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Categorias',
                            style: text.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ),
                      TextButton.icon(
                        onPressed: _addCategory,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Ainda não tem categorias. Adicione uma para organizar as suas coleções.',
                        textAlign: TextAlign.center,
                        style: text.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    )
                  else
                    for (var i = 0; i < _categories.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.only(left: 16, right: 4),
                            leading: Icon(Icons.label_outline,
                                color: scheme.primary),
                            title: Text(_categories[i],
                                style: text.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Renomear',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _renameCategory(i),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  icon: Icon(Icons.delete_outline,
                                      color: scheme.error),
                                  onPressed: () => _deleteCategory(i),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(icon, color: scheme.onPrimaryContainer),
          const SizedBox(height: 8),
          Text(value,
              style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer)),
          Text(label,
              style:
                  text.labelMedium?.copyWith(color: scheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}
