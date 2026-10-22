import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import 'iot_sensor_service.dart';
import 'staff_registry_service.dart';

/// Top-level background handler untuk menerima pesan FCM saat aplikasi
/// di-minimize (*background*) atau dimatikan (*terminated*).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (_) {}
  debugPrint('[FCM Background] ID: ${message.messageId}, Data: ${message.data}, Title: ${message.notification?.title}');
}

/// Layanan terpusat untuk Push Notification Firebase Cloud Messaging (FCM).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  FirebaseDatabase? _databaseInstance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Global Messenger Key untuk menampilkan SnackBar / In-App Notification Banner di mana saja
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  FirebaseDatabase? get _database {
    if (_databaseInstance != null) return _databaseInstance;
    try {
      if (Firebase.apps.isNotEmpty) {
        _databaseInstance = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL: IotSensorService.databaseUrl,
        );
        return _databaseInstance;
      }
    } catch (_) {
      try {
        _databaseInstance = FirebaseDatabase.instance;
        return _databaseInstance;
      } catch (_) {}
    }
    return null;
  }

  /// Inisialisasi FCM saat aplikasi mulai berjalan
  Future<void> initialize() async {
    try {
      // 1. Minta izin notifikasi (Android 13+ & iOS)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Status Izin Notifikasi: ${settings.authorizationStatus}');

      // 2. Ambil token unik FCM perangkat ini
      _fcmToken = await _fcm.getToken();
      debugPrint('[FCM Token Perangkat]: $_fcmToken');

      // 3. Pasang pendengar pembaruan token
      _fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[FCM Token Refreshed]: $newToken');
      });

      // 4. Tangani pesan saat aplikasi sedang dibuka (*Foreground*)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground Message]: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // 5. Tangani saat pengguna mengetuk notifikasi saat aplikasi di latar belakang
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM Opened from Background]: ${message.data}');
      });

      // 6. Tangani notifikasi saat aplikasi dibuka dari keadaan mati (*Cold Start*)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM Cold Start Message]: ${initialMessage.data}');
      }
    } catch (e) {
      debugPrint('[FCM Notice] FCM initialize notice: $e');
    }
  }

  /// Simpan / perbarui FCM Token ke Firebase Realtime Database sesuai identitas petugas
  Future<void> syncStaffToken({
    required String email,
    required UserRole role,
    String? uid,
  }) async {
    final token = _fcmToken ?? await _fcm.getToken();
    if (token == null) return;

    final sanitizedEmail = StaffRegistryService.sanitizeEmailKey(email);
    final db = _database;

    // Daftarkan ke topik broadcast FCM sesuai perannya
    await subscribeRoleTopics(role);

    if (db != null) {
      try {
        final roleKey = role == UserRole.operator ? 'operators' : 'pengawas';
        final tokenRef = db.ref('gaskeun/v1/staff_fcm_tokens/$roleKey/$sanitizedEmail');

        await tokenRef.set({
          'token': token,
          'email': email,
          'uid': uid ?? '',
          'role': role.displayName,
          'updated_at': ServerValue.timestamp,
          'platform': 'android',
        });
        debugPrint('[FCM] Token berhasil disinkronkan ke RTDB untuk $email ($roleKey)');
      } catch (e) {
        debugPrint('[FCM] Gagal menyimpan token ke RTDB: $e');
      }
    }
  }

  /// Berlangganan topik notifikasi sesuai peran petugas
  Future<void> subscribeRoleTopics(UserRole role) async {
    try {
      if (role == UserRole.operator) {
        // Operator berlangganan peringatan sensor IoT & setoran baru warga
        await _fcm.subscribeToTopic('operators');
        await _fcm.subscribeToTopic('iot_emergency');
        await _fcm.unsubscribeFromTopic('pengawas');
        debugPrint('[FCM] Berlangganan topik: operators & iot_emergency');
      } else if (role == UserRole.pengawas) {
        // Pengawas RW berlangganan rekapitulasi & laporan berkala
        await _fcm.subscribeToTopic('pengawas');
        await _fcm.unsubscribeFromTopic('iot_emergency');
        debugPrint('[FCM] Berlangganan topik: pengawas');
      }
    } catch (e) {
      debugPrint('[FCM] Gagal berlangganan topik: $e');
    }
  }

  /// Berhenti berlangganan seluruh topik saat keluar akun (*Sign Out*)
  Future<void> unsubscribeAllTopics() async {
    try {
      await _fcm.unsubscribeFromTopic('operators');
      await _fcm.unsubscribeFromTopic('iot_emergency');
      await _fcm.unsubscribeFromTopic('pengawas');
      debugPrint('[FCM] Unsubscribed all topics');
    } catch (_) {}
  }

  /// Tampilkan banner notifikasi mengambang di layar
  void showNotificationBanner({
    required String title,
    required String body,
    bool isCritical = false,
  }) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: isCritical ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCritical ? Icons.warning_amber_rounded : Icons.notifications_active_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tampilkan notifikasi mengambang (*In-App Banner*) saat pesan masuk di latar depan (*Foreground*)
  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'Pemberitahuan GasKeun';
    final body = message.notification?.body ?? '';
    final isCritical = message.data['type'] == 'emergency' ||
        title.toLowerCase().contains('bahaya') ||
        title.toLowerCase().contains('waspada');

    showNotificationBanner(title: title, body: body, isCritical: isCritical);
  }
}
