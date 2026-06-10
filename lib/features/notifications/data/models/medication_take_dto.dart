enum MedicationNotificationStatus {
  TIEMPO,
  DESTIEMPO,
  NO_TOMADO,
}

class CreateMedicationNotificationDto {
  final String medicationId;
  final String? tiempoTomado;
  final String estado;
  final int frecuenciasHoras;

  CreateMedicationNotificationDto({
    required this.medicationId,
    this.tiempoTomado,
    required this.estado,
    required this.frecuenciasHoras,
  });

  Map<String, dynamic> toJson() => {
        'medication_id': medicationId,
        'tiempo_tomado': tiempoTomado,
        'estado': estado,
        'frecuencias_horas': frecuenciasHoras,
      };
}
