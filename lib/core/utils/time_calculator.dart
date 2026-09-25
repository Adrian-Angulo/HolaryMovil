import 'package:flutter/material.dart';

class TimeCalculator {
  /// Calcula las horas computables netas en formato decimal (ej: 5.0 horas).
  /// [inicio] y [fin] deben estar en formato "HH:mm" (24h).
  static double calcularHorasNetas(
    String inicio,
    String fin, [
    int descuentoMinutos = 0,
  ]) {
    try {
      final partesIni = inicio.split(':').map(int.parse).toList();
      final partesFin = fin.split(':').map(int.parse).toList();

      if (partesIni.length != 2 || partesFin.length != 2) return 0.0;

      final minInicio = partesIni[0] * 60 + partesIni[1];
      final minFin = partesFin[0] * 60 + partesFin[1];

      final minBrutos = minFin - minInicio;
      final minNetos = minBrutos - descuentoMinutos;

      if (minNetos <= 0) return 0.0;

      return double.parse((minNetos / 60.0).toStringAsFixed(2));
    } catch (_) {
      return 0.0;
    }
  }

  /// Calcula minutos totales netos
  static int calcularMinutosNetos(
    String inicio,
    String fin, [
    int descuentoMinutos = 0,
  ]) {
    try {
      final partesIni = inicio.split(':').map(int.parse).toList();
      final partesFin = fin.split(':').map(int.parse).toList();

      final minInicio = partesIni[0] * 60 + partesIni[1];
      final minFin = partesFin[0] * 60 + partesFin[1];

      final minNetos = (minFin - minInicio) - descuentoMinutos;
      return minNetos > 0 ? minNetos : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Convierte un TimeOfDay a formato string "HH:mm"
  static String formatTimeOfDay(TimeOfDay time) {
    final hora = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hora:$min';
  }

  /// Convierte un string "HH:mm" a TimeOfDay
  static TimeOfDay parseTimeOfDay(String timeStr, {TimeOfDay defaultTime = const TimeOfDay(hour: 8, minute: 0)}) {
    try {
      final partes = timeStr.split(':').map(int.parse).toList();
      return TimeOfDay(hour: partes[0], minute: partes[1]);
    } catch (_) {
      return defaultTime;
    }
  }

  /// Formatea horas decimales a texto legible como "5h 30m" o "5 h"
  static String formatHorasHumanReadable(double horasDecimales) {
    if (horasDecimales <= 0) return '0 hrs';
    final horas = horasDecimales.floor();
    final minutos = ((horasDecimales - horas) * 60).round();
    
    if (minutos == 0) {
      return '$horas h';
    }
    return '${horas}h ${minutos}m';
  }

  /// Verifica si dos rangos de horas ("HH:mm") en el mismo día se solapan.
  static bool haySolapamiento(
    String inicioA,
    String finA,
    String inicioB,
    String finB,
  ) {
    try {
      final pIniA = inicioA.split(':').map(int.parse).toList();
      final pFinA = finA.split(':').map(int.parse).toList();
      final pIniB = inicioB.split(':').map(int.parse).toList();
      final pFinB = finB.split(':').map(int.parse).toList();

      if (pIniA.length != 2 || pFinA.length != 2 || pIniB.length != 2 || pFinB.length != 2) {
        return false;
      }

      final minIniA = pIniA[0] * 60 + pIniA[1];
      final minFinA = pFinA[0] * 60 + pFinA[1];
      final minIniB = pIniB[0] * 60 + pIniB[1];
      final minFinB = pFinB[0] * 60 + pFinB[1];

      return (minIniA < minFinB) && (minFinA > minIniB);
    } catch (_) {
      return false;
    }
  }
}
