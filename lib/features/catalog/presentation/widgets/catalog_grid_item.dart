import 'package:flutter/material.dart';
import '../../data/models/catalog_medication_model.dart';

class CatalogGridItem extends StatelessWidget {
  final CatalogMedicationModel medication;

  const CatalogGridItem({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // surface-container-lowest del DESIGN.md
        borderRadius: BorderRadius.circular(12), // 0.75rem de tu HTML
        border: Border.all(
          color: const Color(0xFFE0E8FF), // surface-container-high
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Para que la imagen respete los bordes redondeados
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Futura acción de detalle
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ Sección de Imagen (Aspect Square)
              AspectRatio(
                aspectRatio: 1, // Fuerza a que sea un cuadrado perfecto como en tu HTML
                child: Container(
                  color: const Color(0xFFE9EDFF), // bg-surface-container
                  width: double.infinity,
                  child: medication.imageUrl != null
                      ? Image.network(
                          medication.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              // 📝 Sección de Detalles
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // p-gutter (16px)
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.nombre,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF141B2C), // on-surface
                              height: 1.2,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medication.dosis} • Cada ${medication.frecuenciaHoras}h',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF434653), // on-surface-variant
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.medication, color: Color(0xFF2559BD), size: 48), // surface-tint
    );
  }
}