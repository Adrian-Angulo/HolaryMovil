// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perfil_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerfilHiveModelAdapter extends TypeAdapter<PerfilHiveModel> {
  @override
  final int typeId = 2;

  @override
  PerfilHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerfilHiveModel(
      nombre: fields[0] as String,
      metaHorasTotal: fields[1] as double,
      fechaInicio: fields[2] as DateTime?,
      fechaFin: fields[3] as DateTime?,
      horarioSemanal: (fields[4] as Map).cast<String, HorarioDiaHiveModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PerfilHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.metaHorasTotal)
      ..writeByte(2)
      ..write(obj.fechaInicio)
      ..writeByte(3)
      ..write(obj.fechaFin)
      ..writeByte(4)
      ..write(obj.horarioSemanal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerfilHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
