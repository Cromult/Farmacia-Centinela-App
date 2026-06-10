import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/models/dashboard_model.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../notifications/data/models/medication_take_dto.dart';
import 'dart:io';

// Proveedor del DataSource
final dashboardDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRemoteDataSource(apiClient: apiClient);
});

// Proveedor del Estado
final dashboardFutureProvider = FutureProvider.autoDispose<DashboardModel>((ref) async {
  final dataSource = ref.watch(dashboardDataSourceProvider);
  
  try {
    final dashboard = await dataSource.getDashboard();
    
    // Sincronizar notificaciones cuando los datos lleguen del servidor
    final notifier = ref.read(notificationProvider);
    await notifier.syncNotifications(dashboard);

    // Prueba de 2 minutos sugerida por el usuario
    await NotificationService().scheduleDashboardEntryTest();
    
    return dashboard;
  } catch (e) {
    print('[DashboardProvider] Error de red: $e. Intentando cargar desde Hive...');
    // Si falla la red, intentar cargar desde el caché de notificaciones (Offline-First)
    final cached = ref.read(notificationProvider).getCachedNotification();
    if (cached != null) {
      // Retornamos un modelo parcial basado en el caché para que la UI no muera
      return DashboardModel(
        patientName: 'Modo Offline',
        totalMedications: 1,
        nextMedication: MedicationModel(
          id: cached.id,
          nombre: cached.name,
          dosis: cached.dosage,
          frecuenciaHoras: 0,
          nextTakeAt: cached.scheduledTime,
          status: cached.status,
        ),
        medications: [],
      );
    }
    rethrow;
  }
});

// Provider para la acción de marcar como tomado
final markAsTakenProvider = FutureProvider.family<Map<String, dynamic>, ({MedicationModel medication, File? image})>((ref, params) async {
  final dataSource = ref.read(medicationNotificationDataSourceProvider);
  final medication = params.medication;
  
  final now = DateTime.now();
  // Comparar con un margen de 30 min para decir si es a tiempo
  final isOnTime = now.isBefore(medication.nextTakeAt.add(const Duration(minutes: 30))) &&
                   now.isAfter(medication.nextTakeAt.subtract(const Duration(minutes: 30)));
  
  final dto = CreateMedicationNotificationDto(
    medicationId: medication.id,
    tiempoTomado: now.toUtc().toIso8601String(),
    estado: isOnTime ? 'TIEMPO' : 'DESTIEMPO',
    frecuenciasHoras: medication.frecuenciaHoras,
  );

  final result = await dataSource.createNotification(dto, params.image);
  
  // Refrescar el dashboard después de marcar como tomado
  ref.invalidate(dashboardFutureProvider);

  return result;
});
