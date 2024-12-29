import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InnerCollestionScreen extends StatefulWidget {
  const InnerCollestionScreen({super.key});

  @override
  _InnerCollestionScreenState createState() => _InnerCollestionScreenState();
}

class _InnerCollestionScreenState extends State<InnerCollestionScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late String id;
  Map<String, dynamic>? collection; 
  bool isLoading = true; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    id = ModalRoute.of(context)!.settings.arguments as String;

    _firestore.collection('colecoes').doc(id).get().then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          collection = snapshot.data() as Map<String, dynamic>;
          isLoading = false; 
        });
      } else {
        setState(() {
          isLoading = false; 
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coleção não encontrado.')),
        );
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar o coleção: $error')),
      );
    });
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

    if (collection == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Erro'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: Center(child: Text('Coleção não encontrada.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(collection!['titulo']),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Text(
                  collection!['categoria'],
                )),
          ),
          // galeria de imagens
          Card(
            margin: EdgeInsets.only(bottom: 50),
            elevation: 4,
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: SizedBox(
              width: 170,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 65,
                    height: 60,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        elevation: 2,
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                      ),
                      iconSize: 30,
                      onPressed: () {},
                      icon: Icon(Icons.add_photo_alternate),
                    ),
                  ),
                  SizedBox(
                    width: 65,
                    height: 60,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(
                        elevation: 2,
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      iconSize: 30,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/upload',
                            arguments: id); 
                      },
                      icon: Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
          )

          // botão de adicionar imagem
          // botão de capturar imagem
        ],
      ),
    );
  }
}
