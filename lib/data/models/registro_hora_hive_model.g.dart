// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_hora_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegistroHoraHiveModelAdapter extends TypeAdapter<RegistroHoraHiveModel> {
  @override
  final int typeId = 0;

  @override
  RegistroHoraHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegistroHoraHiveModel(
      id: fields[0] as String,
      fecha: fields[1] as DateTime,
      horaInicio: fields[2] as String,
      horaFin: fields[3] as String,
      descuentoAlmuerzoMinutos: fields[4] as int,
      horasComputables: fields[5] as double,
      modalidad: fields[6] as String,
      actividades: fields[7] as String,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RegistroHoraHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fecha)
      ..writeByte(2)
      ..write(obj.horaInicio)
      ..writeByte(3)
      ..write(obj.horaFin)
      ..writeByte(4)
      ..write(obj.descuentoAlmuerzoMinutos)
      ..writeByte(5)
      ..write(obj.horasComputables)
      ..writeByte(6)
      ..write(obj.modalidad)
      ..writeByte(7)
      ..write(obj.actividades)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistroHoraHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
