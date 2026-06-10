// lib/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_accessible_input.dart';
import 'forgot_password_dialog.dart';
import '../pages/register_page.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  // Actualizado: Ahora recibe el tercer parámetro (rememberMe)
  final void Function(String email, String password, bool rememberMe) onSubmit;

  const LoginForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  // NUEVO: Variable para controlar el estado del Checkbox
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(40), // stack-lg
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.volunteer_activism, size: 48, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          Text('Bienvenido', style: theme.textTheme.displayLarge?.copyWith(color: colorScheme.primary)),
          const SizedBox(height: 12),
          Text('Ingrese a su cuenta para continuar.', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 40),

          // Inputs
          CustomAccessibleInput(
            label: 'E-mail',
            hint: 'Ej: pablo@email.com',
            prefixIcon: Icons.mail_outline,
            controller: _emailCtrl,
          ),
          const SizedBox(height: 24),
          CustomAccessibleInput(
            label: 'Contraseña',
            hint: 'Su contraseña secreta',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: _passCtrl,
          ),
          const SizedBox(height: 16), // Espacio reducido para que quepa el checkbox

          // NUEVO: Checkbox Accesible (Senior-Centric)
          Theme(
            data: theme.copyWith(
              // Quitamos el padding por defecto para alinear con los inputs
              listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.zero),
            ),
            child: CheckboxListTile(
              title: Text(
                'Mantener sesión iniciada', 
                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
              value: _rememberMe,
              activeColor: colorScheme.primary,
              onChanged: (bool? newValue) {
                setState(() {
                  _rememberMe = newValue ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading, // Checkbox a la izquierda
            ),
          ),
          
          const SizedBox(height: 32),

          // Primary Button
          widget.isLoading
              ? const SizedBox(
                  height: 64,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              : ElevatedButton(
                  // Actualizado: Enviamos el valor de _rememberMe a la página
                  onPressed: () => widget.onSubmit(_emailCtrl.text, _passCtrl.text, _rememberMe),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Entrar'),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
          
          const SizedBox(height: 32),
          const Divider(thickness: 2),
          const SizedBox(height: 24),

          // Secondary Actions
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => const ForgotPasswordDialog(),
              );
            },
            child: const Text('Olvidé mi contraseña', style: TextStyle(decoration: TextDecoration.underline)),
          ),
          const SizedBox(height: 16),
          Text('¿Es su primera vez aquí?', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              side: BorderSide(color: colorScheme.primary, width: 3),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            child: const Text('Crear Nueva Cuenta'),
          ),
        ],
      ),
    );
  }
}