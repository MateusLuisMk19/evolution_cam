import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/components/customSwitch.dart';
import 'package:evolution_cam/components/textlabels.dart';
import 'package:evolution_cam/configs/app_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  final String page;

  const MyDrawer({
    Key? key,
    required this.page,
  }) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final _auth = FirebaseAuth.instance;
  String? selectedValue;

  _currentUser(who) {
    return who == 'email'
        ? _auth.currentUser?.email
        : who == 'name'
            ? _auth.currentUser?.displayName
            : _auth.currentUser;
  }

  void _logOut() async {
    _auth.signOut();
    Navigator.of(context).pushReplacementNamed("/login");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPictureSize: Size.square(120),
                currentAccountPicture: SizedBox(
                  child: Image.asset(
                    'assets/images/minLogo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                accountName: Text(_currentUser('name').toString()),
                accountEmail: Text(_currentUser('email').toString()),
              ),
              SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        value: 'Aterar Tema',
                        size: 'md',
                      ),
                      SizedBox(width: 10),
                      CustomSwitch()
                    ],
                  )),
              VisibilityBox(
                  inviseble: widget.page == 'home' ? true : false,
                  child: ListTile(
                    leading: Icon(Icons.home_outlined),
                    title: Text("Home"),
                    subtitle: Text("Pagina inicial"),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                  )),
              VisibilityBox(
                  inviseble: widget.page == 'profile' ? true : false,
                  child: ListTile(
                    leading: Icon(Icons.person_3_outlined),
                    title: Text("Perfil"),
                    subtitle: Text("Gestão de perfil"),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/profile');
                    },
                  )),
              /* ListTile(
                leading: Icon(Icons.logout),
                title: Text("Outra coisa"),
                subtitle: Text("Terminar sessão"),
                onTap: () {
                  _logOut();
                }, 
              ),*/
            ],
          ),
          ListTile(
            leading: Icon(Icons.logout_sharp),
            title: Text("Sair"),
            subtitle: Text("Terminar sessão"),
            onTap: () {
              _logOut();
            },
          ),
        ],
      ),
    );
  }
}

class CustomSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyCustomSwitch(
      value: AppController.instance.isDarkTheme,
      onChanged: (value) {
        AppController.instance.changeTheme();
      },
    );
    /* return Switch(
      value: AppController.instance.isDarkTheme,
      onChanged: (value) {
        AppController.instance.changeTheme();
      },
      activeColor: Colors.green, // Cor do botão ativo
      activeTrackColor: Colors.lightGreenAccent, // Cor da trilha ativa
      inactiveThumbColor: Colors.red, // Cor do botão inativo
      inactiveTrackColor: Colors.orange,
    ); */
  }
}
