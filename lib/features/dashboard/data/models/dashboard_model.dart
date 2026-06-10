class MedicationModel {
  final String id;
  final String nombre;
  final String dosis;
  final int frecuenciaHoras;
  final DateTime nextTakeAt;
  final String? status;
  final String? imageUrl;

  MedicationModel({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.frecuenciaHoras,
    required this.nextTakeAt,
    this.status,
    this.imageUrl,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      dosis: json['dosis'] ?? '',
      frecuenciaHoras: json['frecuencia_horas'] ?? 0,
      nextTakeAt: DateTime.parse(json['next_take_at']).toLocal(),
      status: json['status'],
      // Ya no hay parche aquí. Llega limpio gracias a Dio.
      imageUrl: json['image_url'], 
    );
  }
}

class DashboardModel {
  final String patientName;
  final String? prescriptionId;
  final int totalMedications;
  final MedicationModel? nextMedication;
  final List<MedicationModel> medications;

  DashboardModel({
    required this.patientName,
    this.prescriptionId,
    required this.totalMedications,
    this.nextMedication,
    required this.medications,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      patientName: json['patient_name'] ?? '',
      prescriptionId: json['prescription_id'],
      totalMedications: json['total_medications'] ?? 0,
      nextMedication: json['next_medication'] != null 
          ? MedicationModel.fromJson(json['next_medication']) 
          : null,
      medications: (json['medications'] as List<dynamic>?)
              ?.map((item) => MedicationModel.fromJson(item))
              .toList() ?? [],
    );
  }
}