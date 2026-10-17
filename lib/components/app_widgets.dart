import 'package:flutter/material.dart';

enum AppButtonVariant { filled, tonal, outlined, text }

/// Botão único da app. Altura mínima 52 e largura total por omissão.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool loading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.filled,
    this.loading = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = switch (variant) {
      AppButtonVariant.filled => scheme.onPrimary,
      AppButtonVariant.tonal => scheme.onPrimaryContainer,
      _ => scheme.primary,
    };

    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8)
              ],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final action = loading ? null : onPressed;
    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(onPressed: action, child: child),
      AppButtonVariant.tonal => FilledButton.tonal(
          onPressed: action,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
          ),
          child: child,
        ),
      AppButtonVariant.outlined =>
        OutlinedButton(onPressed: action, child: child),
      AppButtonVariant.text => TextButton(onPressed: action, child: child),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Campo de texto com ícone, rótulo flutuante e (nas senhas) botão de mostrar.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final int? maxLength;
  final String? errorText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.maxLength,
    this.errorText,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType ??
          (widget.obscure ? TextInputType.visiblePassword : TextInputType.text),
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autocorrect: !widget.obscure,
      enableSuggestions: !widget.obscure,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        counterText: '',
        prefixIcon: widget.icon == null ? null : Icon(widget.icon),
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hidden ? 'Mostrar senha' : 'Ocultar senha',
                icon: Icon(_hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}

/// Estado vazio: ícone num círculo suave, título, texto e ação opcional.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(title,
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: text.bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4)),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Avatar com as iniciais do nome (ou da primeira letra do email).
class UserAvatar extends StatelessWidget {
  final String name;
  final String? email;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    this.email,
    this.radius = 28,
  });

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) {
      return (email ?? '?').substring(0, 1).toUpperCase();
    }
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        _initials,
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
