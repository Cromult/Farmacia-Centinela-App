import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prescription_ai_models.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../widgets/medication_ai_card.dart';
import 'edit_medication_page.dart';

class PrescriptionResultsPage extends ConsumerWidget {
  final PrescriptionAIResponse response;

  const PrescriptionResultsPage({super.key, required this.response});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final data = response.data;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Medicamentos Identificados',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Instrucciones Generales
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(color: colorScheme.primary, width: 8),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info, size: 40, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instrucciones Generales',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.instruccionesGlobales,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Listado de Medicamentos
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.medications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final med = data.medications[index];
                return MedicationAICard(
                  med: med,
                  onEdit: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditMedicationPage(medicationId: med.id),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Decorative Visual Aid
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCCCJd2RchD0xdJDJW4qUcquQEPbpSvln1yGQZZd15tQ6U1mqvt2QTh-u4ihpVcEdC87tE3SxSyn_EhunnjTXqA22N1hIAPrrusHdzusKbHu2ZP1mZpHSLXILC3UecdFtt890FwFTBgAGrGkbv0dxrCTsisdB4IcgwX47d7X1svuKu29LgX9lSuvc-Ikaxg0UaPAR1lJ2LfdGlmxd6ONTXr-EG9DYwL2X1UEFXHWD_fh2-7ReZR7Cc3j3107laT97omvwiEZ4br9A',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Por qué tomar fotos?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Identificar visualmente tus pastillas ayuda a evitar confusiones peligrosas durante tu tratamiento.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            ref.invalidate(dashboardFutureProvider);
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receta guardada exitosamente')),
            );
          },
          icon: const Icon(Icons.save_as),
          label: const Text('Confirmar y Guardar Todo'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 70),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
