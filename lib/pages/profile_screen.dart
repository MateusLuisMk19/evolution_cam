import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/myDrawer.dart';
import 'package:evolution_cam/components/textlabels.dart';
import 'package:evolution_cam/configs/app_controller.dart';
import 'package:evolution_cam/functions/modal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _newCategoryController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingNewCategory = false;

  final List<TextEditingController> _categoryControllers = [];
  final List<bool> _isEditingCategory = [];

  void _initializeCategoryControllers(categorias) {
    for (var categoria in categorias) {
      for (var item in categoria['list']) {
        _categoryControllers.add(TextEditingController(text: item.toString()));
        _isEditingCategory.add(false);
      }
    }
  }

  _currentUser(option) {
    if (option == 'email') {
      return _auth.currentUser?.email;
    } else if (option == 'name') {
      return _auth.currentUser?.displayName == ""
          ? 'Nome não definido'
          : _auth.currentUser?.displayName;
    } else {
      return _auth.currentUser;
    }
  }

  _deleteCategory(categorias, idx) async {
    // Obtém a lista de categorias antiga
    var oldCategList = categorias[0]['list'];

    // apagar elemento do indice idx
    oldCategList.removeAt(idx);

    // Adiciona uma nova categoria
    await _firestore
        .collection("categorias")
        .doc(categorias[0].id)
        .update({"list": oldCategList});
    // Atualiza o estado da página para refletir as novas categorias
    setState(() {});
  }

  _addCategory(categorias, idx) async {
    // Obtém a lista de categorias antiga
    var oldCategList = categorias[0]['list'];

    // atualizar a lista de categorias
    if (idx == false) {
      oldCategList.add(_newCategoryController.text);
    } else {
      oldCategList[idx] = _categoryControllers[idx].text;
    }

    // Adiciona uma nova categoria
    await _firestore
        .collection("categorias")
        .doc(categorias[0].id)
        .update({"list": oldCategList});
    // Atualiza o estado da página para refletir as novas categorias
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EvolutionCam'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: MyDrawer(
        page: 'profile',
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                MyText(
                  value: 'Nome: ',
                  size: 'md',
                  fontWeight: FontWeight.bold,
                ),
                MyText(
                  value: _currentUser('name').toString(),
                  size: 'md',
                  fontWeight: FontWeight.normal,
                ),
                Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton.filledTonal(
                        icon: Icon(
                          Icons.edit,
                          size: 15,
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingName = true;
                          });
                        },
                      ),
                    )),
              ],
            ),
            SizedBox(height: 10),
            CustomTextField(
              fieldController: _nameController,
              marginBottom: 10,
              placeholder: 'Insira o nome',
              radius: 5,
              context: context,
              inviseble: !_isEditingName,
            ),
            VisibilityBox(
              marginTop: 10,
              marginBottom: 10,
              inviseble: !_isEditingName,
              child: ButtonGroupYN(
                context: context,
                label1: 'Cancelar',
                label2: 'Salvar',
                onButton1: () {
                  setState(() {
                    _nameController.clear();
                    _isEditingName = false;
                  });
                },
                onButton2: () async {
                  if (_nameController.text.isEmpty) {
                    return;
                  }

                  // Atualiza o nome no Firebase
                  await _auth.currentUser
                      ?.updateDisplayName(_nameController.text);

                  setState(() {
                    _nameController.clear();
                    _isEditingName = false;
                  });

                  // Atualiza o estado da página para refletir o novo nome
                  setState(() {});
                },
              ),
            ),
            Row(
              children: [
                MyText(
                  value: 'Email: ',
                  size: 'md',
                  fontWeight: FontWeight.bold,
                ),
                MyText(
                  value: _currentUser('email').toString(),
                  size: 'md',
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('registros')
                  .where('uid', isEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final registros = snapshot.data!.docs;

                return Column(
                  children: [
                    Row(
                      children: [
                        MyText(
                          value: 'Registos: ',
                          size: 'md',
                          fontWeight: FontWeight.bold,
                        ),
                        MyText(
                          value: registros.length.toString(),
                          size: 'md',
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('categorias')
                  .where('uid', isEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final categorias = snapshot.data!.docs;
                _initializeCategoryControllers(categorias);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          value: 'Categorias',
                          size: 'md',
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(width: 10),
                        IconButton.filled(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          icon: Icon(
                            Icons.add,
                            size: 20,
                          ),
                          onPressed: () {
                            if (_isEditingNewCategory) {
                              return;
                            }
                            setState(() {
                              _isEditingNewCategory = true;
                            });
                          },
                        ),
                      ],
                    ),
                    VisibilityBox(
                        inviseble: !_isEditingNewCategory,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 60),
                          child: Column(children: [
                            CustomTextField(
                                fieldController: _newCategoryController,
                                placeholder: 'Nova categoria',
                                radius: 5,
                                context: context,
                                marginTop: 10),
                            VisibilityBox(
                              marginTop: 10,
                              marginBottom: 10,
                              child: ButtonGroupYN(
                                context: context,
                                label1: 'Cancelar',
                                label2: 'Salvar',
                                onButton1: () {
                                  setState(() {
                                    _isEditingNewCategory = false;
                                    _newCategoryController.clear();
                                  });
                                },
                                onButton2: () {
                                  setState(() {
                                    _addCategory(categorias, false);
                                    _isEditingNewCategory = false;
                                  });
                                },
                              ),
                            )
                          ]),
                        )),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      height: MediaQuery.of(context).size.height / 2,
                      child: ListView(
                        shrinkWrap:
                            true, // Evita que o ListView ocupe todo o espaço disponível
                        children: categorias[0]['list']
                            .asMap() // Converte a lista em um mapa para acessar índices
                            .entries
                            .map<Widget>((entry) {
                          final idx = entry.key; // Índice do item
                          final item = entry.value; // Valor do item

                          return SizedBox(
                            child: Column(
                              children: [
                                VisibilityBox(
                                  inviseble: _isEditingCategory[idx],
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyText(
                                            value: item.toString(),
                                            size: 'sm',
                                          ),
                                          ActionsGroup(
                                            inviseble: _isEditingCategory[idx],
                                            fistBtnPressed: () {
                                              setState(() {
                                                _isEditingCategory[idx] = true;
                                              });
                                            },
                                            secondBtnPressed: () {
                                              modalConfirm(
                                                context: context,
                                                content:
                                                    'Tem certeza que deseja deletar esta categoria?',
                                                actions: () {
                                                  _deleteCategory(
                                                    categorias,
                                                    idx,
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                CustomTextField(
                                    fieldController: _categoryControllers[idx],
                                    placeholder: 'Editar categoria',
                                    radius: 5,
                                    context: context,
                                    inviseble: !_isEditingCategory[idx],
                                    marginTop: 10),
                                VisibilityBox(
                                  marginTop: 10,
                                  marginBottom: 10,
                                  inviseble: !_isEditingCategory[idx],
                                  child: ButtonGroupYN(
                                    context: context,
                                    label1: 'Cancelar',
                                    label2: 'Salvar',
                                    onButton1: () {
                                      setState(() {
                                        _isEditingCategory[idx] = false;
                                        _categoryControllers[idx].clear();
                                      });
                                    },
                                    onButton2: () {
                                      // Salvar alterações
                                      setState(() {
                                        _addCategory(categorias, idx);
                                        _isEditingCategory[idx] = false;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
