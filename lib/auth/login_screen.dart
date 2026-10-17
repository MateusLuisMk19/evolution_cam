import 'package:evolution_cam/auth/auth_shell.dart';
import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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
      setState(() => _message = 'Preencha o email e a senha');
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
        _message = errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Bem-vindo de volta',
      subtitle: 'Entre para continuar a sua evolução.',
      children: [
        AuthBanner(message: _message),
        AppTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _passwordController,
          label: 'Senha',
          icon: Icons.lock_outline,
          obscure: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Entrar',
          loading: _isLoading,
          onPressed: _login,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Criar conta',
          variant: AppButtonVariant.text,
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).pushNamed('/register'),
        ),
      ],
    );
  }
}
