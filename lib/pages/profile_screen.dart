import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/my_drawer.dart';
import 'package:evolution_cam/components/textlabels.dart';
import 'package:evolution_cam/functions/modal.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = CollectionService.instance;
  final _nameController = TextEditingController();
  final _newCategoryController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingNewCategory = false;
  bool _isLoading = true;

  int _collectionsCount = 0;
  List<String> _categories = [];
  final List<TextEditingController> _categoryControllers = [];
  final List<bool> _isEditingCategory = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newCategoryController.dispose();
    for (final c in _categoryControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _service.count(),
        _service.categories(),
      ]);
      if (!mounted) return;
      setState(() {
        _collectionsCount = results[0] as int;
        _setCategories(results[1] as List<String>);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perfil: ${errorMessage(e)}')),
      );
    }
  }

  // Recria os controladores para acompanharem a lista de categorias.
  void _setCategories(List<String> categories) {
    for (final c in _categoryControllers) {
      c.dispose();
    }
    _categories = categories;
    _categoryControllers
      ..clear()
      ..addAll(categories.map((c) => TextEditingController(text: c)));
    _isEditingCategory
      ..clear()
      ..addAll(List.filled(categories.length, false));
  }

  _currentUser(option) {
    if (option == 'email') {
      return AuthService.instance.email;
    } else if (option == 'name') {
      return AuthService.instance.displayName.isEmpty
          ? 'Nome não definido'
          : AuthService.instance.displayName;
    } else {
      return AuthService.instance.currentUser;
    }
  }

  Future<void> _saveCategories(List<String> updated) async {
    try {
      await _service.saveCategories(updated);
      if (!mounted) return;
      setState(() {
        _setCategories(updated);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao guardar categorias: ${errorMessage(e)}')),
      );
    }
  }

  Future<void> _deleteCategory(int idx) =>
      _saveCategories([..._categories]..removeAt(idx));

  Future<void> _addCategory(int? idx) {
    final updated = [..._categories];
    if (idx == null) {
      updated.add(_newCategoryController.text);
      _newCategoryController.clear();
    } else {
      updated[idx] = _categoryControllers[idx].text;
    }
    return _saveCategories(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
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

                  try {
                    await AuthService.instance
                        .updateDisplayName(_nameController.text);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Erro ao guardar nome: ${errorMessage(e)}')),
                    );
                    return;
                  }

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
            Row(
              children: [
                MyText(
                  value: 'Coleções: ',
                  size: 'md',
                  fontWeight: FontWeight.bold,
                ),
                MyText(
                  value: _collectionsCount.toString(),
                  size: 'md',
                )
              ],
            ),
            SizedBox(height: 10),
            Builder(
              builder: (context) {
                if (_isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

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
                                    _addCategory(null);
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
                        children: _categories
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
                                                actions: () =>
                                                    _deleteCategory(idx),
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
                                        _categoryControllers[idx].text =
                                            _categories[idx];
                                      });
                                    },
                                    onButton2: () {
                                      // Salvar alterações
                                      setState(() {
                                        _addCategory(idx);
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
