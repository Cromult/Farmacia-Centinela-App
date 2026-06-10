import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/prescription_ai_models.dart';
import '../providers/prescription_provider.dart';
import 'prescription_results_page.dart';

class RegisterPrescriptionPage extends ConsumerStatefulWidget {
  const RegisterPrescriptionPage({super.key});

  @override
  ConsumerState<RegisterPrescriptionPage> createState() => _RegisterPrescriptionPageState();
}

class _RegisterPrescriptionPageState extends ConsumerState<RegisterPrescriptionPage> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPrescription() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese el detalle de la receta')),
      );
      return;
    }

    await ref.read(prescriptionAIProvider.notifier).processPrescription(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final aiState = ref.watch(prescriptionAIProvider);

    // Escuchar cambios de estado para navegar o mostrar error
    ref.listen<AsyncValue<PrescriptionAIResponse?>>(prescriptionAIProvider, (previous, next) {
      next.whenOrNull(
        data: (PrescriptionAIResponse? response) {
          if (response != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PrescriptionResultsPage(response: response),
              ),
            );
            // Opcional: resetear el estado después de navegar para que al volver no intente navegar de nuevo
            ref.read(prescriptionAIProvider.notifier).reset();
          }
        },
        error: (Object e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Registrar Prescripción',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: Colors.grey.shade100, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instrucciones',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingrese el texto de su receta médica tal como aparece en su documento.',
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Detalle de la Receta', style: theme.textTheme.labelLarge),
                Text('${_textCtrl.text.length} / 2000', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textCtrl,
              maxLines: 10,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Ej. Tomar Amoxicilina 500mg cada 8 horas...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outlineVariant, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.outlineVariant, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.surfaceVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: colorScheme.primary),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Puede copiar el texto desde un mensaje o escribirlo manualmente. Asegúrese de incluir dosis y horarios.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCx8MUjD2bLAmnPRsaHpwqVGW9FHlJoqBLk3BoxHqB65tAQ0jt1cMTUDFp2hobTGBd3qvDKEnRnrcIc-knK1AVYX3XnAdSr_riA8qumcysQZbsN8su33aPtXWQLflU-gd5T7-9bV3Jpsbo0eKBmXEyFQeWgyYQrph_-qs0rlLRb0iJPpA7lGFWEfdMHHHwGaWFb_ETgfiD-e6JP5sQJxg51K2zlKxlOdJ2ZlAlB84nJ7Qi2LSy4SCEN90eexIhfd7DJimdTI37NQg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100, width: 2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: aiState.isLoading
            ? const Center(
                heightFactor: 1,
                child: CircularProgressIndicator.adaptive(),
              )
            : ElevatedButton.icon(
                onPressed: _processPrescription,
                icon: const Icon(Icons.check_circle),
                label: const Text('Procesar Receta'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
      ),
    );
  }
}
