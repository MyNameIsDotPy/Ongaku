const _weekdays = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];
const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', //
  'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

/// "lunes, 5 de octubre".
String longDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} de ${_months[d.month - 1]}';

/// "5 oct".
String shortDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1].substring(0, 3)}';

/// "Hoy", "Ayer" or "sábado, 3 oct".
String dayLabel(DateTime d, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  return '${_weekdays[d.weekday - 1]}, ${shortDate(d)}';
}

String hourMinute(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  return h < 12
      ? 'Buenos días'
      : h < 19
      ? 'Buenas tardes'
      : 'Buenas noches';
}
