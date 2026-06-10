class MedicationTimelineModel {
  final String id;
  final String medicationId;
  final String medicationNombre;
  final String medicationDescripcion;
  final DateTime tiempoTomado;
  final String estado;
  final int frecuenciasHoras;
  final bool isVirtual;

  MedicationTimelineModel({
    required this.id,
    required this.medicationId,
    required this.medicationNombre,
    required this.medicationDescripcion,
    required this.tiempoTomado,
    required this.estado,
    required this.frecuenciasHoras,
    required this.isVirtual,
  });

  factory MedicationTimelineModel.fromJson(Map<String, dynamic> json) {
    return MedicationTimelineModel(
      id: json['id'] ?? '',
      medicationId: json['medication_id'] ?? '',
      medicationNombre: json['medication_nombre'] ?? '',
      medicationDescripcion: json['medication_descripcion'] ?? '',
      tiempoTomado: DateTime.parse(json['tiempo_tomado']).toLocal(),
      estado: json['estado'] ?? '',
      frecuenciasHoras: json['frecuencias_horas'] is int 
          ? json['frecuencias_horas'] 
          : int.tryParse(json['frecuencias_horas'].toString()) ?? 0,
      isVirtual: json['is_virtual'] ?? false,
    );
  }
}
