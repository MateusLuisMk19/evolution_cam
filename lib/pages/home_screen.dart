import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/clickableCard.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/myDrawer.dart';
import 'package:evolution_cam/components/textlabels.dart';
import 'package:evolution_cam/functions/modal.dart';
import 'package:evolution_cam/pages/set_colection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _searchController = TextEditingController();

  List<QueryDocumentSnapshot> collections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCollections();
  }

  Future<void> _fetchCollections() async {
    try {
      final snapshot = await _firestore
          .collection('colecoes')
          .where('uid', isEqualTo: _auth.currentUser?.uid)
          .get();

      setState(() {
        collections = snapshot.docs;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar coleções: $error')),
      );
    }
  }

  Future<void> _deleteCollection(collectionId) async {
    try {
      await _firestore.collection('colecoes').doc(collectionId).delete();
      await _fetchCollections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar coleção: $e')),
      );
    }
  }

  String _convertTStampToDateTime({required Timestamp TStamp}) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(TStamp.millisecondsSinceEpoch);
    String stringDate = date.toString();
    return stringDate.substring(0, 10);
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
              placeholder: 'Procurar',
              radius: 10,
              context: context,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];

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
                                builder: (context) => SetColectionScreen(
                                  collectionId: collection.id,
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
                            content: 'Deseja realmente excluir a coleção?',
                            actions: () => _deleteCollection(collection.id));
                      },
                    ),
                  ],
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/inner', arguments: collection.id);
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
                                    _convertTStampToDateTime(
                                        TStamp: collection['updatedAt']),
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    collection['imgs'].length > 0
                                        ? '${collection['imgs'].length} arquivo(s)'
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
