import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/catalog_medication_model.dart';

class CatalogItemCard extends StatelessWidget {
  final CatalogMedicationModel medication;

  const CatalogItemCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    // Usamos intl para formatear la hora de forma legible
    final timeFormat = DateFormat('hh:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // 0.5rem del DESIGN.md
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Futura navegación al detalle
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Imagen del medicamento (soporta nulos)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: medication.imageUrl != null
                      ? Image.network(
                          medication.imageUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: 16),
                // Detalles (Flexible para evitar Overflow)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.nombre,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF141B2C), // Ink Black
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosis: ${medication.dosis} • Cada ${medication.frecuenciaHoras}h',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF434653), // Gris oscuro
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E8FF), // Primary container
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Próxima: ${timeFormat.format(medication.nextTakeAt)}',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: const Color(0xFF00327D), // Cobalt Blue
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFE9EDFF),
      child: const Icon(Icons.medication, color: Color(0xFF2559BD), size: 32),
    );
  }
}