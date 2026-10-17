import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String _message = '';

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameController.text.trim().isEmpty ||
        _surnameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      return 'Preencha todos os campos';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(_emailController.text.trim())) {
      return 'Email inválido';
    }
    if (_passwordController.text.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      return 'As senhas não conferem';
    }
    return null;
  }

  Future<void> _register() async {
    if (_isLoading) return;

    final problem = _validate();
    if (problem != null) {
      setState(() {
        _message = problem;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final hasSession = await AuthService.instance.signUp(
        name: '${_nameController.text} ${_surnameController.text}'.trim(),
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;

      if (hasSession) {
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        setState(() {
          _isLoading = false;
          _message =
              'Registro realizado! Confirma o teu email e depois faz login.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = 'Erro: ${errorMessage(e)}';
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
                  keyboardType: TextInputType.emailAddress,
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
                      label: _isLoading ? "A registar..." : "Cadastrar",
                      numWidth: 3,
                      onPressedFunc: _isLoading ? null : _register,
                      rgbBgColor: Color.fromRGBO(0, 122, 204, 1),
                      rgbColor: Color.fromRGBO(249, 249, 249, 1),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(_message, textAlign: TextAlign.center),
                ),
              ],
            ),
          )),
    );
  }
}
