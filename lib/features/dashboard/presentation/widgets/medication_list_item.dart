// lib\features\dashboard\presentation\widgets\medication_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/dashboard_model.dart';

class MedicationListItem extends StatelessWidget {
  final MedicationModel medication;

  const MedicationListItem({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat('hh:mm a').format(medication.nextTakeAt);
    
    return InkWell(
      onTap: () {}, // Acción futura
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: const Icon(Icons.schedule, color: AppColors.outline),
            ),
            const SizedBox(width: 16),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${medication.nombre} ${medication.dosis}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (medication.descripcion != null && medication.descripcion!.isNotEmpty)
                    Text(
                      medication.descripcion!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.outline),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(timeFormatted, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.outline)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}