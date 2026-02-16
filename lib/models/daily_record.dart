import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class DailyRecord {
  @HiveField(0)
  final int day;
  @HiveField(1)
  final List<String> completedActivityIds;
  @HiveField(2)
  final String? note;
  @HiveField(3)
  final Map<String, dynamic>? quranData;
  @HiveField(4)
  final String? mood;

  DailyRecord({
    required this.day,
    required this.completedActivityIds,
    this.note,
    this.quranData,
    this.mood,
  });

  DailyRecord copyWith({
    int? day,
    List<String>? completedActivityIds,
    String? note,
    Map<String, dynamic>? quranData,
    String? mood,
  }) {
    return DailyRecord(
      day: day ?? this.day,
      completedActivityIds: completedActivityIds ?? this.completedActivityIds,
      note: note ?? this.note,
      quranData: quranData ?? this.quranData,
      mood: mood ?? this.mood,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'completedActivityIds': completedActivityIds,
      'note': note,
      'quranData': quranData,
      'mood': mood,
    };
  }

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      day: json['day'] as int,
      completedActivityIds: (json['completedActivityIds'] as List)
          .cast<String>(),
      note: json['note'] as String?,
      quranData: json['quranData'] as Map<String, dynamic>?,
      mood: json['mood'] as String?,
    );
  }
}

class DailyRecordAdapter extends TypeAdapter<DailyRecord> {
  @override
  final int typeId = 0;

  @override
  DailyRecord read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecord(
      day: fields[0] as int,
      completedActivityIds: (fields[1] as List).cast<String>(),
      note: fields[2] as String?,
      quranData: (fields[3] as Map?)?.cast<String, dynamic>(),
      mood: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecord obj) {
    writer
      ..writeByte(5) // Updated count
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.completedActivityIds)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.quranData)
      ..writeByte(4)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
