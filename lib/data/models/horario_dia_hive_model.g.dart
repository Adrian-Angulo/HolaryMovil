// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horario_dia_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HorarioDiaHiveModelAdapter extends TypeAdapter<HorarioDiaHiveModel> {
  @override
  final int typeId = 1;

  @override
  HorarioDiaHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HorarioDiaHiveModel(
      diaSemana: fields[0] as String,
      activo: fields[1] as bool,
      horaInicio: fields[2] as String,
      horaFin: fields[3] as String,
      refrigerioMinutos: fields[4] as int,
      modalidad: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HorarioDiaHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.diaSemana)
      ..writeByte(1)
      ..write(obj.activo)
      ..writeByte(2)
      ..write(obj.horaInicio)
      ..writeByte(3)
      ..write(obj.horaFin)
      ..writeByte(4)
      ..write(obj.refrigerioMinutos)
      ..writeByte(5)
      ..write(obj.modalidad);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorarioDiaHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
