import 'package:hive_flutter/hive_flutter.dart';
import '../models/medication_notification_model.dart';

class NotificationLocalDataSource {
  static const String _boxName = 'medication_notifications';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicationNotificationModelAdapter());
    }
    await Hive.openBox<MedicationNotificationModel>(_boxName);
  }

  Future<void> saveNextMedication(MedicationNotificationModel model) async {
    final box = Hive.box<MedicationNotificationModel>(_boxName);
    await box.put('next_medication', model);
    print('[Hive] ✅ Guardado en caché: ${model.name} (${model.scheduledTime})');
  }

  MedicationNotificationModel? getNextMedication() {
    final box = Hive.box<MedicationNotificationModel>(_boxName);
    final data = box.get('next_medication');
    if (data != null) {
      print('[Hive] 📖 Cargado desde caché: ${data.name}');
    } else {
      print('[Hive] ⚠️ El caché está vacío');
    }
    return data;
  }

  Future<void> clearCache() async {
    final box = Hive.box<MedicationNotificationModel>(_boxName);
    await box.clear();
  }
}
