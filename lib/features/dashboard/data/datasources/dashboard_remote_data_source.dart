import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSource({required this.apiClient});

  Future<DashboardModel> getDashboard() async {
    try {
      // Las cookies viajan solas gracias a nuestra configuración previa
      final response = await apiClient.dio.get('/prescriptions/dashboard/me');
      return DashboardModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Error al cargar el panel: ${e.response?.statusCode}');
    }
  }
}