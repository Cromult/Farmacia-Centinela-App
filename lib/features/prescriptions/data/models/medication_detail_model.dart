class MedicationDetailModel {
  final String id;
  final String nombre;
  final String dosis;
  final String descripcion;
  final int frecuenciaHoras;
  final int cantidad;
  final int duracionDias;
  final String viaAdministracion;
  final String prescriptionId;
  final List<MedicationDocModel> medicationsDocs;

  MedicationDetailModel({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.descripcion,
    required this.frecuenciaHoras,
    required this.cantidad,
    required this.duracionDias,
    required this.viaAdministracion,
    required this.prescriptionId,
    required this.medicationsDocs,
  });

  factory MedicationDetailModel.fromJson(Map<String, dynamic> json, [Map<String, dynamic>? docsUrls]) {
    final docs = (json['medications_docs'] as List<dynamic>?)?.map((d) {
      final docJson = Map<String, dynamic>.from(d);
      if (docsUrls != null && docsUrls.containsKey(docJson['id'])) {
        docJson['media_url'] = docsUrls[docJson['id']];
      }
      return MedicationDocModel.fromJson(docJson);
    }).toList() ?? [];

    return MedicationDetailModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      dosis: json['dosis'] ?? '',
      descripcion: json['descripcion'] ?? '',
      frecuenciaHoras: json['frecuencia_horas'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      duracionDias: json['duracion_dias'] ?? 0,
      viaAdministracion: json['via_administracion'] ?? '',
      prescriptionId: json['prescription_id'] ?? '',
      medicationsDocs: docs,
    );
  }
}

class MedicationDocModel {
  final String id;
  final String mediaId;
  final String? mediaUrl;

  MedicationDocModel({
    required this.id,
    required this.mediaId,
    this.mediaUrl,
  });

  factory MedicationDocModel.fromJson(Map<String, dynamic> json) {
    return MedicationDocModel(
      id: json['id'] ?? '',
      mediaId: json['media_id'] ?? '',
      mediaUrl: json['media_url'],
    );
  }
}
