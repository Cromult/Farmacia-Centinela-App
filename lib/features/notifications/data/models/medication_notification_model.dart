import 'package:hive/hive.dart';

part 'medication_notification_model.g.dart';

@HiveType(typeId: 0)
class MedicationNotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dosage;

  @HiveField(3)
  final DateTime scheduledTime;

  @HiveField(4)
  final String? status;

  MedicationNotificationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.scheduledTime,
    this.status,
  });
}
