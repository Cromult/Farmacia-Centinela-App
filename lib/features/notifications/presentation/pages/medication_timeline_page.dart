import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/network_providers.dart';
import '../../data/models/medication_timeline_model.dart';

final timelineHistoryProvider = FutureProvider.autoDispose<List<MedicationTimelineModel>>((ref) async {
  final dataSource = ref.watch(medicationNotificationDataSourceProvider);
  return dataSource.getTimelineHistory();
});

class MedicationTimelinePage extends ConsumerWidget {
  const MedicationTimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineState = ref.watch(timelineHistoryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Línea de Tiempo', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(timelineHistoryProvider.future),
        child: timelineState.when(
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (timeline) {
            if (timeline.isEmpty) {
              return const Center(child: Text('No hay actividad programada para hoy ni mañana.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final item = timeline[index];
                return _TimelineItem(item: item);
              },
            );
          },
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final MedicationTimelineModel item;

  const _TimelineItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Configuración visual según estado
    Color iconColor;
    IconData iconData;
    Color bgColor;
    String statusText;

    if (!item.isVirtual) {
      // ✅ Toma REAL confirmada
      iconColor = Colors.green;
      iconData = Icons.check_circle;
      bgColor = Colors.green.withOpacity(0.05);
      statusText = 'CONFIRMADO: ${item.estado}';
    } else if (item.estado == 'NO_TOMADO') {
      // ❌ Toma VIRTUAL expirada (Olvido)
      iconColor = Colors.red;
      iconData = Icons.cancel;
      bgColor = Colors.red.withOpacity(0.05);
      statusText = 'NO TOMADO';
    } else if (item.estado == 'TOMAR_AHORA') {
      // 🔔 Ventana actual
      iconColor = Colors.orange;
      iconData = Icons.notifications_active;
      bgColor = Colors.orange.withOpacity(0.05);
      statusText = '¡TOMAR AHORA!';
    } else {
      // ⏳ Futuro (A_TOMAR)
      iconColor = Colors.blue;
      iconData = Icons.schedule;
      bgColor = Colors.blue.withOpacity(0.05);
      statusText = 'PENDIENTE';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Lado Izquierdo: Hora
          Column(
            children: [
              Text(
                DateFormat('HH:mm').format(item.tiempoTomado),
                style: theme.textTheme.headlineSmall?.copyWith(color: iconColor, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('dd MMM').format(item.tiempoTomado),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Divisor vertical
          Container(width: 2, height: 50, color: Colors.grey.shade100),
          const SizedBox(width: 20),
          // Lado Derecho: Info Medicamento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicationNombre,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  item.medicationDescripcion,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconData, size: 16, color: iconColor),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
