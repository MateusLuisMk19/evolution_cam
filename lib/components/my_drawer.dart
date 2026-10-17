import 'package:evolution_cam/components/custom_switch.dart';
import 'package:evolution_cam/components/textlabels.dart';
import 'package:evolution_cam/configs/app_controller.dart';
import 'package:evolution_cam/services/auth_service.dart';
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
  String? selectedValue;

  _currentUser(who) {
    return who == 'email'
        ? AuthService.instance.email
        : who == 'name'
            ? AuthService.instance.displayName
            : AuthService.instance.currentUser;
  }

  void _logOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
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
                onDetailsPressed: () {
                  Navigator.of(context).pushReplacementNamed('/profile');
                },
                arrowColor: Theme.of(context).primaryColor,
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
              ListTile(
                leading: Icon(Icons.home_outlined),
                title: Text("Home"),
                subtitle: Text("Página inicial"),
                selected: widget.page == 'home',
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text("Perfil"),
                subtitle: Text("Nome e categorias"),
                selected: widget.page == 'profile',
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/profile');
                },
              ),

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
          SafeArea(
            top: false,
            child: ListTile(
              leading: Icon(Icons.logout_sharp),
              title: Text("Sair"),
              subtitle: Text("Terminar sessão"),
              onTap: () {
                _logOut();
              },
            ),
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
