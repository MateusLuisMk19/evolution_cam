import 'dart:convert';

import 'package:evolution_cam/components/camera_components.dart';
import 'package:evolution_cam/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências da câmera, guardadas por utilizador neste aparelho.
class CameraSettings extends ChangeNotifier {
  /// Segundos de espera antes da foto; 0 = desligado.
  int _timer = 0;
  bool _grid = false;
  RefMode _mode = RefMode.edges;
  bool _angles = true;
  bool _arrows = true;
  double _ghostOpacity = 0.5;

  int get timer => _timer;
  bool get grid => _grid;
  RefMode get mode => _mode;
  bool get angles => _angles;
  bool get arrows => _arrows;
  double get ghostOpacity => _ghostOpacity;

  static const timerOptions = [0, 3, 5, 10];

  String get _key => 'camera_settings_${AuthService.instance.userId}';

  Future<void> load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final timer = map['timer'];
      _timer = timerOptions.contains(timer) ? timer as int : 0;
      _grid = map['grid'] == true;
      final mode = map['mode'];
      _mode = RefMode.values.firstWhere(
        (m) => m.name == mode,
        orElse: () => RefMode.edges,
      );
      _angles = map['angles'] != false;
      _arrows = map['arrows'] != false;
      final opacity = map['ghostOpacity'];
      if (opacity is num) _ghostOpacity = opacity.toDouble().clamp(0.1, 1.0);
      notifyListeners();
    } catch (_) {
      // definições ilegíveis: ficam as predefinidas
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode({
          'timer': _timer,
          'grid': _grid,
          'mode': _mode.name,
          'angles': _angles,
          'arrows': _arrows,
          'ghostOpacity': _ghostOpacity,
        }),
      );
    } catch (_) {
      // sem armazenamento: vale só para esta sessão
    }
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  void setTimer(int v) {
    _timer = v;
    _changed();
  }

  void setGrid(bool v) {
    _grid = v;
    _changed();
  }

  void setMode(RefMode v) {
    _mode = v;
    _changed();
  }

  void setAngles(bool v) {
    _angles = v;
    _changed();
  }

  void setArrows(bool v) {
    _arrows = v;
    _changed();
  }

  void setGhostOpacity(double v) {
    _ghostOpacity = v;
    _changed();
  }
}
