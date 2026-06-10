import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/custom_accessible_input.dart';
import '../../data/models/forgot_password_dtos.dart';

class ForgotPasswordDialog extends ConsumerStatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  
  int _step = 1; // 1: Email, 2: Code & New Password
  bool _isLoading = false;
  String? _errorMessage; // Variable para el error interno

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _handleSendCode() async {
    setState(() => _errorMessage = null);
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Por favor ingresa un correo válido');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await ref.read(authProvider.notifier).forgotPassword(email);
      _showSuccess(message);
      setState(() => _step = 2);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleResetPassword() async {
    setState(() => _errorMessage = null);
    final code = _codeCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (code.length != 6) {
      setState(() => _errorMessage = 'El código debe ser de 6 dígitos');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _errorMessage = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dto = ResetPasswordDto(
        email: _emailCtrl.text.trim(),
        code: code,
        newPassword: newPassword,
      );
      final message = await ref.read(authProvider.notifier).resetPassword(dto);
      _showSuccess(message);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_reset, size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                _step == 1 ? 'Recuperar Contraseña' : 'Verificar Código',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _step == 1 
                  ? 'Ingresa tu correo para recibir un código de 6 dígitos.' 
                  : 'Ingresa el código enviado a ${_emailCtrl.text} y tu nueva contraseña.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              if (_step == 1)
                CustomAccessibleInput(
                  label: 'Correo Electrónico',
                  hint: 'ejemplo@correo.com',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailCtrl,
                  enabled: !_isLoading,
                ),
              
              if (_step == 2) ...[
                CustomAccessibleInput(
                  label: 'Código de 6 dígitos',
                  hint: '123456',
                  prefixIcon: Icons.numbers,
                  controller: _codeCtrl,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                CustomAccessibleInput(
                  label: 'Nueva Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _newPasswordCtrl,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                CustomAccessibleInput(
                  label: 'Confirmar Contraseña',
                  hint: 'Repite tu nueva contraseña',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _confirmPasswordCtrl,
                  enabled: !_isLoading,
                ),
              ],

              const SizedBox(height: 24),

              // Mensaje de error interno
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 8),
              
              if (_isLoading)
                const CircularProgressIndicator.adaptive()
              else
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _step == 1 ? _handleSendCode : _handleResetPassword,
                    child: Text(_step == 1 ? 'Enviar Código' : 'Restablecer Contraseña'),
                  ),
                ),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }

