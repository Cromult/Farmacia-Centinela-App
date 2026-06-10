import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/models/prescription_ai_models.dart';
import '../../data/models/medication_detail_model.dart';
import '../../data/models/prescription_model.dart';
import 'dart:io';

// Estado para el procesamiento de IA
class PrescriptionAIState extends StateNotifier<AsyncValue<PrescriptionAIResponse?>> {
  final Ref ref;
  PrescriptionAIState(this.ref) : super(const AsyncValue.data(null));

  Future<void> processPrescription(String text) async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(prescriptionDataSourceProvider);
      final response = await dataSource.processPrescriptionAI(text);
      state = AsyncValue.data(response);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final prescriptionAIProvider = StateNotifierProvider<PrescriptionAIState, AsyncValue<PrescriptionAIResponse?>>((ref) {
  return PrescriptionAIState(ref);
});

// Listado de todas las prescripciones
final myPrescriptionsProvider = FutureProvider<List<PrescriptionModel>>((ref) async {
  final dataSource = ref.read(prescriptionDataSourceProvider);
  return dataSource.findAllByMe();
});

// Detalle de una prescripción específica (metadata)
final prescriptionDetailProvider = FutureProvider.family<PrescriptionModel, String>((ref, id) async {
  final dataSource = ref.read(prescriptionDataSourceProvider);
  return dataSource.findById(id);
});

// Listado de medicamentos por prescripción
final medicationsByPrescriptionProvider = FutureProvider.family<List<MedicationDetailModel>, String>((ref, prescriptionId) async {
  final dataSource = ref.read(medicationDataSourceProvider);
  return dataSource.findByPrescriptionId(prescriptionId);
});

// Lógica para medicamentos individuales
final medicationActionsProvider = Provider((ref) {
  final dataSource = ref.read(medicationDataSourceProvider);
  return MedicationActions(dataSource, ref);
});

class MedicationActions {
  final dynamic dataSource; // MedicationRemoteDataSource
  final Ref ref;
  MedicationActions(this.dataSource, this.ref);

  Future<MedicationDetailModel> getDetail(String id) => dataSource.getMedicationById(id);

  Future<void> updateImage(String id, File file) async {
    await dataSource.updateMedicationImage(id: id, files: [file]);
    ref.invalidate(medicationsByPrescriptionProvider); // Refrescar lista si estamos en ella
  }
}

// Lógica para acciones de prescripción
final prescriptionActionsProvider = Provider((ref) {
  final dataSource = ref.read(prescriptionDataSourceProvider);
  return PrescriptionActions(dataSource, ref);
});

class PrescriptionActions {
  final dynamic dataSource; // PrescriptionRemoteDataSource
  final Ref ref;
  PrescriptionActions(this.dataSource, this.ref);

  Future<void> updatePrescription(String id, UpdatePrescriptionDto dto) async {
    await dataSource.update(id, dto);
    // Invalidamos el listado y el detalle para que se refresquen
    ref.invalidate(myPrescriptionsProvider);
    ref.invalidate(prescriptionDetailProvider(id));
  }
}
