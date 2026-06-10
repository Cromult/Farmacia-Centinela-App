import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/prescription_ai_models.dart';
import '../models/prescription_model.dart';

class PrescriptionRemoteDataSource {
  final ApiClient apiClient;

  PrescriptionRemoteDataSource({required this.apiClient});

  Future<PrescriptionAIResponse> processPrescriptionAI(String text) async {
    try {
      final response = await apiClient.dio.post(
        '/prescriptions/ai/process',
        data: {'texto_receta': text},
      );
      return PrescriptionAIResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Error al procesar receta con IA: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<List<PrescriptionModel>> findAllByMe() async {
    try {
      final response = await apiClient.dio.get('/prescriptions/me/all');
      return (response.data as List)
          .map((json) => PrescriptionModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(
          'Error al obtener mis prescripciones: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<PrescriptionModel> findById(String id) async {
    try {
      final response = await apiClient.dio.get('/prescriptions/$id');
      return PrescriptionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Error al obtener la prescripción: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<PrescriptionModel> update(String id, UpdatePrescriptionDto dto) async {
    try {
      final response = await apiClient.dio.patch(
        '/prescriptions/$id',
        data: dto.toJson(),
      );
      return PrescriptionModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Error al actualizar la prescripción: ${e.response?.data['message'] ?? e.message}');
    }
  }
}
