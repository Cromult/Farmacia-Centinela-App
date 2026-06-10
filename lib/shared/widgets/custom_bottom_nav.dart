import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart'; // Asegúrate de que esta ruta sea correcta

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 80, // <-- ❌ ELIMINAMOS LA ALTURA FIJA PARA HACERLO FLEXIBLE
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 6,
          ),
        ],
      ),
      // Usamos Material e InkWell para un efecto visual de toque (mejor accesibilidad)
      child: Material(
        color: Colors.transparent,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround, // <-- ❌ Reemplazado por Expanded
          children: [
            Expanded(child: _buildNavItem(0, Icons.home_filled, 'Inicio', context)),
            Expanded(child: _buildNavItem(1, Icons.medication, 'Medicinas', context)),
            Expanded(child: _buildNavItem(2, Icons.book, 'Prescripciones', context)),
            Expanded(child: _buildNavItem(3, Icons.account_circle, 'Perfil', context)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, BuildContext context) {
    final isActive = currentIndex == index;
    final color = isActive ? AppColors.primary : AppColors.outline;

    return InkWell( // <-- Usamos InkWell para feedback visual al tocar
      onTap: () => onTap(index),
      child: Container(
        // width: 70, // <-- ❌ ELIMINAMOS EL ANCHO FIJO (lo gestiona Expanded)
        
        // 🌟 AÑADIMOS PADDING VERTICAL PARA CREAR UN BOTÓN GRANDE Y ACCESIBLE
        // Esto expande el área táctil orgánicamente.
        padding: const EdgeInsets.symmetric(vertical: 20), // 20px arriba y abajo
        
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent, 
              width: 4, 
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 🌟 IMPORTANTE: La columna solo toma el espacio necesario
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              // 🌟 PROTECCIÓN DE TEXTO PARA SENIORS
              maxLines: 1, // Previene el salto de línea si la fuente se agranda en el sistema
              overflow: TextOverflow.ellipsis, // Muestra "Inici..." si es muy largo
            ),
          ],
        ),
      ),
    );
  }
}