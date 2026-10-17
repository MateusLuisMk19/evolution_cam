import 'package:evolution_cam/auth/auth_shell.dart';
import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  String _message = '';
  bool _messageIsError = true;
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
        _messageIsError = true;
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
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      } else {
        setState(() {
          _isLoading = false;
          _messageIsError = false;
          _message = 'Conta criada! Confirme o seu email e depois faça login.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messageIsError = true;
        _message = errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Criar conta',
      subtitle: 'Leva menos de um minuto.',
      children: [
        AuthBanner(message: _message, isError: _messageIsError),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _nameController,
                label: 'Nome',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _surnameController,
                label: 'Sobrenome',
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: _passwordConfirmController,
          label: 'Confirmar senha',
          icon: Icons.lock_outline,
          obscure: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _register(),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Criar conta',
          loading: _isLoading,
          onPressed: _register,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Já tenho conta',
          variant: AppButtonVariant.text,
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
