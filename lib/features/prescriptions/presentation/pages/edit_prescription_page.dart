import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/prescription_provider.dart';
import '../../data/models/prescription_model.dart';

class EditPrescriptionPage extends ConsumerStatefulWidget {
  final String prescriptionId;

  const EditPrescriptionPage({super.key, required this.prescriptionId});

  @override
  ConsumerState<EditPrescriptionPage> createState() => _EditPrescriptionPageState();
}

class _EditPrescriptionPageState extends ConsumerState<EditPrescriptionPage> {
  final _instructionsCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final dto = UpdatePrescriptionDto(
        instruccionesGlobales: _instructionsCtrl.text.trim(),
        fechaInicioReceta: _startDate,
        fechaFinReceta: _endDate,
      );
      await ref.read(prescriptionActionsProvider).updatePrescription(widget.prescriptionId, dto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescripción actualizada correctamente')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionState = ref.watch(prescriptionDetailProvider(widget.prescriptionId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final df = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Editar Prescripción', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: prescriptionState.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (prescription) {
          // Inicializar controladores una sola vez
          if (_instructionsCtrl.text.isEmpty && _startDate == null) {
            _instructionsCtrl.text = prescription.instruccionesGlobales;
            _startDate = prescription.fechaInicioReceta;
            _endDate = prescription.fechaFinReceta;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructional Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
                        child: Icon(Icons.medication, color: colorScheme.onPrimaryContainer, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Detalles del Tratamiento', style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Modifique las instrucciones globales y el rango de fechas para este medicamento.', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Form
                Text('Instrucciones Globales', style: theme.textTheme.labelLarge),
                const SizedBox(height: 12),
                TextField(
                  controller: _instructionsCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ej: Tomar con alimentos...',
                    suffixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha de Inicio', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(border: Border.all(color: colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_startDate != null ? df.format(_startDate!) : '')),
                                  Icon(Icons.calendar_today, color: colorScheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha de Finalización', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(border: Border.all(color: colorScheme.outlineVariant), borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_endDate != null ? df.format(_endDate!) : '')),
                                  Icon(Icons.event_busy, color: colorScheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Visual Context Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant, style: BorderStyle.solid),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCwpSpZCdgPGi4zyel3e-e6ta_N8vGmEilaoq_LFX6-iPt3V-WlKqkjkTdMlqP4a8BNa6en4Ww6-sEfXmK6VDdjSHMhEiSZqSnPdfYA4XrgFQrvsKdMDuGVOMGpCKyXTKK0zl88FaTwVzBvRiveC6GsAmWvAuaCWPSROvlGh4y_9kORHm3gi_afC2tcCYDWrVKRzsH_1ryk8QRl2kflAxsNGTfspfSR5LZ5zIwzLsEDZDQgyAulG7X4MKpQgXLCvcG5yBTKEN3akA',
                          width: 96, height: 96, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PRESCRIPCIÓN ACTUAL', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary, letterSpacing: 2)),
                            Text('Tratamiento AI', style: theme.textTheme.headlineSmall),
                            Text('Ajuste sus fechas según la receta física.', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isSaving 
              ? const CircularProgressIndicator.adaptive()
              : ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Cambios'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 64)),
                ),
            const SizedBox(height: 12),
            Text('Sus cambios se sincronizarán automáticamente.', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
