import '../../../../core/network/api_client.dart';
import '../models/paginated_catalog_model.dart';

class CatalogRemoteDataSource {
  final ApiClient _apiClient;

  CatalogRemoteDataSource(this._apiClient);

  Future<PaginatedCatalogModel> getMyMedications({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.dio.get(
        '/medications/me/latest-prescription',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return PaginatedCatalogModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al cargar el catálogo: $e');
    }
  }
}