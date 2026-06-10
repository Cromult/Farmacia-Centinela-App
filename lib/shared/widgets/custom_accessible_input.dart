import 'package:flutter/material.dart';

class CustomAccessibleInput extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final bool enabled;

  const CustomAccessibleInput({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    required this.controller,
    this.enabled = true,
  });

  @override
  State<CustomAccessibleInput> createState() => _CustomAccessibleInputState();
}

class _CustomAccessibleInputState extends State<CustomAccessibleInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 64, // Altura estricta por accesibilidad
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.enabled,
            obscureText: widget.isPassword && _obscureText,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(widget.prefixIcon, size: 32, color: theme.colorScheme.outline),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      iconSize: 32,
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: theme.colorScheme.outline,
                      ),
                      onPressed: widget.enabled ? () => setState(() => _obscureText = !_obscureText) : null,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}