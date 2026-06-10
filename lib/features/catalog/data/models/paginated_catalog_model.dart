import 'catalog_medication_model.dart';

class PaginatedCatalogModel {
  final List<CatalogMedicationModel> data;
  final int total;
  final int page;
  final int limit;

  PaginatedCatalogModel({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedCatalogModel.fromJson(Map<String, dynamic> json) {
    return PaginatedCatalogModel(
      data: (json['data'] as List?)
              ?.map((item) => CatalogMedicationModel.fromJson(item))
              .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }
}