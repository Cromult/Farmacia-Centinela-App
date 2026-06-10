import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prescriptions/presentation/pages/my_prescriptions_page.dart';
import '../providers/catalog_provider.dart';
import '../widgets/catalog_grid_item.dart';
import '../../../../shared/widgets/accessible_search_bar.dart'; // Tu buscador
import '../../../../shared/widgets/custom_bottom_nav.dart'; // Tu barra de navegación

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado original (para saber si está cargando o hay error)
    final catalogState = ref.watch(catalogProvider);
    // Escuchamos la lista filtrada instantáneamente
    final filteredMeds = ref.watch(filteredCatalogProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF), // bg-surface 
      appBar: AppBar(
        title: const Text('My Medications', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00327D))),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00327D)), // Primary 
          // Al retroceder, volvemos al Dashboard
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Volver',
        ),
      ),
      body: catalogState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (_) {
          if (filteredMeds == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0), // px-margin-edge [cite: 281]
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24), // pt-[104px] padding top adjustment
                
                // 🔍 Tu buscador accesible en acción
                AccessibleSearchBar(
                  onChanged: (value) {
                    // Actualizamos el provider instantáneamente al escribir
                    ref.read(searchQueryProvider.notifier).state = value;
                  },
                ),
                
                const SizedBox(height: 32), // mb-stack-lg
                
                // 🖼️ Grilla de Medicamentos
                Expanded(
                  child: filteredMeds.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron medicamentos.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF737784), // outline color 
                                ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          // Configuración exacta para imitar tu grid-cols-2
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16, // gap-gutter
                            mainAxisSpacing: 16,  // gap-gutter
                            childAspectRatio: 0.55, // Ajuste para dar espacio al texto bajo la foto
                          ),
                          itemCount: filteredMeds.length,
                          itemBuilder: (context, index) {
                            return CatalogGridItem(medication: filteredMeds[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      
      // 📱 Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1, // La pestaña 1 es "Meds" (Medicinas), la marcamos como activa
        onTap: (index) {
          if (index == 0) {
            // Si tocan "Home" (0), retrocedemos al Dashboard
            Navigator.of(context).pop();
          }else if (index == 1) {
            // Navegación a Medicinas (Mismo sitio o Refresh)
          }else if (index == 2) {
            // Navegación a Mis Prescripciones (Historial)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MyPrescriptionsPage(),
              ),
            );
          }

          // Puedes agregar la navegación de Alarmas y Perfil aquí luego
        },
      ),
    );
  }
}