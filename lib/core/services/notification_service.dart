import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Al pulsar entra a la app
      },
    );

    // SOLICITAR PERMISOS
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print('[NotificationService] Timezone: $currentTimeZone');
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    
    await showTestNotification();
  }

  Future<void> showTestNotification() async {
    print('[NotificationService] Enviando TEST...');
    await flutterLocalNotificationsPlugin.show(
      999,
      'Farmacia Centinela Activa',
      'El motor de alertas de medicación está listo.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel_v11',
          'Canal de Pruebas',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }

  Future<void> scheduleDashboardEntryTest() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = now.add(const Duration(minutes: 2));
    
    print('[NotificationService] Programando TEST DASHBOARD (2 min) para $scheduledTime');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      111,
      'Prueba de Ingreso',
      'Ingresaste al dashboard hace 2 minutos.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel_v12',
          'Canal de Pruebas de Sistema',
          importance: Importance.max,
          priority: Priority.max,
          fullScreenIntent: true,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleMedicationNotifications({
    required String id,
    required String name,
    required String dosage,
    required DateTime nextTakeAt,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime.from(nextTakeAt, tz.local);
    final int baseId = id.hashCode.abs() % 100000;

    print('[NotificationService] Sincronizando: $name para $nextTakeAt');

    // 1. CASO: MEDICINA ATRASADA (Refuerzos cada 5 MINUTOS)
    if (scheduledDate.isBefore(now)) {
      print('[NotificationService] ¡ATRASO DETECTADO! Programando refuerzos cada 5 min.');
      
      await _showImmediate(
        id: baseId + 100,
        title: '¡MEDICINA RETRASADA: $name!',
        body: 'Llevas tiempo de retraso con tu dosis de $dosage. ¡Tómala ahora!',
        level: NotificationLevel.critical,
      );

      for (int i = 1; i <= 6; i++) { // Cubrimos 30 minutos con 6 alertas
        await _schedule(
          id: baseId + 100 + i,
          title: '¡SIGUE RETRASADO ($i): $name!',
          body: 'Han pasado ${i * 5} min. Por favor toma tu $dosage lo antes posible.',
          scheduledDate: now.add(Duration(minutes: 5 * i)),
          level: NotificationLevel.critical,
        );
      }
      return;
    }

    // 2. CASO: PROGRAMACIÓN NORMAL (Futuro)
    
    // 10 min antes (Nivel: Informativo)
    await _schedule(
      id: baseId + 10,
      title: 'Aviso pronto: $name',
      body: 'En 10 minutos toca tu dosis de $dosage.',
      scheduledDate: scheduledDate.subtract(const Duration(minutes: 10)),
      level: NotificationLevel.low,
    );

    // 5 min antes (Nivel: Medio)
    await _schedule(
      id: baseId + 5,
      title: 'Prepárate: $name',
      body: 'En 5 minutos debes tomar $dosage.',
      scheduledDate: scheduledDate.subtract(const Duration(minutes: 5)),
      level: NotificationLevel.medium,
    );

    // 2 min antes (Nivel: Medio-Alto)
    await _schedule(
      id: baseId + 2,
      title: 'Casi hora: $name',
      body: 'En 2 minutos toca tu dosis de $dosage. Ten tu agua lista.',
      scheduledDate: scheduledDate.subtract(const Duration(minutes: 2)),
      level: NotificationLevel.medium,
    );

    // HORA EXACTA (¡CRÍTICO! - DISEÑO DIFERENTE)
    await _schedule(
      id: baseId + 0,
      title: '¡AHORA MISMO: $name!',
      body: 'Es el momento exacto. Toma tu dosis de $dosage ya.',
      scheduledDate: scheduledDate,
      level: NotificationLevel.critical,
    );
  }

  Future<void> _showImmediate({required int id, required String title, required String body, NotificationLevel level = NotificationLevel.critical}) async {
    await flutterLocalNotificationsPlugin.show(
      id, title, body,
      NotificationDetails(
        android: _androidDetails(level),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
    );
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationLevel level,
  }) async {
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    print('[NotificationService] Programado [$level]: "$title" para $scheduledDate');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, title, body, scheduledDate,
      NotificationDetails(
        android: _androidDetails(level),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      ),
      androidScheduleMode: level == NotificationLevel.critical ? AndroidScheduleMode.alarmClock : AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  AndroidNotificationDetails _androidDetails(NotificationLevel level) {
    // Definimos configuraciones según el nivel
    String channelId;
    String channelName;
    Importance importance;
    Priority priority;
    Color? color;
    Int64List? vibration;
    bool showWhen = true;

    switch (level) {
      case NotificationLevel.low:
        channelId = 'med_reminders_low';
        channelName = 'Recordatorios Preventivos';
        importance = Importance.low;
        priority = Priority.low;
        color = Colors.blue;
        vibration = Int64List.fromList([0, 200]);
        break;
      case NotificationLevel.medium:
        channelId = 'med_reminders_medium';
        channelName = 'Avisos de Preparación';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        color = Colors.orange;
        vibration = Int64List.fromList([0, 500, 200, 500]);
        break;
      case NotificationLevel.critical:
        channelId = 'med_alerts_critical_v11';
        channelName = 'Alertas Médicas Críticas';
        importance = Importance.max;
        priority = Priority.max;
        color = const Color.fromARGB(255, 255, 0, 0);
        vibration = Int64List.fromList([0, 1000, 500, 1000, 500, 2000]); // Vibración agresiva
        showWhen = true;
        break;
    }

    return AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      color: color,
      ledColor: color,
      ledOnMs: 1000,
      ledOffMs: 500,
      enableLights: true,
      enableVibration: true,
      vibrationPattern: vibration,
      fullScreenIntent: level == NotificationLevel.critical,
      category: level == NotificationLevel.critical ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      styleInformation: const BigTextStyleInformation(''),
      playSound: true,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

enum NotificationLevel { low, medium, critical }
