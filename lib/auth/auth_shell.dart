import 'package:evolution_cam/configs/theme.dart';
import 'package:flutter/material.dart';

/// Estrutura comum do login e do registo: degradé da marca no topo e o
/// formulário numa folha arredondada que rola quando o teclado abre.
class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Container(
            height: 340,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.brandDeep, AppColors.brand],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/fullLogo.png',
                            width: 84,
                            height: 84,
                            semanticLabel: 'Logótipo EvolutionCam',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'EvolutionCam',
                          style: text.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Veja a sua evolução, foto a foto',
                          style: text.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 480,
                        minHeight: MediaQuery.of(context).size.height - 230,
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: MediaQuery.of(context).size.width > 520
                            ? BorderRadius.circular(AppRadius.xl + 4)
                            : const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.xl + 4),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: text.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: text.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          ...children,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensagem inline por baixo do formulário (erro ou informação).
class AuthBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const AuthBanner({super.key, required this.message, this.isError = true});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final bg = isError ? scheme.errorContainer : scheme.primaryContainer;
    final fg = isError ? scheme.onErrorContainer : scheme.onPrimaryContainer;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isError ? Icons.error_outline : Icons.info_outline,
              color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: fg))),
        ],
      ),
    );
  }
}
