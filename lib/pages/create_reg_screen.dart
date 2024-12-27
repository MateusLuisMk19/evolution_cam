import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/customSelectField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateRegScreen extends StatefulWidget {
  const CreateRegScreen({Key? key}) : super(key: key);

  @override
  _CreateRegScreenState createState() => _CreateRegScreenState();
}

class _CreateRegScreenState extends State<CreateRegScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isOutherCategory = false;
  String _message = '';

  Future<void> _addRecord() async {
    if (_titleController.text.isEmpty || _categoryController.text.isEmpty) {
      return;
    }
    try {
      await _firestore.collection('registros').add({
        'uid': _auth.currentUser?.uid,
        'titulo': _titleController.text,
        'categoria': _categoryController.text,
        'imgs': [],
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      _titleController.clear();
      _categoryController.clear();
      // go to register
      setState(() {
        _message = 'Success! Register added successfully';
      });
    } catch (e) {
      setState(() {
        _message = 'Erro: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'EvolutionCam',
      )),
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
                    context: context),
                StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('categorias')
                        .where('uid', isEqualTo: _auth.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final categoria = snapshot.data!.docs[0];

                      return CustomSelectField(
                        marginTop: 10,
                        marginBottom: 20,
                        options: [...categoria['list'], 'Outra Categoria'],
                        hint: 'Selecione uma categoria',
                        onChanged: (value) {
                          if (value == "Outra Categoria") {
                            setState(() {
                              _isOutherCategory = true;
                              return;
                            });
                          }
                          _categoryController.text = value!;
                        },
                        invisible: _isOutherCategory,
                      );
                    }),
                CustomTextField(
                  marginTop: 10,
                  marginBottom: 20,
                  fieldController: _categoryController,
                  placeholder: 'Categoria',
                  radius: 5,
                  context: context,
                  inviseble: !_isOutherCategory,
                ),
                CustomBtn(
                  context: context,
                  label: 'Adicionar',
                  onPressedFunc: _addRecord,
                  rgbBgColor: Color.fromRGBO(0, 122, 204, 1),
                  rgbColor: Color.fromRGBO(249, 249, 249, 1),
                )
              ],
            ),
          ),
          Text(_message),
        ],
      ),
    );
  }
}
