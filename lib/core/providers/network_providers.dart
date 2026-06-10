// lib/core/providers/network_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/prescriptions/data/datasources/prescription_remote_data_source.dart';
import '../../features/prescriptions/data/datasources/medication_remote_data_source.dart';
import '../../features/notifications/data/datasources/medication_notification_remote_data_source.dart';

// Proveedor del Cliente Base (Dio + Cookies)
final apiClientProvider = Provider<ApiClient>((ref) {
  // Lanzamos un error temporal. 
  // El valor real se sobreescribe en el main.dart usando "overrideWithValue"
  // después de inicializar el directorio del teléfono.
  throw UnimplementedError('El ApiClient no ha sido inicializado en main.dart');
});

// Proveedor del Data Source de Autenticación
final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  // Aquí watch(apiClientProvider) ya recibirá el cliente con las cookies persistentes
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient: apiClient);
});

// Proveedor del Data Source de Prescripciones
final prescriptionDataSourceProvider = Provider<PrescriptionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PrescriptionRemoteDataSource(apiClient: apiClient);
});

// Proveedor del Data Source de Medicamentos
final medicationDataSourceProvider = Provider<MedicationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MedicationRemoteDataSource(apiClient: apiClient);
});

// Proveedor del Data Source de Toma de Medicamentos
final medicationNotificationDataSourceProvider = Provider<MedicationNotificationRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MedicationNotificationRemoteDataSource(apiClient: apiClient);
});