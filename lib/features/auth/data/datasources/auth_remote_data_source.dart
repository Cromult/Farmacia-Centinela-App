import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_dto.dart';
import '../models/user_model.dart';
import '../models/update_password_dto.dart';
import '../models/create_patient_user_profile_dto.dart';
import '../models/forgot_password_dtos.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  // =========================
  // POST /auth/login
  // =========================
  Future<UserModel> login(LoginDto loginDto) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: loginDto.toJson(),
      );

      // Tu backend devuelve { user: {...}, access_token: "..." }
      // Las cookies ya fueron guardadas automáticamente por el CookieManager
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      // Aquí manejaremos los errores (ej. UnauthorizedException de NestJS)
      throw Exception('Error al iniciar sesión: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // =========================
  // GET /auth/me
  // =========================
  Future<UserModel> getMe({String? accessToken}) async {
    try {
      final options = accessToken != null
          ? Options(
              headers: {'Authorization': 'Bearer $accessToken'},
            )
          : null;

      final response = await apiClient.dio.get(
        '/auth/me',
        options: options,
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw Exception('Error al obtener usuario: ${e.message}');
    }
  }

  // =========================
  // POST /auth/refresh
  // =========================
  Future<bool> refreshToken() async {
    try {
      // El CookieManager enviará la cookie de refresh automáticamente
      final response = await apiClient.dio.post('/auth/refresh');
      return response.data['ok'] == true;
    } catch (e) {
      return false; // Si falla, significa que la sesión expiró totalmente
    }
  }

  // =========================
  // POST /auth/logout
  // =========================
  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/logout');
      // Limpiamos las cookies locales del dispositivo
      await apiClient.cookieJar.deleteAll();
    } catch (e) {
      throw Exception('Error al cerrar sesión');
    }
  }

  // =========================
  // PATCH /auth/me/password
  // =========================
  Future<Map<String, dynamic>> updatePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final dto = UpdatePasswordDto(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      final response = await apiClient.dio.patch(
        '/auth/me/password',
        data: dto.toJson(),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        'Error al actualizar contraseña: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // =========================
  // POST /patients/full
  // =========================
  Future<Map<String, dynamic>> registerFull(
    CreatePatientUserProfileDto dto,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/patients/full',
        data: dto.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        'Error al registrar usuario completo: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // =========================
  // POST /auth/forgot-password
  // =========================
  Future<String> forgotPassword(String email) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.data['message'] ?? 'Código enviado';
    } on DioException catch (e) {
      throw Exception(
        'Error al solicitar código: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }

  // =========================
  // POST /auth/reset-password
  // =========================
  Future<String> resetPassword(ResetPasswordDto dto) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/reset-password',
        data: dto.toJson(),
      );
      return response.data['message'] ?? 'Contraseña restablecida';
    } on DioException catch (e) {
      throw Exception(
        'Error al restablecer contraseña: ${e.response?.data['message'] ?? e.message}',
      );
    }
  }
}