import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class ApiClient {
  final Dio dio;
  final CookieJar cookieJar; // Ahora lo recibimos desde afuera

  ApiClient({required this.cookieJar}) : dio = Dio() {
    // dio.options.baseUrl = 'http://10.0.2.2:3000';
    dio.options.baseUrl = 'https://cj0n1l0x-3000.brs.devtunnels.ms/';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Interceptor de Cookies
    dio.interceptors.add(CookieManager(cookieJar));

    // Tu Interceptor de MinIO (El que reemplaza localhost)
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.data != null) {
            response.data = _replaceLocalhost(response.data);
          }
          return handler.next(response);
        },
      ),
    );
    
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  dynamic _replaceLocalhost(dynamic data) {
    if (data is String) {
      if (data.contains('http://localhost:9000')) return data.replaceAll('http://localhost:9000', 'https://cj0n1l0x-9000.brs.devtunnels.ms');
      return data;
    } else if (data is Map<String, dynamic>) {
      return data.map((key, value) => MapEntry(key, _replaceLocalhost(value)));
    } else if (data is List) {
      return data.map((item) => _replaceLocalhost(item)).toList();
    }
    return data;
  }
}