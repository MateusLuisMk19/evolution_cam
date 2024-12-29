import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      setState(() {
        _message = 'Erro: ${e.toString()}';
      });
    }
  }

  Future<void> _loginWtGoogle() async {
    setState(() {
      _message = 'Login com Google ainda não implementado';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: darkTheme.cardTheme.color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image(
                    image: AssetImage('assets/images/fullLogo.png'),
                    width: 130,
                    height: 130,
                  ),
                ),
                SizedBox(height: 25),
                CustomTextField(
                  fieldController: _emailController,
                  placeholder: "Email",
                  radius: 15,
                  context: context,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  fieldController: _passwordController,
                  placeholder: "Senha",
                  radius: 15,
                  context: context,
                  isObscured: true,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomBtn(
                        context: context,
                        label: "Cadastro",
                        numWidth: 3,
                        onPressedFunc: () {
                          Navigator.of(context).pushNamed('/register');
                        },
                        rgbBgColor: Color.fromRGBO(111, 195, 223, 1),
                        rgbColor: Color.fromRGBO(51, 51, 51, 1),
                      ),
                      CustomBtn(
                        context: context,
                        label: "Entrar",
                        numWidth: 3,
                        onPressedFunc: _login,
                        rgbBgColor: Color.fromRGBO(0, 122, 204, 1),
                        rgbColor: Color.fromRGBO(249, 249, 249, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: Center(
                      child: Text(
                    "Ou",
                    style: TextStyle(),
                  )),
                ),
                CustomBtn(
                  context: context,
                  label: "Entrar com Google",
                  numWidth: 1,
                  onPressedFunc: _loginWtGoogle,
                  rgbBgColor: Color.fromRGBO(234, 79, 79, 1),
                  rgbColor: Color.fromRGBO(249, 249, 249, 1),
                ),
                Text(_message),
              ],
            ),
          )),
    );
  }
}
