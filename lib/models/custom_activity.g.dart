// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_activity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomActivityAdapter extends TypeAdapter<CustomActivity> {
  @override
  final int typeId = 1;

  @override
  CustomActivity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomActivity(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomActivity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomActivityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
