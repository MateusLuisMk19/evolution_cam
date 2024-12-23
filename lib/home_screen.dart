import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();

  Future<void> _addRecord() async {
    try {
      await _firestore.collection('registros').add({
        'titulo': _titleController.text,
        'categoria': _categoryController.text,
        'dataCriacao': FieldValue.serverTimestamp(),
      });
      _titleController.clear();
      _categoryController.clear();
    } catch (e) {
      print('Erro ao adicionar registro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registros - EvolutionCam')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Categoria'),
                ),
                ElevatedButton(
                  onPressed: _addRecord,
                  child: Text('Adicionar Registro'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('registros').orderBy('dataCriacao').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final registros = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final registro = registros[index];
                    return ListTile(
                      title: Text(registro['titulo']),
                      subtitle: Text('Categoria: ${registro['categoria']}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
