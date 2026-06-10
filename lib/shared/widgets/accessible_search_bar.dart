import 'package:flutter/material.dart';

class AccessibleSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String label;
  final String hint;

  const AccessibleSearchBar({
    super.key,
    required this.onChanged,
    this.label = 'Buscar Medicamento',
    this.hint = 'Ej. Paracetamol',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta persistente superior (como en tu HTML)
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF434653), // on-surface-variant
              ),
        ),
        const SizedBox(height: 12), // stack-sm
        // Input accesible de altura mínima
        TextFormField(
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
            prefixIcon: const Icon(Icons.search, size: 28),
            contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16), // Asegura altura de ~72px
            filled: true,
            fillColor: Colors.white, // surface-container-lowest
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 2, // Borde normal de 2px
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 3, // Borde grueso de 3px al hacer foco (focus-ring)
              ),
            ),
          ),
        ),
      ],
    );
  }
}