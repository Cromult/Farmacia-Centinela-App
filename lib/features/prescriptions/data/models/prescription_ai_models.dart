class ProcessRawPrescriptionDto {
  final String textoReceta;

  ProcessRawPrescriptionDto({required this.textoReceta});

  Map<String, dynamic> toJson() => {
        'texto_receta': textoReceta,
      };
}

class PrescriptionAIResponse {
  final String message;
  final PrescriptionData data;

  PrescriptionAIResponse({required this.message, required this.data});

  factory PrescriptionAIResponse.fromJson(Map<String, dynamic> json) {
    return PrescriptionAIResponse(
      message: json['message'] ?? '',
      data: PrescriptionData.fromJson(json['data']),
    );
  }
}

class PrescriptionData {
  final String id;
  final String instruccionesGlobales;
  final List<MedicationAIModel> medications;

  PrescriptionData({
    required this.id,
    required this.instruccionesGlobales,
    required this.medications,
  });

  factory PrescriptionData.fromJson(Map<String, dynamic> json) {
    return PrescriptionData(
      id: json['id'] ?? '',
      instruccionesGlobales: json['instrucciones_globales'] ?? '',
      medications: (json['medications'] as List<dynamic>?)
              ?.map((m) => MedicationAIModel.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class MedicationAIModel {
  final String id;
  final String nombre;
  final String dosis;
  final String descripcion;
  final int frecuenciaHoras;
  final int duracionDias;

  MedicationAIModel({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.descripcion,
    required this.frecuenciaHoras,
    required this.duracionDias,
  });

  factory MedicationAIModel.fromJson(Map<String, dynamic> json) {
    return MedicationAIModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      dosis: json['dosis'] ?? '',
      descripcion: json['descripcion'] ?? '',
      frecuenciaHoras: json['frecuencia_horas'] ?? 0,
      duracionDias: json['duracion_dias'] ?? 0,
    );
  }
}
