import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/network_providers.dart'; // Tu inyector del ApiClient
import '../../data/datasources/catalog_remote_data_source.dart';
import '../../data/models/paginated_catalog_model.dart';
import '../../data/models/catalog_medication_model.dart';

// Proveedor del DataSource
final catalogDataSourceProvider = Provider<CatalogRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider); // Asumiendo que así lo llamaste
  return CatalogRemoteDataSource(apiClient);
});
final searchQueryProvider = StateProvider<String>((ref) => '');
// Gestor de Estado (Notifier)
class CatalogNotifier extends Notifier<AsyncValue<PaginatedCatalogModel>> {
  @override
  AsyncValue<PaginatedCatalogModel> build() {
    // Iniciamos la carga automáticamente al observar el provider
    fetchCatalog();
    return const AsyncValue.loading();
  }

  Future<void> fetchCatalog({int page = 1}) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(catalogDataSourceProvider);
      final result = await dataSource.getMyMedications(page: page);
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final catalogProvider = NotifierProvider<CatalogNotifier, AsyncValue<PaginatedCatalogModel>>(() {
  return CatalogNotifier();
});

final filteredCatalogProvider = Provider<List<CatalogMedicationModel>?>((ref) {
  // Observamos la lista original del backend
  final catalogState = ref.watch(catalogProvider);
  // Observamos lo que el usuario escribe
  final query = ref.watch(searchQueryProvider).toLowerCase();

  // Si aún no hay datos, retornamos nulo
  if (catalogState.valueOrNull == null) return null;

  final allMedications = catalogState.valueOrNull!.data;

  // Si el buscador está vacío, mostramos todos
  if (query.isEmpty) return allMedications;

  // Filtramos localmente (instantáneo)
  return allMedications.where((med) {
    return med.nombre.toLowerCase().contains(query);
  }).toList();
});