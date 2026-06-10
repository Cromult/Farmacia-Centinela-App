import 'package:intl/intl.dart';

class PrescriptionModel {
  final String id;
  final String patientId;
  final String instruccionesGlobales;
  final DateTime fechaInicioReceta;
  final DateTime fechaFinReceta;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.instruccionesGlobales,
    required this.fechaInicioReceta,
    required this.fechaFinReceta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      instruccionesGlobales: json['instrucciones_globales'] ?? '',
      fechaInicioReceta: DateTime.parse(json['fecha_inicio_receta']),
      fechaFinReceta: DateTime.parse(json['fecha_fin_receta']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'instrucciones_globales': instruccionesGlobales,
      'fecha_inicio_receta': DateFormat('yyyy-MM-dd').format(fechaInicioReceta),
      'fecha_fin_receta': DateFormat('yyyy-MM-dd').format(fechaFinReceta),
    };
  }
}

class UpdatePrescriptionDto {
  final String? instruccionesGlobales;
  final DateTime? fechaInicioReceta;
  final DateTime? fechaFinReceta;

  UpdatePrescriptionDto({
    this.instruccionesGlobales,
    this.fechaInicioReceta,
    this.fechaFinReceta,
  });

  Map<String, dynamic> toJson() {
    return {
      if (instruccionesGlobales != null) 'instrucciones_globales': instruccionesGlobales,
      if (fechaInicioReceta != null) 'fecha_inicio_receta': DateFormat('yyyy-MM-dd').format(fechaInicioReceta!),
      if (fechaFinReceta != null) 'fecha_fin_receta': DateFormat('yyyy-MM-dd').format(fechaFinReceta!),
    };
  }
}
