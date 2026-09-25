import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../features/perfil/domain/entities/perfil.dart';
import '../../features/registros/domain/entities/registro_hora.dart';
import 'date_formatters.dart';

class PdfExporter {
  /// Genera y comparte el PDF oficial de convalidación con firmas
  static Future<void> exportarYCompartirPdf({
    required List<RegistroHora> registros,
    required Perfil perfil,
    String? email,
  }) async {
    final pdf = pw.Document();

    // Ordenar cronológicamente
    final ordenados = List<RegistroHora>.from(registros)
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    final totalHorasRegistradas = ordenados.fold<double>(
      0.0,
      (prev, r) => prev + r.horasComputables,
    );
    final totalAcumulado = totalHorasRegistradas + perfil.horasInicialesPrevias;
    final porcentaje = perfil.metaHorasTotal > 0
        ? ((totalAcumulado / perfil.metaHorasTotal) * 100).clamp(0, 100)
        : 0.0;

    final primaryColor = PdfColor.fromHex('#4F46E5');
    final secondaryColor = PdfColor.fromHex('#1E1B4B');
    final grayLight = PdfColor.fromHex('#F8FAFC');
    final grayBorder = PdfColor.fromHex('#CBD5E1');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'CONTROL DE PRÁCTICAS PRE-PROFESIONALES',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  'Generado el ${DateFormatters.fechaCompleta(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Horaly • Control Inteligente de Prácticas',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
                pw.Text(
                  'Página ${context.pageNumber} de ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) => [
          // 1. TÍTULO PRINCIPAL
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'FICHA OFICIAL DE CONVALIDACIÓN DE HORAS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: secondaryColor,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Registro detallado de actividades y horas acumuladas de prácticas',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // 2. DATOS DEL ESTUDIANTE Y CONVENIO
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: grayLight,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: grayBorder, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: _buildInfoItem(
                        'Estudiante / Practicante:',
                        perfil.nombre,
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: _buildInfoItem(
                        'Correo Electrónico:',
                        email ?? 'No especificado',
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: _buildInfoItem(
                        'Carrera / Especialidad:',
                        perfil.carrera,
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: _buildInfoItem(
                        'Semestre / Ciclo:',
                        perfil.semestre,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: _buildInfoItem(
                        'Período de Prácticas:',
                        perfil.fechaInicio != null && perfil.fechaFin != null
                            ? '${DateFormatters.fechaCorta(perfil.fechaInicio!)} — ${DateFormatters.fechaCorta(perfil.fechaFin!)}'
                            : 'No definido',
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: _buildInfoItem(
                        'Meta Requerida:',
                        '${perfil.metaHorasTotal.toStringAsFixed(0)} hrs',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          // 3. RESUMEN DE CUMPLIMIENTO (KPIs)
          pw.Row(
            children: [
              _buildKpiBox(
                'Horas Previas',
                '${perfil.horasInicialesPrevias.toStringAsFixed(1)} h',
                PdfColors.blueGrey800,
              ),
              pw.SizedBox(width: 8),
              _buildKpiBox(
                'Horas en Sede',
                '${totalHorasRegistradas.toStringAsFixed(1)} h',
                PdfColors.indigo800,
              ),
              pw.SizedBox(width: 8),
              _buildKpiBox(
                'Total Acumulado',
                '${totalAcumulado.toStringAsFixed(1)} h',
                PdfColors.green800,
              ),
              pw.SizedBox(width: 8),
              _buildKpiBox(
                'Avance Meta',
                '${porcentaje.toStringAsFixed(1)}%',
                primaryColor,
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // 4. TABLA DE JORNADAS
          pw.Text(
            'DETALLE CRONOLÓGICO DE JORNADAS LABORALES',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: secondaryColor,
            ),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: [
              'N°',
              'Fecha',
              'Entrada',
              'Salida',
              'Refrig.',
              'Horas',
              'Modalidad',
              'Actividades Realizadas',
            ],
            data: List<List<dynamic>>.generate(ordenados.length, (index) {
              final reg = ordenados[index];
              return [
                '${index + 1}',
                DateFormatters.fechaCorta(reg.fecha),
                reg.horaInicio,
                reg.horaFin,
                reg.descuentoAlmuerzoMinutos > 0
                    ? '${reg.descuentoAlmuerzoMinutos}m'
                    : '-',
                '${reg.horasComputables.toStringAsFixed(2)} h',
                reg.modalidad,
                reg.actividades.isNotEmpty
                    ? reg.actividades
                    : 'Jornada laboral de prácticas',
              ];
            }),
            border: pw.TableBorder.all(color: grayBorder, width: 0.5),
            headerStyle: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: primaryColor),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.center,
              7: pw.Alignment.centerLeft,
            },
            cellStyle: const pw.TextStyle(fontSize: 7.5),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 4,
            ),
          ),

          pw.SizedBox(height: 35),

          // 5. SECCIÓN DE FIRMAS Y CONFORMIDAD
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Firma Estudiante
                pw.Container(
                  width: 220,
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 45,
                        alignment: pw.Alignment.bottomCenter,
                        child: pw.Container(
                          width: 180,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                color: PdfColors.black,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        perfil.nombre,
                        style: const pw.TextStyle(
                          fontSize: 9,
                        ),
                      ),
                      pw.Text(
                        'Firma del Practicante',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Firma Supervisor / Encargado
                pw.Container(
                  width: 220,
                  child: pw.Column(
                    children: [
                      pw.Container(
                        height: 45,
                        alignment: pw.Alignment.bottomCenter,
                        child: pw.Container(
                          width: 180,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                color: PdfColors.black,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Supervisor / Encargado de Prácticas',
                        style: const pw.TextStyle(
                          fontSize: 9,
                        ),
                      ),
                      pw.Text(
                        'Firma y Sello de la Empresa / Institución',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Guardar archivo y compartir
    final tempDir = await getTemporaryDirectory();
    final fechaHoy = DateTime.now();
    final fechaStr =
        '${fechaHoy.year}_${fechaHoy.month.toString().padLeft(2, '0')}_${fechaHoy.day.toString().padLeft(2, '0')}';
    final nombreSanitizado =
        perfil.nombre.trim().replaceAll(RegExp(r'\s+'), '_');
    final nombreArchivo = 'Ficha_Practicas_${nombreSanitizado}_$fechaStr.pdf';

    final file = File('${tempDir.path}/$nombreArchivo');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      text: 'Ficha Oficial de Control de Prácticas - ${perfil.nombre}',
      subject: 'Ficha de Convalidación PDF - ${perfil.nombre}',
    );
  }

  static pw.Widget _buildInfoItem(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        text: '$label ',
        style: const pw.TextStyle(
          fontSize: 8,
          color: PdfColors.grey800,
        ),
        children: [
          pw.TextSpan(
            text: value,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildKpiBox(String title, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: color, width: 0.8),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
