// lib/features/dashboard/presentation/widgets/next_medication_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/dashboard_model.dart';

class NextMedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback onTaken;

  const NextMedicationCard({
    super.key, 
    required this.medication,
    required this.onTaken,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormatted = DateFormat('hh:mm a').format(medication.nextTakeAt);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface, // Fondo suave azulado
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Próxima toma y Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Envolvemos la parte izquierda en Expanded
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: AppColors.primary, size: 12),
                    const SizedBox(width: 8),
                    // 2. Usamos Flexible para que el texto haga "..." si no cabe
                    Flexible(
                      child: Text(
                        'Próxima Toma', 
                        style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primary),
                        overflow: TextOverflow.ellipsis, // Corta el texto con puntos si es muy largo
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8), // Un pequeño margen de seguridad
              
              // 3. La etiqueta de estado (PENDIENTE)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Le dice que ocupe solo lo necesario
                  children: [
                    const Icon(Icons.schedule, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(medication.status ?? 'PENDIENTE', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Detalles e Imagen
          Row(
            children: [
              // Foto
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.white,
                ),
                child: medication.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(medication.imageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.medication, size: 40, color: AppColors.outline),
              ),
              const SizedBox(width: 24),
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(timeFormatted, style: theme.textTheme.displayLarge),
                    Text('${medication.nombre} ${medication.dosis}', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.restaurant, size: 20, color: AppColors.outline),
                        const SizedBox(width: 8),
                        Text('Cada ${medication.frecuenciaHoras} horas', style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.outline)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Botón Grande
          ElevatedButton(
            onPressed: onTaken,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: const Text('Marcar como Tomado'),
          )
        ],
      ),
    );
  }
}