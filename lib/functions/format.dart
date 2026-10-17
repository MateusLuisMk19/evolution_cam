String _two(int n) => n.toString().padLeft(2, '0');

/// 17/10/2026
String formatDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// 17/10/2026 · 03:09
String formatDateTime(DateTime d) =>
    '${formatDate(d)} · ${_two(d.hour)}:${_two(d.minute)}';

/// 'Sem fotos', '1 foto', '5 fotos'
String photoCount(int n) => n == 0
    ? 'Sem fotos'
    : n == 1
        ? '1 foto'
        : '$n fotos';
