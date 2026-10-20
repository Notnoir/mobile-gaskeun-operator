import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/iot_device_reading.dart';

class IotSensorService {
  final String deviceId;
  static const String databaseUrl =
      'https://gaskeun-ef49f-default-rtdb.asia-southeast1.firebasedatabase.app';

  FirebaseDatabase? _databaseInstance;
  String? lastError;

  IotSensorService({this.deviceId = 'gaskeun-rw01-01'});

  FirebaseDatabase? get _database {
    if (_databaseInstance != null) return _databaseInstance;
    try {
      _databaseInstance = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: databaseUrl,
      );
      return _databaseInstance;
    } catch (e) {
      try {
        _databaseInstance = FirebaseDatabase.instance;
        return _databaseInstance;
      } catch (err) {
        lastError = 'Firebase init error: $err';
        debugPrint('FirebaseDatabase resolution error: $err');
        return null;
      }
    }
  }

  DatabaseReference? get _latestRef {
    final db = _database;
    if (db == null) return null;
    return db.ref('gaskeun/v1/devices/$deviceId/latest');
  }

  DatabaseReference? get _readingsRef {
    final db = _database;
    if (db == null) return null;
    return db.ref('gaskeun/v1/devices/$deviceId/readings');
  }

  /// Membaca satu kali nilai sensor paling mutakhir (One-time fetch)
  Future<IotDeviceReading?> fetchLatestReading() async {
    final ref = _latestRef;
    if (ref == null) {
      lastError = 'DatabaseReference tidak dapat diinisialisasi';
      return null;
    }

    try {
      final snapshot = await ref.get();
      if (!snapshot.exists || snapshot.value == null) {
        lastError = 'Data di path /latest belum ditemukan di Firebase';
        return null;
      }

      final map = Map<dynamic, dynamic>.from(snapshot.value as Map);
      lastError = null;
      return IotDeviceReading.fromJson(map);
    } catch (e) {
      lastError = 'Gagal membaca Firebase: $e';
      debugPrint('Error fetchLatestReading: $e');
      return null;
    }
  }

  /// Mendengarkan perubahan data terkini (Path: /gaskeun/v1/devices/{deviceId}/latest)
  Stream<IotDeviceReading?> streamLatestReading() {
    final ref = _latestRef;
    if (ref == null) {
      return const Stream.empty();
    }

    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return null;
      try {
        final map = Map<dynamic, dynamic>.from(value as Map);
        lastError = null;
        return IotDeviceReading.fromJson(map);
      } catch (e) {
        lastError = 'Gagal parsing JSON: $e';
        debugPrint('Error parsing latest IoT reading: $e');
        return null;
      }
    }).handleError((error) {
      lastError = 'Stream Firebase Error: $error';
      debugPrint('Error on Firebase IoT stream: $error');
      return null;
    });
  }

  /// Mengambil riwayat 7 data terakhir dari Path: /gaskeun/v1/devices/{deviceId}/readings
  Future<List<IotDeviceReading>> fetchRecentHistory({int limit = 7}) async {
    final ref = _readingsRef;
    if (ref == null) return [];

    try {
      final query = ref.orderByKey().limitToLast(limit);
      final snapshot = await query.get();

      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }

      final rawMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      final List<IotDeviceReading> list = [];

      rawMap.forEach((key, val) {
        if (val is Map) {
          list.add(IotDeviceReading.fromJson(Map<dynamic, dynamic>.from(val)));
        }
      });

      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    } catch (e) {
      debugPrint('Error fetching IoT history: $e');
      return [];
    }
  }
}
