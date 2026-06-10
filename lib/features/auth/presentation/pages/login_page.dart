import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado general para obtener el estatus de carga
    final authState = ref.watch(authProvider);

    // Escuchamos los errores para mostrar feedback al usuario de la tercera edad
    ref.listen<AsyncValue>(authProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: ${state.error}', 
              style: const TextStyle(fontSize: 18), // Texto grande para el error
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      else if (state.hasValue && state.value != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    });

    return Scaffold(
      body: SafeArea( // Evita el notch y los indicadores del sistema
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: LoginForm(
              isLoading: authState.isLoading,
              onSubmit: (email, password, rememberMe) {
                // Aquí disparamos la petición al backend configurado con Dio
                ref.read(authProvider.notifier).login(email, password, rememberMe);
              },
            ),
          ),
        ),
      ),
    );
  }
}