import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/custom_accessible_input.dart';
import '../../data/models/create_patient_user_profile_dto.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // Perfil
  final _nameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController();
  final _birthplaceCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _ciCtrl = TextEditingController();
  String? _gender;

  // Usuario
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Paciente
  final _hospitalCtrl = TextEditingController();

  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastnameCtrl.dispose();
    _birthdateCtrl.dispose();
    _birthplaceCtrl.dispose();
    _nationalityCtrl.dispose();
    _ciCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _hospitalCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1960),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdateCtrl.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _submit() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final lastname = _lastnameCtrl.text.trim();
    final birthdate = _birthdateCtrl.text.trim();
    final ci = _ciCtrl.text.trim();
    final hospital = _hospitalCtrl.text.trim();

    // Validaciones Básicas
    if (name.isEmpty || lastname.isEmpty || birthdate.isEmpty || ci.isEmpty || hospital.isEmpty) {
      _showError('Por favor, complete todos los campos obligatorios');
      return;
    }

    if (_gender == null) {
      _showError('Por favor, seleccione su género');
      return;
    }

    // Validación de Email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Por favor, ingrese un correo electrónico válido');
      return;
    }

    // Validación de Contraseña
    if (password.length < 8) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (!_acceptTerms) {
      _showError('Debe aceptar los términos y condiciones');
      return;
    }

    final dto = CreatePatientUserProfileDto(
      user: CreateUserDto(
        email: email,
        password: password,
      ),
      profile: CreateProfileDto(
        name: name,
        lastname: lastname,
        birthdate: birthdate,
        birthplace: _birthplaceCtrl.text.trim(),
        nationality: _nationalityCtrl.text.trim(),
        ci: ci,
        gender: _gender!,
      ),
      patient: CreatePatientDto(
        hospital: hospital,
      ),
    );

    ref.read(authProvider.notifier).register(dto);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<UserModel?>>(authProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.error}'),
            backgroundColor: colorScheme.error,
          ),
        );
      } else if (state.hasValue && state.value != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Crear Cuenta',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: Colors.grey.shade100, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Bienvenido al Gestor de Medicación',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete sus datos para comenzar',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 32),

            _buildSection(
              title: 'Perfil',
              icon: Icons.person,
              colorScheme: colorScheme,
              theme: theme,
              children: [
                CustomAccessibleInput(
                  label: 'Nombre',
                  hint: 'Ej: Antonio',
                  prefixIcon: Icons.person_outline,
                  controller: _nameCtrl,
                ),
                const SizedBox(height: 16),
                CustomAccessibleInput(
                  label: 'Apellido',
                  hint: 'Ej: Calderón',
                  prefixIcon: Icons.person_outline,
                  controller: _lastnameCtrl,
                ),
                const SizedBox(height: 16),
                // Fecha de Nacimiento con Selector
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomAccessibleInput(
                      label: 'Fecha de Nacimiento',
                      hint: 'YYYY-MM-DD',
                      prefixIcon: Icons.calendar_today,
                      controller: _birthdateCtrl,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomAccessibleInput(
                  label: 'Lugar de Nacimiento',
                  hint: 'Ej: Sucre',
                  prefixIcon: Icons.location_on_outlined,
                  controller: _birthplaceCtrl,
                ),
                const SizedBox(height: 16),
                CustomAccessibleInput(
                  label: 'Nacionalidad',
                  hint: 'Ej: Bolivia',
                  prefixIcon: Icons.flag_outlined,
                  controller: _nationalityCtrl,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomAccessibleInput(
                        label: 'CI',
                        hint: '1234567',
                        prefixIcon: Icons.badge_outlined,
                        controller: _ciCtrl,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Género', style: theme.textTheme.labelLarge),
                          const SizedBox(height: 12),
                          Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorScheme.outlineVariant, width: 2),
                              color: colorScheme.surfaceContainerLowest,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _gender,
                                isExpanded: true,
                                hint: const Text('Elegir'),
                                items: ['masculino', 'femenino', 'otro'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _gender = val),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Usuario',
              icon: Icons.account_circle,
              colorScheme: colorScheme,
              theme: theme,
              children: [
                CustomAccessibleInput(
                  label: 'Correo Electrónico',
                  hint: 'antonio@ejemplo.com',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailCtrl,
                ),
                const SizedBox(height: 16),
                CustomAccessibleInput(
                  label: 'Contraseña',
                  hint: 'Mínimo 8 caracteres',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordCtrl,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              title: 'Paciente',
              icon: Icons.health_and_safety,
              colorScheme: colorScheme,
              theme: theme,
              children: [
                CustomAccessibleInput(
                  label: 'Centro de Salud / Hospital',
                  hint: 'Ej: Hospital Central de Sucre',
                  prefixIcon: Icons.local_hospital_outlined,
                  controller: _hospitalCtrl,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Acepto los términos y condiciones de privacidad y uso de datos médicos.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // Espacio para el botón fijo
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: authState.isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.person_add),
                label: const Text('Crear Cuenta'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required ColorScheme colorScheme,
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 30),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
