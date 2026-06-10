import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/prescription_provider.dart';
import 'edit_prescription_page.dart';
import 'prescription_medications_page.dart';

class MyPrescriptionsPage extends ConsumerWidget {
  const MyPrescriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsState = ref.watch(myPrescriptionsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Medications',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'MED+',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: prescriptionsState.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (prescriptions) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myPrescriptionsProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Prescripciones',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Revisa tus recetas activas y las instrucciones de tu médico.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: prescriptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final prescription = prescriptions[index];
                      // Marcar la más reciente (asumiendo que vienen ordenadas o la primera es la más nueva)
                      final isRecent = index == 0; 
                      return _PrescriptionCard(
                        prescription: prescription,
                        isRecent: isRecent,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  // Decorative Visual Component
                  Container(
                    height: 192,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB18_JNQYfYGXgrsLffA4DItHrTZpl1H3RZEKmW0wiS-OChUtVPWVahVUhH33UhY9zUkKgFLkIgp0SzEfho_SU7lmYQ0so9CN0v_42vy2wBtj6OTGNubr3btM33OvQ6rjUN08SmBbRw1fWimPZ8BzX85rkcpL156nx3anipO1wBOGUkcqIzi8TPh4CN1AXw8HA0gPmSxk-kE7AkUEofQaeJcTmBo2jNhnU0uxIPQFc7CppOTW785VxKZMhk0mqLkoal588HzcSDNA'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [colorScheme.primary.withValues(alpha: 0.8), Colors.transparent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Tu salud es nuestra prioridad.',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        maxLines: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final dynamic prescription;
  final bool isRecent;

  const _PrescriptionCard({required this.prescription, this.isRecent = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final df = DateFormat('yyyy-MM-dd');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isRecent)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Reciente',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: colorScheme.outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prescription.id,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.outline,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Instrucciones Globales',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prescription.instruccionesGlobales,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Inicio', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontWeight: FontWeight.bold)),
                            Text(df.format(prescription.fechaInicioReceta), style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.event_busy, color: colorScheme.tertiary, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fin', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontWeight: FontWeight.bold)),
                            Text(df.format(prescription.fechaFinReceta), style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PrescriptionMedicationsPage(prescriptionId: prescription.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Ver Medicamentos'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditPrescriptionPage(prescriptionId: prescription.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      side: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
