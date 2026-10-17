import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/components/feedback.dart';
import 'package:evolution_cam/components/my_drawer.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/functions/format.dart';
import 'package:evolution_cam/pages/set_collection_screen.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = CollectionService.instance;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _collections = [];
  bool _isLoading = true;
  String? _category; // null = todas

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final data = await _service.list();
      if (!mounted) return;
      setState(() {
        _collections = data;
        _isLoading = false;
        // A categoria escolhida pode ter deixado de existir.
        if (_category != null &&
            !data.any((c) => c['categoria'] == _category)) {
          _category = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showAppSnack(context, 'Erro ao buscar coleções: ${errorMessage(e)}',
          error: true);
    }
  }

  Future<void> _openForm([String? id]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SetCollectionScreen(collectionId: id),
      ),
    );
    if (changed == true) _fetch(silent: true);
  }

  Future<void> _open(String id) async {
    await Navigator.of(context).pushNamed('/inner', arguments: id);
    if (mounted) _fetch(silent: true);
  }

  Future<void> _delete(Map<String, dynamic> c) async {
    final ok = await confirmDialog(
      context,
      title: 'Excluir coleção?',
      message:
          '"${c['titulo']}" e ${photoCount(c['imgCount'] as int).toLowerCase()} serão apagadas para sempre.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await _service.delete(c['id'] as String);
      if (!mounted) return;
      showAppSnack(context, 'Coleção excluída');
      _fetch(silent: true);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, 'Erro ao excluir: ${errorMessage(e)}', error: true);
    }
  }

  List<Map<String, dynamic>> get _visible {
    final q = _searchController.text.trim().toLowerCase();
    return _collections.where((c) {
      if (_category != null && c['categoria'] != _category) return false;
      if (q.isEmpty) return true;
      return '${c['titulo']}'.toLowerCase().contains(q) ||
          '${c['categoria']}'.toLowerCase().contains(q);
    }).toList();
  }

  String get _firstName {
    final name = AuthService.instance.displayName.trim();
    if (name.isNotEmpty) return name.split(RegExp(r'\s+')).first;
    return (AuthService.instance.email ?? '').split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final categories = _collections
        .map((c) => c['categoria'] as String)
        .toSet()
        .toList()
      ..sort();
    final visible = _visible;

    return Scaffold(
      drawer: const MyDrawer(page: 'home'),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child:
                  Image.asset('assets/images/minLogo.png', semanticLabel: ''),
            ),
            const SizedBox(width: 10),
            const Text('EvolutionCam'),
          ],
        ),
      ),
      // No estado vazio o botão do próprio conteúdo já faz a mesma coisa.
      floatingActionButton: _isLoading || _collections.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Nova coleção'),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _fetch(silent: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Olá, $_firstName',
                              style: text.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(
                            _collections.isEmpty
                                ? 'Crie a sua primeira coleção.'
                                : '${_collections.length} ${_collections.length == 1 ? 'coleção' : 'coleções'} em acompanhamento',
                            style: text.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (_collections.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _searchController,
                              label: 'Pesquisar coleções',
                              icon: Icons.search,
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (categories.length > 1)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 64,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                          children: [
                            _CategoryChip(
                              label: 'Todas',
                              selected: _category == null,
                              onSelected: () =>
                                  setState(() => _category = null),
                            ),
                            for (final c in categories)
                              _CategoryChip(
                                label: c,
                                selected: _category == c,
                                onSelected: () => setState(() => _category = c),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (_collections.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.add_a_photo_outlined,
                        title: 'Comece a registrar a sua evolução',
                        message:
                            'Crie uma coleção e tire a primeira foto. Nas seguintes, a foto anterior serve de guia para tirar sempre no mesmo enquadramento.',
                        action: AppButton(
                          label: 'Criar coleção',
                          icon: Icons.add,
                          expand: false,
                          onPressed: () => _openForm(),
                        ),
                      ),
                    )
                  else if (visible.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: 'Nada encontrado',
                        message: 'Tente outro termo ou limpe o filtro.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
                      sliver: SliverList.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final c = visible[i];
                          return _CollectionCard(
                            collection: c,
                            onTap: () => _open(c['id'] as String),
                            onEdit: () => _openForm(c['id'] as String),
                            onDelete: () => _delete(c),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Map<String, dynamic> collection;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CollectionCard({
    required this.collection,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final count = collection['imgCount'] as int;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Cover(url: collection['coverUrl'] as String?),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection['titulo'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        collection['categoria'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${photoCount(count)} · ${formatDate(collection['updatedAt'] as DateTime)}',
                      style: text.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opções da coleção',
                icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: scheme.error),
                      title: Text('Excluir',
                          style: TextStyle(color: scheme.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({this.url});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      color: scheme.surfaceContainerHigh,
      child: Icon(Icons.photo_outlined, color: scheme.onSurfaceVariant),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: 88,
        height: 88,
        child: url == null
            ? placeholder
            : Image.network(
                url!,
                fit: BoxFit.cover,
                cacheWidth: 264,
                errorBuilder: (_, __, ___) => placeholder,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
              ),
      ),
    );
  }
}
