import 'package:evolution_cam/configs/camera_settings.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:flutter/material.dart';

// O ecrã da câmera é sempre escuro, por isso estes tons não seguem o tema.
const _camActive = Color(0xFF6BC4FF);

/// Botão redondo e escuro para usar por cima do preview (alvo de 48dp).
class CamButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;
  final Color? activeColor;
  final Widget? badge;

  const CamButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
    this.activeColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final tint = active ? (activeColor ?? _camActive) : Colors.white;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filled(
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black54,
            foregroundColor: tint,
            fixedSize: const Size(48, 48),
          ),
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        if (badge != null) Positioned(right: -2, top: -2, child: badge!),
      ],
    );
  }
}

/// Abre as definições da câmera. `settings` é atualizado em direto.
Future<void> showCameraSettings(
  BuildContext context,
  CameraSettings settings, {
  required bool hasReference,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: darkTheme.colorScheme.surfaceContainerHigh,
    showDragHandle: true,
    useSafeArea: true,
    builder: (sheetContext) => Theme(
      data: darkTheme,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => _CameraSettingsSheet(
          settings: settings,
          hasReference: hasReference,
        ),
      ),
    ),
  );
}

class _CameraSettingsSheet extends StatelessWidget {
  final CameraSettings settings;
  final bool hasReference;

  const _CameraSettingsSheet({
    required this.settings,
    required this.hasReference,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(title,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Definições da câmera',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          Text('Ficam guardadas para a próxima vez.', style: text.bodySmall),
          section('Temporizador'),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final t in CameraSettings.timerOptions)
                  ButtonSegment(
                    value: t,
                    label: Text(t == 0 ? 'Desligado' : '$t s'),
                  ),
              ],
              selected: {settings.timer},
              onSelectionChanged: (v) => settings.setTimer(v.first),
            ),
          ),
          if (hasReference) ...[
            section('Tipo de captura'),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<RefMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: RefMode.edges,
                    icon: Icon(Icons.border_style, size: 18),
                    label: Text('Contorno'),
                  ),
                  ButtonSegment(
                    value: RefMode.ghost,
                    icon: Icon(Icons.layers_outlined, size: 18),
                    label: Text('Fantasma'),
                  ),
                  ButtonSegment(
                    value: RefMode.split,
                    icon: Icon(Icons.vertical_split_outlined, size: 18),
                    label: Text('Cortina'),
                  ),
                ],
                selected: {settings.mode},
                onSelectionChanged: (v) => settings.setMode(v.first),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              switch (settings.mode) {
                RefMode.edges =>
                  'Desenha as linhas da foto anterior sobre o vídeo.',
                RefMode.ghost => 'Mostra a foto anterior semitransparente.',
                RefMode.split =>
                  'Foto anterior à esquerda e vídeo à direita da linha.',
              },
              style: text.bodySmall,
            ),
            if (settings.mode == RefMode.ghost) ...[
              section('Transparência da foto anterior'),
              Slider(
                min: 0.1,
                max: 1,
                value: settings.ghostOpacity,
                onChanged: settings.setGhostOpacity,
              ),
            ],
          ],
          section('Ajudas'),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text('Grelha'),
            subtitle: const Text('Linhas dos terços para enquadrar'),
            value: settings.grid,
            onChanged: settings.setGrid,
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text('Ângulos'),
            subtitle: const Text('Nível e graus de inclinação'),
            value: settings.angles,
            onChanged: settings.setAngles,
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: const Text('Setas de direção'),
            subtitle: const Text('Setas que mostram para onde inclinar'),
            value: settings.arrows,
            onChanged: settings.setArrows,
          ),
        ],
      ),
    );
  }
}

/// Barra inferior: flash, obturador e trocar de câmera.
class CameraActionBar extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleFlash;
  final bool isFlashOn;
  final bool busy;

  const CameraActionBar({
    super.key,
    required this.onCapture,
    required this.onToggleCamera,
    required this.onToggleFlash,
    required this.isFlashOn,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CamButton(
          icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
          tooltip: isFlashOn ? 'Desligar lanterna' : 'Ligar lanterna',
          active: isFlashOn,
          activeColor: Colors.amber,
          onPressed: busy ? null : onToggleFlash,
        ),
        Semantics(
          button: true,
          label: 'Tirar foto',
          child: GestureDetector(
            onTap: busy ? null : onCapture,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: busy ? 0.5 : 1,
              child: Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        CamButton(
          icon: Icons.flip_camera_android_outlined,
          tooltip: 'Trocar de câmera',
          onPressed: busy ? null : onToggleCamera,
        ),
      ],
    );
  }
}

class TimerOverlay extends StatelessWidget {
  final int seconds;

  const TimerOverlay({Key? key, required this.seconds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$seconds',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class FocusIndicator extends StatefulWidget {
  const FocusIndicator({Key? key}) : super(key: key);

  @override
  State<FocusIndicator> createState() => _FocusIndicatorState();
}

class _FocusIndicatorState extends State<FocusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.8).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
