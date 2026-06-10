import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ¡NUEVO!
import '../../../../core/providers/network_providers.dart';
import '../../data/models/login_dto.dart';
import '../../data/models/user_model.dart';
import '../../data/models/create_patient_user_profile_dto.dart';
import '../../data/models/forgot_password_dtos.dart';

class AuthNotifier extends Notifier<AsyncValue<UserModel?>> {
  @override
  AsyncValue<UserModel?> build() {
    _checkAuthStatus();
    return const AsyncLoading();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // 1. Verificamos si el usuario quiso guardar la sesión
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;

      // 2. Si NO quiso guardar sesión, limpiamos el disco duro y lo mandamos al login
      if (!rememberMe) {
        await ref.read(apiClientProvider).cookieJar.deleteAll();
        state = const AsyncData(null);
        return; // Detenemos la ejecución aquí
      }

      // 3. Si SÍ quiso guardar sesión, procedemos normal
      final dataSource = ref.read(authDataSourceProvider);
      final user = await dataSource.getMe(); 
      state = AsyncData(user); 
    } catch (e) {
      state = const AsyncData(null);
    }
  }

  // ¡NUEVO!: Añadimos el parámetro rememberMe
  Future<void> login(String email, String password, bool rememberMe) async {
    state = const AsyncLoading();

    try {
      final dataSource = ref.read(authDataSourceProvider);
      
      final user = await dataSource.login(
        LoginDto(email: email, password: password),
      );

      // Guardamos la decisión del usuario en el dispositivo
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);

      state = AsyncData(user);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> register(CreatePatientUserProfileDto dto) async {
    state = const AsyncLoading();
    try {
      final dataSource = ref.read(authDataSourceProvider);
      await dataSource.registerFull(dto);
      
      // Si el registro es exitoso, logueamos automáticamente
      await login(dto.user.email, dto.user.password, true);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(authDataSourceProvider).logout();
    } finally {
      // Al hacer logout manual, limpiamos todo y quitamos el remember_me
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', false);
      state = const AsyncData(null);
    }
  }

  Future<String> updatePassword(String oldPassword, String newPassword) async {
    try {
      final result = await ref.read(authDataSourceProvider).updatePassword(
        oldPassword,
        newPassword,
      );
      // Retornamos el mensaje de éxito del servidor
      return result['message'] ?? 'Contraseña actualizada correctamente';
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      rethrow;
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      return await ref.read(authDataSourceProvider).forgotPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> resetPassword(ResetPasswordDto dto) async {
    try {
      return await ref.read(authDataSourceProvider).resetPassword(dto);
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(() {
  return AuthNotifier();
});