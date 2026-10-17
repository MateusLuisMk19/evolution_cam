import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:evolution_cam/components/clickable_card.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/my_drawer.dart';
import 'package:evolution_cam/components/textlabels.dart';
import 'package:evolution_cam/functions/modal.dart';
import 'package:evolution_cam/pages/set_collection_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = CollectionService.instance;
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> collections = [];
  bool isLoading = true;
  List<Map<String, dynamic>> _filteredCollections = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCollections);
    _fetchCollections();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCollections);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCollections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCollections = List.of(collections);
      } else {
        _filteredCollections = collections.where((doc) {
          final titulo = doc['titulo'].toString().toLowerCase();
          final categoria = doc['categoria'].toString().toLowerCase();
          return titulo.contains(query) || categoria.contains(query);
        }).toList();
      }

      // Ordena a lista filtrada por data de atualização
      _filteredCollections.sort((a, b) {
        final DateTime timeA = a['updatedAt'];
        final DateTime timeB = b['updatedAt'];
        return timeB.compareTo(timeA); // Ordem descendente
      });
    });
  }

  Future<void> _fetchCollections({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final data = await _service.list();
      if (!mounted) return;
      setState(() {
        collections = data;
        _filteredCollections = List.of(data);
        isLoading = false;
      });
      _filterCollections();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao buscar coleções: ${errorMessage(error)}')),
      );
    }
  }

  Future<void> _deleteCollection(String collectionId) async {
    try {
      await _service.delete(collectionId);
      await _fetchCollections();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar coleção: ${errorMessage(e)}')),
      );
    }
  }

  String _formatDate(DateTime date) => date.toString().substring(0, 10);

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

    return Scaffold(
      appBar: AppBar(
        title: Text('EvolutionCam'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: MyDrawer(
        page: 'home',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              fieldController: _searchController,
              placeholder: 'Procurar por título ou categoria',
              radius: 10,
              context: context,
              onChanged: (value) => _filterCollections(),
            ),
          ),
          Expanded(
            child: _filteredCollections.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma coleção encontrada',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _fetchCollections(silent: true),
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredCollections.length,
                      itemBuilder: (context, index) {
                        final collection = _filteredCollections[index];

                        return MyClickable(
                          items: [
                            PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                                onTap: () {
                                  Future.delayed(
                                    const Duration(seconds: 0),
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SetColectionScreen(
                                          collectionId: collection['id'],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Excluir'),
                              onTap: () {
                                modalConfirm(
                                    context: context,
                                    content:
                                        'Deseja realmente excluir a coleção?',
                                    actions: () =>
                                        _deleteCollection(collection['id']));
                              },
                            ),
                          ],
                          onTap: () async {
                            await Navigator.of(context).pushNamed('/inner',
                                arguments: collection['id']);
                            _fetchCollections();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Card(
                              color: Theme.of(context).cardTheme.color,
                              elevation: 4,
                              child: SizedBox(
                                height: 75,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyText(
                                            value: collection['titulo'],
                                            size: 'md',
                                            fontWeight: FontWeight.bold,
                                          ),
                                          Text(
                                            _formatDate(
                                                collection['updatedAt']),
                                            style: TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            collection['imgCount'] > 0
                                                ? '${collection['imgCount']} arquivo(s)'
                                                : 'N/A arquivo(s)',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            collection['categoria'],
                                            style: TextStyle(fontSize: 16),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/create');
        },
      ),
    );
  }
}
