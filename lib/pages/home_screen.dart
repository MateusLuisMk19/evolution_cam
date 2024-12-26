import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/configs/app_controller.dart';
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

  _currentUser(who) {
    return who == 'email'
        ? _auth.currentUser?.email
        : who == 'name'
            ? _auth.currentUser?.displayName
            : _auth.currentUser;
  }

  Future<void> _searchReg() async {
    // function to search
  }

  String _convertTStampToDateTime({TStamp}) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(TStamp.millisecondsSinceEpoch);
    String stringDate = date.toString();
    return stringDate.substring(0, 10);
  }

  void _logOut() async {
    _auth.signOut();
    Navigator.of(context).pushReplacementNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EvolutionCam'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [CustomSwitch()],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              accountName: Text(_currentUser('name').toString()),
              accountEmail: Text(_currentUser('email').toString()),
            ),
            Column(
              children: [
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Sair"),
                  subtitle: Text("Terminar sessão"),
                  onTap: () {
                    _logOut();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Sair"),
                  subtitle: Text("Terminar sessão"),
                  onTap: () {
                    _logOut();
                  },
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Sair"),
              subtitle: Text("Terminar sessão"),
              onTap: () {
                _logOut();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomTextField(
                  fieldController: _searchController,
                  placeholder: 'Procurar',
                  radius: 10,
                  context: context)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('registros')
                  .where('uid', isEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final registros = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final registro = registros[index];

                    return Card(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: Border.all(),
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
                                  Text(
                                    registro['titulo'],
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  Text(
                                    _convertTStampToDateTime(
                                        TStamp: registro['updatedAt']),
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${registro['imgs'].length} registo(s)',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    registro['categoria'],
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
          }),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: AppController.instance.isDarkTheme,
      onChanged: (value) {
        AppController.instance.changeTheme();
      },
    );
  }
}
