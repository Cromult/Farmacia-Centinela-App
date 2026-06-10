import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/medication_take_dto.dart';

class MedicationNotificationRemoteDataSource {
  final ApiClient apiClient;

  MedicationNotificationRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> createNotification(CreateMedicationNotificationDto dto, File? image) async {
    try {
      final Map<String, dynamic> dataMap = {
        'medication_id': dto.medicationId,
        if (dto.tiempoTomado != null) 'tiempo_tomado': dto.tiempoTomado,
        'estado': dto.estado,
        'frecuencias_horas': dto.frecuenciasHoras.toString(),
      };

      dynamic data;

      if (image != null) {
        final formData = FormData.fromMap(dataMap);
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            image.path,
            filename: 'verification_pill.jpg',
          ),
        ));
        data = formData;
      } else {
        data = dataMap;
      }

      final response = await apiClient.dio.post(
        '/medicantion-notifications',
        data: data,
      );
      
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Devolvemos el mensaje exacto de la IA o del servidor
      throw Exception(e.response?.data['message'] ?? 'Error al procesar la toma');
    }
  }

  Future<List<Map<String, dynamic>>> getNotificationsByMedication(String medicationId) async {
    try {
      final response = await apiClient.dio.get('/medicantion-notifications/medication/$medicationId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener el historial: ${e.response?.data['message'] ?? e.message}');
    }
  }
}
