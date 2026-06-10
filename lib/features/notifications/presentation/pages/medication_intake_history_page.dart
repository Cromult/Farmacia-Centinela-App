import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/network_providers.dart';

class MedicationIntakeHistoryPage extends ConsumerWidget {
  final String medicationId;
  final String medicationName;

  const MedicationIntakeHistoryPage({
    super.key,
    required this.medicationId,
    required this.medicationName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final historyFuture = ref.watch(_medicationHistoryProvider(medicationId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial: $medicationName'),
      ),
      body: historyFuture.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (records) {
          if (historyFuture.value?.isEmpty ?? true) {
            return const Center(
              child: Text('No hay registros de tomas para este medicamento.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = records[index];
              final String estado = record['estado'] ?? 'DESCONOCIDO';
              final DateTime? tiempoTomado = record['tiempo_tomado'] != null 
                  ? DateTime.parse(record['tiempo_tomado']).toLocal() 
                  : null;
              
              final isOnTime = estado == 'TIEMPO';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOnTime ? Icons.check_circle : Icons.error,
                      color: isOnTime ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            estado,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOnTime ? Colors.green : Colors.orange,
                            ),
                          ),
                          if (tiempoTomado != null)
                            Text(
                              'Tomado el: ${DateFormat('dd/MM/yyyy HH:mm').format(tiempoTomado)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final _medicationHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, id) async {
  final dataSource = ref.read(medicationNotificationDataSourceProvider);
  return dataSource.getNotificationsByMedication(id);
});
