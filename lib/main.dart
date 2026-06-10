import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/providers/network_providers.dart';
import 'core/network/api_client.dart';
import 'core/services/notification_service.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';

// lib/main.dart (Corrección de inicialización)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // 1. Inicializar Notificaciones
  final notificationService = NotificationService();
  await notificationService.init();

  // 2. Buscamos la carpeta segura del dispositivo
  final dir = await getApplicationDocumentsDirectory();

  // 3. Creamos el Jar persistente
  final persistCookieJar = PersistCookieJar(
    storage: FileStorage('${dir.path}/.cookies/'),
  );

  // 4. CREAMOS EL CLIENTE PRIMERO
  final apiClient = ApiClient(cookieJar: persistCookieJar);

  // 5. INYECTAMOS EL CLIENTE EN EL CONTENEDOR INICIAL
  // Así, cuando llamemos a init() del DataSource, el Provider sabrá qué ApiClient usar.
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
    ],
  );

  // 6. Ahora sí inicializamos el DataSource de notificaciones con seguridad
  await container.read(notificationLocalDataSourceProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FarmaciaCentinelaApp(),
    ),
  );
}
