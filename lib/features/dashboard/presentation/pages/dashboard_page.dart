// lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/next_medication_card.dart';
import '../widgets/medication_list_item.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../../catalog/presentation/pages/catalog_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../prescriptions/presentation/pages/register_prescription_page.dart';
import '../../../prescriptions/presentation/pages/my_prescriptions_page.dart';
import '../../../notifications/presentation/pages/medication_timeline_page.dart';

import 'visual_validation_page.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Medicamentos', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, // Evita botón de retroceso al login
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String choice) async {
              if (choice == 'logout') {
                // Mostrar diálogo de confirmación
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Sí, cerrar sesión'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout ?? false) {
                  try {
                    // Llamamos al logout del provider
                    await ref.read(authProvider.notifier).logout();
                    
                    if (context.mounted) {
                      // Navegamos al login y eliminamos todo el historial
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 10),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (dashboard) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(dashboardFutureProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo
                  Text('Buenos días,', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  Text(dashboard.patientName, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 32),

                  // Próxima Toma
                  if (dashboard.nextMedication != null)
                    NextMedicationCard(
                      medication: dashboard.nextMedication!,
                      onTaken: () {
                        // Diálogo para elegir si con foto o sin foto
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Wrap(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                                  title: const Text('Registrar con Foto (Verificación IA)'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => VisualValidationPage(medication: dashboard.nextMedication!),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.done_all, color: Colors.green),
                                  title: const Text('Registrar sin Foto (Toma Directa)'),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    try {
                                      await ref.read(markAsTakenProvider((
                                        medication: dashboard.nextMedication!,
                                        image: null,
                                      )).future);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Toma registrada correctamente')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 40),

                  // Sección: Medicinas a tomar hoy
                  Text('Medicinas a tomar hoy', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  
                  if (dashboard.medications.isEmpty && dashboard.nextMedication == null)
                    _buildEmptyState(context)
                  else if (dashboard.medications.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No hay más medicamentos programados para hoy'),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: dashboard.medications.map((med) => MedicationListItem(medication: med)).toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),

      // FABs para acciones rápidas
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btn_timeline',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MedicationTimelinePage()),
              );
            },
            label: const Text('Ver Historial', style: TextStyle(fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.history),
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'btn_new_recipe',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegisterPrescriptionPage(),
                ),
              );
            },
            label: const Text('Nueva Receta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            icon: const Icon(Icons.add_circle_outline, size: 28),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0, // 0 corresponde a 'Inicio'
        onTap: (index) {
          // Lógica de navegación nativa (Navigator)
          if (index == 1) {
            // Índice 1 es 'Medicinas'
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CatalogPage(),
              ),
            );
          } else if (index == 2) {
            // Navegación a Mis Prescripciones
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MyPrescriptionsPage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.history_edu,
            size: 100,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin recetas actuales ni históricas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Cuando su médico le asigne una receta, aparecerá aquí.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegisterPrescriptionPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Registrar mi primera receta'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
