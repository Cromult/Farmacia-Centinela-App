// lib/features/dashboard/presentation/widgets/medication_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/dashboard_model.dart';
import 'package:intl/intl.dart'; // Añade "intl: ^0.19.0" a tu pubspec.yaml

class MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final bool isHighlight; // Si es la próxima a tomar

  const MedicationCard({super.key, required this.medication, this.isHighlight = false});

  Color _getStatusColor() {
    switch (medication.status) {
      case 'TOMAR_AHORA':
        return Colors.orange.shade700;
      case 'ATRASADO':
        return AppColors.tertiary; // Deep Red del diseño
      case 'PENDIENTE':
      default:
        return AppColors.primary; // Cobalt Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormatted = DateFormat('HH:mm').format(medication.nextTakeAt);

    return Card(
      elevation: isHighlight ? 3 : 1, // Más elevación si es la próxima
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isHighlight ? 16 : 8),
        side: isHighlight 
            ? BorderSide(color: _getStatusColor(), width: 2) 
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Imagen del Medicamento (con placeholder si falla)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: medication.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        medication.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.medication),
                      ),
                    )
                  : const Icon(Icons.medication, size: 32),
            ),
            const SizedBox(width: 16),
            
            // Datos del Medicamento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medication.nombre, style: theme.textTheme.headlineMedium),
                  Text('${medication.dosis} • Cada ${medication.frecuenciaHoras}h', 
                       style: theme.textTheme.bodyLarge),
                  if (medication.status != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        medication.status!,
                        style: theme.textTheme.labelLarge?.copyWith(color: _getStatusColor()),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
            // Hora
            Text(timeFormatted, style: theme.textTheme.headlineLarge?.copyWith(
              color: isHighlight ? _getStatusColor() : theme.colorScheme.onSurface,
            )),
          ],
        ),
      ),
    );
  }
}