import 'package:intl/intl.dart';

class DateFormatters {
  /// Devuelve la fecha formateada en español, ej: "Lunes, 22 Sep 2026"
  static String fechaCompleta(DateTime fecha) {
    return DateFormat('EEEE, d MMM y', 'es').format(fecha);
  }

  /// Devuelve fecha corta, ej: "22/09/2026"
  static String fechaCorta(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  /// Devuelve el día y mes abreviado, ej: "22 Sep"
  static String diaMes(DateTime fecha) {
    return DateFormat('d MMM', 'es').format(fecha);
  }

  /// Devuelve el nombre del día en minúscula normalizado: 'lunes', 'martes', etc.
  static String getDiaSemanaKey(DateTime fecha) {
    switch (fecha.weekday) {
      case DateTime.monday:
        return 'lunes';
      case DateTime.tuesday:
        return 'martes';
      case DateTime.wednesday:
        return 'miercoles';
      case DateTime.thursday:
        return 'jueves';
      case DateTime.friday:
        return 'viernes';
      case DateTime.saturday:
        return 'sabado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return 'lunes';
    }
  }

  /// Devuelve el nombre amigable en español del día
  static String getDiaNombre(String diaKey) {
    switch (diaKey.toLowerCase()) {
      case 'lunes':
        return 'Lunes';
      case 'martes':
        return 'Martes';
      case 'miercoles':
        return 'Miércoles';
      case 'jueves':
        return 'Jueves';
      case 'viernes':
        return 'Viernes';
      case 'sabado':
        return 'Sábado';
      case 'domingo':
        return 'Domingo';
      default:
        return diaKey;
    }
  }

  /// Abreviación para gráficas: Lun, Mar, Mié, Jue, Vie, Sáb, Dom
  static String getDiaAbbr(int weekdayIndex) {
    switch (weekdayIndex) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mié';
      case 4:
        return 'Jue';
      case 5:
        return 'Vie';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  /// Retorna el rango de fechas de la semana actual (Lunes a Domingo)
  static DateTimeRange getSemanaActualRange([DateTime? fechaReferencia]) {
    final now = fechaReferencia ?? DateTime.now();
    final lunes = now.subtract(Duration(days: now.weekday - 1));
    final inicioSemana = DateTime(lunes.year, lunes.month, lunes.day, 0, 0, 0);
    final domingo = inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return DateTimeRange(start: inicioSemana, end: domingo);
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});
}
