class CatalogMedicationModel {
  final String id;
  final String nombre;
  final String dosis;
  final int frecuenciaHoras;
  final DateTime nextTakeAt;
  final String? imageUrl;

  CatalogMedicationModel({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.frecuenciaHoras,
    required this.nextTakeAt,
    this.imageUrl,
  });

  factory CatalogMedicationModel.fromJson(Map<String, dynamic> json) {
    return CatalogMedicationModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      dosis: json['dosis'] ?? '',
      frecuenciaHoras: json['frecuencia_horas'] ?? 0,
      // Convertimos el UTC a la hora local del dispositivo automáticamente
      nextTakeAt: DateTime.parse(json['next_take_at']).toLocal(),
      imageUrl: json['image_url'],
    );
  }
}