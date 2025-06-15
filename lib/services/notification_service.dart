// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Menggunakan Singleton Pattern agar hanya ada satu instance dari service ini di seluruh aplikasi.
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  // Inisialisasi plugin notifikasi
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Menginisialisasi service notifikasi.
  /// Harus dipanggil di main.dart saat aplikasi pertama kali dijalankan.
  Future<void> init() async {
    // Pengaturan untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Menggunakan ikon default aplikasi

    // Pengaturan untuk iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    // Gabungkan pengaturan
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inisialisasi Timezone untuk notifikasi terjadwal (zonedSchedule)
    tz.initializeTimeZones();

    // Inisialisasi plugin dengan pengaturan yang sudah dibuat
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print("Notification Service Initialized.");
  }

  /// Meminta izin notifikasi di iOS (juga berfungsi untuk Android 13+).
  void requestPermissions() {
    // Untuk iOS
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // Untuk Android 13+
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Fungsi utama untuk menjadwalkan notifikasi di masa depan.
  Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    // Konversi DateTime biasa menjadi TZDateTime (waktu sadar timezone)
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    // Pengecekan keamanan: jangan jadwalkan notifikasi untuk waktu yang sudah lewat.
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print("Error: Waktu notifikasi ($scheduledDate) sudah lewat. Tidak dijadwalkan.");
      return;
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'main_channel_id',        // ID unik untuk channel
            'Pengingat Utama',        // Nama channel yang terlihat di pengaturan HP
            channelDescription: 'Channel untuk notifikasi pengingat catatan.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // Opsi penting untuk Android
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      // Pesan debugging yang sangat membantu
      print("SUCCESS: Notifikasi dengan ID $id dijadwalkan untuk: $scheduledDate");
    } catch (e) {
      // Menangkap error jika ada
      print("ERROR saat menjadwalkan notifikasi: $e");
    }
  }

  /// Fungsi untuk membatalkan notifikasi yang sudah terjadwal.
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print("Notifikasi dengan ID $id dibatalkan.");
  }

  /// Fungsi untuk membatalkan semua notifikasi.
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("Semua notifikasi dibatalkan.");
  }
}
