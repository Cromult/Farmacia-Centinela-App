import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/medication_detail_model.dart';

class MedicationRemoteDataSource {
  final ApiClient apiClient;

  MedicationRemoteDataSource({required this.apiClient});

  Future<List<MedicationDetailModel>> findByPrescriptionId(String prescriptionId) async {
    try {
      final response = await apiClient.dio.get('/medications/by-prescription/$prescriptionId');
      final data = response.data['data'] as List;
      final docsUrls = response.data['docsUrls'] as Map<String, dynamic>?;

      return data.map((json) => MedicationDetailModel.fromJson(json, docsUrls)).toList();
    } on DioException catch (e) {
      throw Exception('Error al obtener medicamentos de la receta: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<MedicationDetailModel> getMedicationById(String id) async {
    try {
      final response = await apiClient.dio.get('/medications/$id');
      // En findOne individual, el media_url ya viene dentro de medications_docs si includeUrls es true (default)
      return MedicationDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al obtener medicamento: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<MedicationDetailModel> updateMedication({
    required String id,
    String? nombre,
    String? dosis,
    String? descripcion,
    int? frecuenciaHoras,
    int? cantidad,
    int? duracionDias,
    String? viaAdministracion,
    List<String>? keepDocIds,
    List<File>? files,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (nombre != null) 'nombre': nombre,
        if (dosis != null) 'dosis': dosis,
        if (descripcion != null) 'descripcion': descripcion,
        if (frecuenciaHoras != null) 'frecuencia_horas': frecuenciaHoras.toString(),
        if (cantidad != null) 'cantidad': cantidad.toString(),
        if (duracionDias != null) 'duracion_dias': duracionDias.toString(),
        if (viaAdministracion != null) 'via_administracion': viaAdministracion,
        if (keepDocIds != null) 'keep_doc_ids': keepDocIds,
      };

      FormData formData = FormData.fromMap(data);

      if (files != null && files.isNotEmpty) {
        for (var file in files) {
          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(file.path,
                filename: file.path.split('/').last),
          ));
        }
      }

      final response = await apiClient.dio.patch(
        '/medications/$id',
        data: formData,
      );
      return MedicationDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al actualizar medicamento: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<MedicationDetailModel> updateMedicationImage({
    required String id,
    required List<File> files,
    List<String>? keepDocIds,
  }) async {
    try {
      final Map<String, dynamic> data = {
        if (keepDocIds != null) 'keep_doc_ids': keepDocIds,
      };

      FormData formData = FormData.fromMap(data);

      for (var file in files) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path,
              filename: file.path.split('/').last),
        ));
      }

      final response = await apiClient.dio.patch(
        '/medications/$id/image',
        data: formData,
      );
      return MedicationDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al actualizar imagen: ${e.response?.data['message'] ?? e.message}');
    }
  }
}
