// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkAdapter extends TypeAdapter<Work> {
  @override
  final int typeId = 1;

  @override
  Work read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Work(
      id: fields[0] as String,
      checkInTime: fields[1] as DateTime,
      checkOutTime: fields[2] as DateTime,
      // workTime: fields[3] as Duration,
      workTime: Duration(seconds: fields[3] as int), // 👈 Chuyển int thành Duration
      report: fields[4] as String,
      plan: fields[5] as String,
      note: fields[6] as String,
      userId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Work obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.checkInTime)
      ..writeByte(2)
      ..write(obj.checkOutTime)
      ..writeByte(3)
      // ..write(obj.workTime)
      ..write(obj.workTime!.inSeconds) // 👈 Lưu Duration dưới dạng int (số giây)
      ..writeByte(4)
      ..write(obj.report)
      ..writeByte(5)
      ..write(obj.plan)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
