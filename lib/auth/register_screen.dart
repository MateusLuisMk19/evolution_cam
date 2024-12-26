import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evolution_cam/components/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String _message = '';

  Future<void> _register() async {
    if (_nameController.text == '' ||
        _surnameController.text == '' ||
        _emailController.text == '' ||
        _passwordController.text == '' ||
        _passwordConfirmController.text == '') {
      setState(() {
        _message = 'Preencha todos os campos';
      });
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() {
        _message = 'As senhas não conferem';
      });
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _auth.currentUser!.updateProfile(
          displayName: '${_nameController.text} ${_surnameController.text}');

      await _firestore.collection('categorias').add({
        'uid': _auth.currentUser?.uid,
        'list': ["Paisagem", "Limpeza", "Construção"]
      });

      setState(() {
        _message = 'Registro realizado com sucesso!';
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
      body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/fullLogo.png'),
                  width: 130,
                  height: 130,
                ),
                SizedBox(height: 25),
                CustomTextField(
                  fieldController: _nameController,
                  placeholder: "Nome",
                  radius: 15,
                  context: context,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  fieldController: _surnameController,
                  placeholder: "Sobrenome",
                  radius: 15,
                  context: context,
                ),
                SizedBox(height: 15),
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
                SizedBox(height: 15),
                CustomTextField(
                  fieldController: _passwordConfirmController,
                  placeholder: "Confirmar Senha",
                  radius: 15,
                  context: context,
                  isObscured: true,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomBtn(
                      context: context,
                      label: "Cancelar",
                      numWidth: 3,
                      onPressedFunc: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      rgbBgColor: Color.fromRGBO(111, 195, 223, 1),
                      rgbColor: Color.fromRGBO(51, 51, 51, 1),
                    ),
                    SizedBox(height: 10),
                    CustomBtn(
                      context: context,
                      label: "Registar",
                      numWidth: 3,
                      onPressedFunc: _register,
                      rgbBgColor: Color.fromRGBO(0, 122, 204, 1),
                      rgbColor: Color.fromRGBO(249, 249, 249, 1),
                    ),
                  ],
                ),
                Text(_message),
              ],
            ),
          )),
    );
  }
}
