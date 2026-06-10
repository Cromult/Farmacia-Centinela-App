import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/data/models/dashboard_model.dart';
import '../../data/datasources/notification_local_data_source.dart';
import '../../data/models/medication_notification_model.dart';
import '../../../../core/services/notification_service.dart';

final notificationLocalDataSourceProvider = Provider((ref) => NotificationLocalDataSource());

final notificationProvider = Provider((ref) {
  final localDataSource = ref.watch(notificationLocalDataSourceProvider);
  final service = NotificationService();
  return NotificationManager(localDataSource, service);
});

class NotificationManager {
  final NotificationLocalDataSource localDataSource;
  final NotificationService service;

  NotificationManager(this.localDataSource, this.service);

  Future<void> syncNotifications(DashboardModel dashboard) async {
    final nextMed = dashboard.nextMedication;
    
    if (nextMed != null) {
      // 1. Guardar en Hive para Offline-First
      final model = MedicationNotificationModel(
        id: nextMed.id,
        name: nextMed.nombre,
        dosage: nextMed.dosis,
        scheduledTime: nextMed.nextTakeAt,
        status: nextMed.status,
      );
      await localDataSource.saveNextMedication(model);

      // 2. Programar notificaciones locales
      await service.cancelAllNotifications(); // Limpiar previas para evitar duplicados
      await service.scheduleMedicationNotifications(
        id: nextMed.id,
        name: nextMed.nombre,
        dosage: nextMed.dosis,
        nextTakeAt: nextMed.nextTakeAt,
      );
    }
  }

  MedicationNotificationModel? getCachedNotification() {
    return localDataSource.getNextMedication();
  }
}
