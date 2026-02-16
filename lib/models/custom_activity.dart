import 'package:hive/hive.dart';

part 'custom_activity.g.dart';

@HiveType(typeId: 1)
class CustomActivity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String category;

  CustomActivity({
    required this.id,
    required this.title,
    required this.category,
  });
}
