// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveAdapter extends TypeAdapter<Leave> {
  @override
  final int typeId = 0;

  @override
  Leave read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Leave(
      id: fields[0] as String,
      dateCreated: fields[1] as DateTime,
      startDate: fields[2] as DateTime,
      endDate: fields[3] as DateTime,
      leaveType: fields[4] as String,
      leaveTimeType: fields[5] as String,
      reason: fields[6] as String,
      status: fields[7] as String,
      userId: fields[8] as String,
      isNew: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Leave obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateCreated)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.leaveType)
      ..writeByte(5)
      ..write(obj.leaveTimeType)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.isNew);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
