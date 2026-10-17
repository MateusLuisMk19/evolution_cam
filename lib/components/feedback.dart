import 'package:flutter/material.dart';

/// Aviso rápido no fundo do ecrã. `error: true` usa as cores de erro.
void showAppSnack(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(12),
        backgroundColor: error ? scheme.errorContainer : null,
        content: Text(
          message,
          style: error ? TextStyle(color: scheme.onErrorContainer) : null,
        ),
      ),
    );
}

/// Pergunta de confirmação. Devolve `true` só se o utilizador confirmar.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool destructive = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  minimumSize: const Size(96, 48),
                )
              : FilledButton.styleFrom(minimumSize: const Size(96, 48)),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Diálogo com um campo de texto. Devolve o texto (sem espaços nas pontas) ou
/// `null` se for cancelado ou ficar vazio.
Future<String?> promptDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  String confirmLabel = 'Salvar',
  IconData? icon,
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => _PromptDialog(
      title: title,
      label: label,
      initial: initial,
      confirmLabel: confirmLabel,
      icon: icon,
    ),
  );
  return (result == null || result.isEmpty) ? null : result;
}

/// O diálogo é dono do controlador: só o liberta quando sai da árvore, depois
/// da animação de saída (libertá-lo antes causa erros no campo de texto).
class _PromptDialog extends StatefulWidget {
  final String title;
  final String label;
  final String initial;
  final String confirmLabel;
  final IconData? icon;

  const _PromptDialog({
    required this.title,
    required this.label,
    required this.initial,
    required this.confirmLabel,
    required this.icon,
  });

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.icon == null ? null : Icon(widget.icon),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
