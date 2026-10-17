import 'dart:io';

import 'package:evolution_cam/components/app_widgets.dart';
import 'package:evolution_cam/components/feedback.dart';
import 'package:evolution_cam/configs/theme.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:evolution_cam/services/collection_service.dart';
import 'package:flutter/material.dart';

/// Pré-visualização da foto antes de a enviar para a coleção.
class AddImageScreen extends StatefulWidget {
  const AddImageScreen({super.key});

  @override
  State<AddImageScreen> createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  late String collectionId;
  late File image;
  double? _tiltRoll, _tiltPitch, _zoom;
  bool _started = false;
  bool _uploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    collectionId = args['collectionId'] as String;
    image = File(args['imagePath'] as String);
    _tiltRoll = args['tiltRoll'] as double?;
    _tiltPitch = args['tiltPitch'] as double?;
    _zoom = args['zoom'] as double?;
  }

  Future<void> _upload() async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      await CollectionService.instance.addImage(
        collectionId,
        image,
        tiltRoll: _tiltRoll,
        tiltPitch: _tiltPitch,
        zoom: _zoom,
      );
      if (!mounted) return;
      showAppSnack(context, 'Foto adicionada');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      showAppSnack(context, 'Erro ao enviar a foto: ${errorMessage(e)}',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_uploading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Nova foto')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Container(
                      width: double.infinity,
                      color: scheme.surfaceContainerHigh,
                      child: Image.file(image, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancelar',
                        variant: AppButtonVariant.outlined,
                        onPressed: _uploading
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Adicionar',
                        icon: Icons.check,
                        loading: _uploading,
                        onPressed: _upload,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
