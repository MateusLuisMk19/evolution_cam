import 'package:evolution_cam/components/components.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Preencha o email e a senha';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      await AuthService.instance
          .signIn(_emailController.text, _passwordController.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
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
                  fieldController: _emailController,
                  placeholder: "Email",
                  radius: 15,
                  context: context,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  fieldController: _passwordController,
                  placeholder: "Senha",
                  radius: 15,
                  context: context,
                  isObscured: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
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
                        label: _isLoading ? "A entrar..." : "Entrar",
                        numWidth: 3,
                        onPressedFunc: _isLoading ? null : _login,
                        rgbBgColor: Color.fromRGBO(0, 122, 204, 1),
                        rgbColor: Color.fromRGBO(249, 249, 249, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          )),
    );
  }
}
