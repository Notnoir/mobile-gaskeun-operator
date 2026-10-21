import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import 'iot_sensor_service.dart';

/// Layanan Whitelist Registry untuk Petugas Operator & Pengawas RW (Pendekatan 2).
/// Mendukung akun dengan peran tunggal maupun akun dengan peran ganda (Multi-Role: Operator & Pengawas).
class StaffRegistryService {
  static final StaffRegistryService _instance = StaffRegistryService._internal();
  factory StaffRegistryService() => _instance;
  StaffRegistryService._internal();

  FirebaseDatabase? _databaseInstance;

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

  /// Whitelist Petugas Operator Lapangan (Default / Seed)
  static final Set<String> _operatorEmails = {
    'mriza8857@gmail.com',
    'huaweicloudroadtochina@gmail.com',
  };

  /// Whitelist Pengawas RW (Default / Seed)
  static final Set<String> _pengawasEmails = {
    'huaweicloudroadtochina@gmail.com',
  };

  /// Whitelist UID Petugas dari Firebase Auth (opsional)
  static final Map<String, Set<UserRole>> _whitelistedUids = {};

  /// Tambahkan email petugas secara dinamis ke whitelist lokal
  void registerStaffEmail(String email, UserRole role) {
    final clean = email.trim().toLowerCase();
    if (role == UserRole.operator) {
      _operatorEmails.add(clean);
    } else if (role == UserRole.pengawas) {
      _pengawasEmails.add(clean);
    }
  }

  /// Tambahkan UID petugas secara dinamis ke whitelist lokal
  void registerStaffUid(String uid, UserRole role) {
    final cleanUid = uid.trim();
    _whitelistedUids.putIfAbsent(cleanUid, () => <UserRole>{}).add(role);
  }

  /// Helper untuk sanitasi email agar valid sebagai Firebase RTDB key
  static String sanitizeEmailKey(String email) {
    return email.trim().toLowerCase().replaceAll('.', '_').replaceAll('@', '_at_');
  }

  /// Dapatkan daftar seluruh peran yang diizinkan untuk email/UID secara sinkron
  Set<UserRole> getAuthorizedRolesSync(String email, {String? uid}) {
    final cleanEmail = email.trim().toLowerCase();
    final roles = <UserRole>{};

    if (uid != null && _whitelistedUids.containsKey(uid.trim())) {
      roles.addAll(_whitelistedUids[uid.trim()]!);
    }
    if (_operatorEmails.contains(cleanEmail)) {
      roles.add(UserRole.operator);
    }
    if (_pengawasEmails.contains(cleanEmail)) {
      roles.add(UserRole.pengawas);
    }
    return roles;
  }

  /// Verifikasi peran petugas secara sinkron dengan dukungan preferredRole
  UserRole? verifyStaffRoleSync(String email, {String? uid, UserRole? preferredRole}) {
    final roles = getAuthorizedRolesSync(email, uid: uid);
    if (roles.isEmpty) return null;

    if (preferredRole != null && roles.contains(preferredRole)) {
      return preferredRole;
    }

    // Jika memiliki kedua role dan tidak ada preferredRole, default ke operator
    if (roles.contains(UserRole.operator)) return UserRole.operator;
    if (roles.contains(UserRole.pengawas)) return UserRole.pengawas;
    return null;
  }

  /// Dapatkan seluruh peran yang diizinkan untuk akun ini (cek Firebase RTDB + Whitelist lokal)
  Future<Set<UserRole>> getAuthorizedRoles({
    required String email,
    String? uid,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final sanitizedEmail = sanitizeEmailKey(cleanEmail);
    final roles = getAuthorizedRolesSync(cleanEmail, uid: uid);

    final db = _database;
    if (db != null) {
      try {
        final staffRef = db.ref('gaskeun/v1/authorized_staff');

        // Cek Operators di RTDB (by UID atau by sanitized email)
        final opRef = staffRef.child('operators');
        if (uid != null && uid.isNotEmpty) {
          final opUidSnap = await opRef.child(uid).get().timeout(const Duration(seconds: 3));
          if (opUidSnap.exists && (opUidSnap.value == true || opUidSnap.child('active').value == true)) {
            roles.add(UserRole.operator);
            registerStaffUid(uid, UserRole.operator);
          }
        }
        final opEmailSnap = await opRef.child(sanitizedEmail).get().timeout(const Duration(seconds: 3));
        if (opEmailSnap.exists && (opEmailSnap.value == true || opEmailSnap.child('active').value == true)) {
          roles.add(UserRole.operator);
          registerStaffEmail(cleanEmail, UserRole.operator);
        }

        // Cek Pengawas RW di RTDB (by UID atau by sanitized email)
        final rwRef = staffRef.child('pengawas');
        if (uid != null && uid.isNotEmpty) {
          final rwUidSnap = await rwRef.child(uid).get().timeout(const Duration(seconds: 3));
          if (rwUidSnap.exists && (rwUidSnap.value == true || rwUidSnap.child('active').value == true)) {
            roles.add(UserRole.pengawas);
            registerStaffUid(uid, UserRole.pengawas);
          }
        }
        final rwEmailSnap = await rwRef.child(sanitizedEmail).get().timeout(const Duration(seconds: 3));
        if (rwEmailSnap.exists && (rwEmailSnap.value == true || rwEmailSnap.child('active').value == true)) {
          roles.add(UserRole.pengawas);
          registerStaffEmail(cleanEmail, UserRole.pengawas);
        }
      } catch (e) {
        debugPrint('StaffRegistryService: RTDB check notice ($e), using local whitelist.');
      }
    }

    return roles;
  }

  /// Verifikasi peran petugas secara asinkron dengan dukungan preferredRole
  Future<UserRole?> verifyStaffRole({
    required String email,
    String? uid,
    UserRole? preferredRole,
  }) async {
    final roles = await getAuthorizedRoles(email: email, uid: uid);
    if (roles.isEmpty) return null;

    if (preferredRole != null && roles.contains(preferredRole)) {
      return preferredRole;
    }

    if (roles.contains(UserRole.operator)) return UserRole.operator;
    if (roles.contains(UserRole.pengawas)) return UserRole.pengawas;
    return null;
  }
}
