import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:practi_horas_app/features/registros/domain/entities/registro_hora.dart';
import 'package:share_plus/share_plus.dart';

import 'date_formatters.dart';

class CsvExporter {
  /// Genera el contenido del archivo CSV con el formato exacto requerido:
  /// Fecha | Hora de inicio | Hora de Fin | Resumen actividades realizada | Horas realizadas | Horas totales Sumatoria (∑)
  static String generarCsvString({
    required List<RegistroHora> registros,
    double horasInicialesPrevias = 0.0,
  }) {
    final buffer = StringBuffer();

    // UTF-8 BOM para que Excel reconozca tildes, caracteres especiales y el símbolo ∑
    buffer.write('\uFEFF');

    // Encabezados con delimitador estándar coma (y entrecomillado para compatibilidad universal)
    buffer.writeln(
      'Fecha,Hora de inicio,Hora de Fin,Resumen actividades realizada,Horas realizadas,Horas totales Sumatoria (∑)',
    );

    // Ordenar registros en orden cronológico ascendente para la sumatoria acumulativa
    final registrosOrdenados = List<RegistroHora>.from(registros)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    double sumatoriaAcumulada = horasInicialesPrevias;

    // Si hay horas iniciales previas convalidadas, registrar una fila inicial informativa
    if (horasInicialesPrevias > 0) {
      buffer.writeln(
        'Inicial,-,-,"Horas previas cursadas (convalidadas en ajustes)",${horasInicialesPrevias.toStringAsFixed(2)},${sumatoriaAcumulada.toStringAsFixed(2)}',
      );
    }

    for (final reg in registrosOrdenados) {
      sumatoriaAcumulada += reg.horasComputables;
      sumatoriaAcumulada = double.parse(sumatoriaAcumulada.toStringAsFixed(2));

      final fechaStr = DateFormatters.fechaCorta(reg.fecha);
      final horaIniStr = reg.horaInicio;
      final horaFinStr = reg.horaFin;
      
      // Escapar actividades para CSV (reemplazar comillas dobles y entrecomillar texto)
      final actividadesLimpias = reg.actividades.isEmpty
          ? 'Jornada laboral de prácticas'
          : reg.actividades.replaceAll('"', '""').replaceAll('\n', ' ');
      
      final horasRealizadas = reg.horasComputables.toStringAsFixed(2);
      final sumatoriaStr = sumatoriaAcumulada.toStringAsFixed(2);

      buffer.writeln(
        '$fechaStr,$horaIniStr,$horaFinStr,"$actividadesLimpias",$horasRealizadas,$sumatoriaStr',
      );
    }

    return buffer.toString();
  }

  /// Guarda el archivo CSV en el dispositivo y abre el diálogo nativo para compartir/guardar
  static Future<void> exportarYCompartirCsv({
    required List<RegistroHora> registros,
    double horasInicialesPrevias = 0.0,
    String nombrePracticante = 'Practicante',
  }) async {
    final csvContent = generarCsvString(
      registros: registros,
      horasInicialesPrevias: horasInicialesPrevias,
    );

    final tempDir = await getTemporaryDirectory();
    final fechaHoy = DateTime.now();
    final fechaHoyStr = '${fechaHoy.year}_${fechaHoy.month.toString().padLeft(2, '0')}_${fechaHoy.day.toString().padLeft(2, '0')}';
    final nombreArchivo = 'Reporte_Horas_${nombrePracticante.replaceAll(' ', '_')}_$fechaHoyStr.csv';

    final file = File('${tempDir.path}/$nombreArchivo');
    await file.writeAsString(csvContent);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      text: 'Reporte de Horas de Prácticas - $nombrePracticante',
      subject: 'Reporte de Horas CSV - $nombrePracticante',
    );
  }

  static Future<void> exportarYCompartir(
    List<RegistroHora> registros, {
    String nombreEstudiante = 'Practicante',
    double horasPrevias = 0.0,
  }) {
    return exportarYCompartirCsv(
      registros: registros,
      horasInicialesPrevias: horasPrevias,
      nombrePracticante: nombreEstudiante,
    );
  }

  /// Copia el contenido CSV al portapapeles
  static Future<void> copiarCsvAlPortapapeles({
    required List<RegistroHora> registros,
    double horasInicialesPrevias = 0.0,
  }) async {
    final csvContent = generarCsvString(
      registros: registros,
      horasInicialesPrevias: horasInicialesPrevias,
    );

    await Clipboard.setData(ClipboardData(text: csvContent));
  }
}
