import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

// Cambiamos StatelessWidget por ConsumerWidget para leer Riverpod
class FarmaciaCentinelaApp extends ConsumerWidget {
  const FarmaciaCentinelaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado de autenticación
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Farmacia Centinela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      
      // Decidimos qué pantalla mostrar basados en el estado
      home: authState.when(
        // 1. Mientras verifica el auto-login en el disco
        loading: () => const _SplashScreen(), 
        
        // 2. Si ocurre un error catastrófico (poco probable aquí)
        error: (err, stack) => const LoginPage(), 
        
        // 3. Ya terminó de verificar
        data: (user) {
          if (user != null) {
            // Hay usuario = Va directo al Dashboard
            return const DashboardPage();
          } else {
            // No hay usuario = Va al Login
            return const LoginPage();
          }
        },
      ),
    );
  }
}

// Pantalla de carga simple con tus colores (Senior-Centric)
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism, size: 80, color: AppColors.primary),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}