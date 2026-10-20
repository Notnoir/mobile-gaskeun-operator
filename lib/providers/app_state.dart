import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/waste_submission_model.dart';
import '../models/reward_model.dart';
import '../models/iot_sensor_model.dart';
import '../models/report_model.dart';

class DemoUserCredential {
  final String email;
  final String password;
  final String roleLabel;
  final String name;
  final UserRole role;

  const DemoUserCredential({
    required this.email,
    required this.password,
    required this.roleLabel,
    required this.name,
    required this.role,
  });
}

class AppState extends ChangeNotifier {
  // Current active role & authentication (Default to Operator for this app)
  UserRole _currentRole = UserRole.operator;
  bool _isAuthenticated = false;
  bool _isLoggedIn = false;

  UserRole get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoggedIn => _isLoggedIn;

  static const List<DemoUserCredential> demoCredentials = [
    DemoUserCredential(
      email: 'operator@gaskeun.id',
      password: 'password123',
      roleLabel: 'Operator',
      name: 'Pak Anton (Teknisi)',
      role: UserRole.operator,
    ),
    DemoUserCredential(
      email: 'pengawas@gaskeun.id',
      password: 'password123',
      roleLabel: 'Pengawas RW',
      name: 'Bu Sari Handayani (Ketua RW)',
      role: UserRole.pengawas,
    ),
  ];

  // Profiles
  late UserProfile _wargaProfile;
  late UserProfile _operatorProfile;
  late UserProfile _pengawasProfile;

  UserProfile get activeProfile {
    switch (_currentRole) {
      case UserRole.operator:
        return _operatorProfile;
      case UserRole.pengawas:
        return _pengawasProfile;
      case UserRole.warga:
        return _operatorProfile;
    }
  }

  UserProfile get wargaProfile => _wargaProfile;

  // Data collections
  final List<WasteSubmission> _submissions = [];
  final List<RewardItem> _rewards = [];
  final List<RewardClaim> _claims = [];
  final List<PredictiveAlert> _alerts = [];
  final List<GeneratedReport> _reports = [];

  // Machine & Sensors
  String machineName = 'Biodigester Komunal BD-RW05';
  String machineLocation = 'Jl. Kenanga RT 02 / RW 05 (Samping Balai Pertemuan)';
  bool isMachineOnline = true;

  SensorMetric _temperatureMetric = SensorMetric(
    name: 'Suhu Reaktor',
    currentValue: 37.4,
    unit: '°C',
    maxValue: 55.0,
    severity: SensorSeverity.normal,
    history7Points: [35.1, 35.6, 36.2, 36.8, 37.0, 37.2, 37.4],
    sensorType: SensorType.temperature,
  );

  SensorMetric _pressureMetric = SensorMetric(
    name: 'Tekanan Biogas',
    currentValue: 1045.0,
    unit: 'hPa',
    maxValue: 1200.0,
    severity: SensorSeverity.warning,
    history7Points: [980.0, 995.0, 1010.0, 1025.0, 1032.0, 1038.0, 1045.0],
    sensorType: SensorType.pressure,
  );

  SensorMetric _mq4OutdoorMetric = SensorMetric(
    name: 'Gas Metana (Luar)',
    currentValue: 12.0,
    unit: 'ppm',
    maxValue: 200.0,
    severity: SensorSeverity.normal,
    history7Points: [8.0, 9.5, 10.0, 11.2, 11.5, 11.8, 12.0],
    sensorType: SensorType.mq4Outdoor,
  );

  SensorMetric _mq4BiodgesterMetric = SensorMetric(
    name: 'Gas Metana (Digester)',
    currentValue: 4850.0,
    unit: 'ppm',
    maxValue: 10000.0,
    severity: SensorSeverity.normal,
    history7Points: [4200.0, 4380.0, 4520.0, 4640.0, 4720.0, 4790.0, 4850.0],
    sensorType: SensorType.mq4Biodigester,
  );

  SensorMetric _mq136Metric = SensorMetric(
    name: 'H₂S Pasca Filter',
    currentValue: 3.2,
    unit: 'ppm',
    maxValue: 50.0,
    severity: SensorSeverity.normal,
    history7Points: [2.1, 2.5, 2.7, 2.9, 3.0, 3.1, 3.2],
    sensorType: SensorType.mq136,
  );

  Timer? _sensorSimulationTimer;

  // Getters
  List<WasteSubmission> get submissions => List.unmodifiable(_submissions);
  List<RewardItem> get rewards => List.unmodifiable(_rewards);
  List<RewardClaim> get claims => List.unmodifiable(_claims);
  List<PredictiveAlert> get activeAlerts =>
      _alerts.where((a) => !a.isDismissed).toList();
  List<GeneratedReport> get reports => List.unmodifiable(_reports);

  SensorMetric get temperatureMetric => _temperatureMetric;
  SensorMetric get pressureMetric => _pressureMetric;
  SensorMetric get mq4OutdoorMetric => _mq4OutdoorMetric;
  SensorMetric get mq4BiodigesterMetric => _mq4BiodgesterMetric;
  SensorMetric get mq136Metric => _mq136Metric;

  int get pendingSubmissionsCount =>
      _submissions.where((s) => s.status == SubmissionStatus.menunggu).length;

  int get pendingClaimsCount =>
      _claims.where((c) => c.status == ClaimStatus.menunggu).length;

  int get unreadNotificationsCount {
    if (_currentRole == UserRole.operator) {
      return pendingSubmissionsCount + activeAlerts.length;
    } else {
      return 1; // monthly report ready notice for Pengawas RW
    }
  }

  AppState() {
    _initInitialData();
    _startSensorSimulation();
  }

  void _initInitialData() {
    _wargaProfile = UserProfile(
      id: 'usr-warga-01',
      name: 'Budi Pratama',
      email: 'warga@gaskeun.id',
      phone: '0812-3456-7890',
      role: UserRole.warga,
      rw: 'RW 05',
      rt: 'RT 02',
      points: 1250,
      monthlyTargetKg: 25.0,
      currentMonthKg: 18.5,
      monthlySubmissionsCount: 6,
      monthlyClaimsCount: 1,
    );

    _operatorProfile = UserProfile(
      id: 'usr-opr-01',
      name: 'Pak Anton',
      email: 'operator@gaskeun.id',
      phone: '0813-9876-5432',
      role: UserRole.operator,
      rw: 'RW 05',
      rt: 'RT 03',
    );

    _pengawasProfile = UserProfile(
      id: 'usr-pgw-01',
      name: 'Bu Sari Handayani',
      email: 'pengawas@gaskeun.id',
      phone: '0811-2233-4455',
      role: UserRole.pengawas,
      rw: 'RW 05',
      rt: 'RT 01',
    );

    final now = DateTime.now();
    _submissions.addAll([
      WasteSubmission(
        id: 'sub-001',
        ticketCode: 'GSK-9102',
        citizenId: 'usr-warga-02',
        citizenName: 'Siti Rahma',
        citizenPhone: '0812-8877-1122',
        citizenRt: 'RT 03',
        weightKg: 2.8,
        points: 280,
        wasteCategory: 'Sisa Sayur & Nasi',
        createdAt: now.subtract(const Duration(minutes: 15)),
        status: SubmissionStatus.menunggu,
      ),
      WasteSubmission(
        id: 'sub-002',
        ticketCode: 'GSK-9101',
        citizenId: 'usr-warga-03',
        citizenName: 'Agus Wijaya',
        citizenPhone: '0857-4433-2211',
        citizenRt: 'RT 01',
        weightKg: 4.0,
        points: 400,
        wasteCategory: 'Kulit Buah & Ampas Kelapa',
        createdAt: now.subtract(const Duration(minutes: 42)),
        status: SubmissionStatus.menunggu,
      ),
      WasteSubmission(
        id: 'sub-003',
        ticketCode: 'GSK-9098',
        citizenId: 'usr-warga-01',
        citizenName: 'Budi Pratama',
        citizenPhone: '0812-3456-7890',
        citizenRt: 'RT 02',
        weightKg: 3.5,
        points: 350,
        wasteCategory: 'Organik Basah Rumah Tangga',
        createdAt: now.subtract(const Duration(hours: 3)),
        status: SubmissionStatus.diterima,
        verifiedAt: now.subtract(const Duration(hours: 2, minutes: 40)),
        operatorName: 'Pak Anton',
      ),
      WasteSubmission(
        id: 'sub-004',
        ticketCode: 'GSK-9080',
        citizenId: 'usr-warga-01',
        citizenName: 'Budi Pratama',
        citizenPhone: '0812-3456-7890',
        citizenRt: 'RT 02',
        weightKg: 2.0,
        points: 200,
        wasteCategory: 'Sisa Makanan',
        createdAt: now.subtract(const Duration(days: 2)),
        status: SubmissionStatus.diterima,
        verifiedAt: now.subtract(const Duration(days: 2, hours: -1)),
        operatorName: 'Pak Anton',
      ),
    ]);

    _rewards.addAll([
      RewardItem(
        id: 'rew-01',
        name: 'Pupuk Cair Digestate 1 Liter',
        description:
            'Pupuk organik cair hasil olahan biodigester siap pakai. Kaya unsur nitrogen, fosfor, dan kalium organik untuk menyuburkan tanaman hias dan sayuran.',
        pointsCost: 1000,
        stock: 36,
        unit: 'Botol 1L',
        iconType: 'liquid',
      ),
      RewardItem(
        id: 'rew-02',
        name: 'Kompos Padat Organik 2 Kg',
        description:
            'Kompos gembur murni hasil fermentasi sisa digestate. Bagus untuk media tanam pot dan kebun rumah warga.',
        pointsCost: 1500,
        stock: 20,
        unit: 'Kantong 2kg',
        iconType: 'compost',
      ),
      RewardItem(
        id: 'rew-03',
        name: 'Bibit Sayur Bayam & Kangkung',
        description:
            'Paket 2 sachet bibit sayuran hijau unggul untuk mendukung program ketahanan pangan pekarangan rumah.',
        pointsCost: 500,
        stock: 50,
        unit: 'Paket Bibit',
        iconType: 'seed',
      ),
    ]);

    _claims.addAll([
      RewardClaim(
        id: 'clm-01',
        voucherCode: 'VCR-7821',
        citizenId: 'usr-warga-02',
        citizenName: 'Siti Rahma',
        citizenPhone: '0812-8877-1122',
        rewardId: 'rew-01',
        rewardName: 'Pupuk Cair Digestate 1 Liter',
        pointsCost: 1000,
        requestedAt: now.subtract(const Duration(minutes: 30)),
        status: ClaimStatus.menunggu,
      ),
      RewardClaim(
        id: 'clm-02',
        voucherCode: 'VCR-7790',
        citizenId: 'usr-warga-01',
        citizenName: 'Budi Pratama',
        citizenPhone: '0812-3456-7890',
        rewardId: 'rew-01',
        rewardName: 'Pupuk Cair Digestate 1 Liter',
        pointsCost: 1000,
        requestedAt: now.subtract(const Duration(days: 4)),
        status: ClaimStatus.selesai,
        completedAt: now.subtract(const Duration(days: 4, hours: -1)),
      ),
    ]);

    _alerts.add(
      PredictiveAlert(
        id: 'alt-01',
        title: 'Prediksi Tekanan Gas Penuh',
        message:
            'Laju akumulasi gas meningkat +18%. Tekanan diprediksi mencapai batas kapasitas 1.150 hPa dalam 8 jam ke depan. Disarankan alirkan ke jaringan kompor warga.',
        severity: SensorSeverity.warning,
        timestamp: now.subtract(const Duration(minutes: 25)),
      ),
    );

    _reports.addAll([
      GeneratedReport(
        id: 'rep-08-2026',
        title: 'Laporan Ekosistem Biodigester RW 05',
        period: 'Agustus 2026',
        fileName: 'Laporan_GasKeun_RW05_Agu_2026.pdf',
        fileSize: '412 KB',
        generatedAt: DateTime(2026, 8, 31, 16, 0),
      ),
      GeneratedReport(
        id: 'rep-07-2026',
        title: 'Laporan Ekosistem Biodigester RW 05',
        period: 'Juli 2026',
        fileName: 'Laporan_GasKeun_RW05_Jul_2026.pdf',
        fileSize: '398 KB',
        generatedAt: DateTime(2026, 7, 31, 15, 30),
      ),
    ]);
  }

  void _startSensorSimulation() {
    _sensorSimulationTimer?.cancel();
    _sensorSimulationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      triggerSensorFluctuation();
    });
  }

  void triggerSensorFluctuation() {
    final random = Random();
    final tempDelta = (random.nextDouble() - 0.5) * 0.4;
    final newTemp = double.parse((_temperatureMetric.currentValue + tempDelta).toStringAsFixed(1));
    final updatedTempHistory = List<double>.from(_temperatureMetric.history7Points.sublist(1))
      ..add(newTemp);

    SensorSeverity tempSeverity = SensorSeverity.normal;
    if (newTemp > 45) {
      tempSeverity = SensorSeverity.critical;
    } else if (newTemp > 40) {
      tempSeverity = SensorSeverity.warning;
    }

    _temperatureMetric = SensorMetric(
      name: 'Suhu Reaktor',
      currentValue: newTemp,
      unit: '°C',
      maxValue: 55.0,
      severity: tempSeverity,
      history7Points: updatedTempHistory,
      sensorType: SensorType.temperature,
    );

    final pressureDelta = (random.nextDouble() - 0.45) * 8.0;
    final newPressure =
        double.parse((_pressureMetric.currentValue + pressureDelta).toStringAsFixed(0));
    final updatedPressureHistory = List<double>.from(_pressureMetric.history7Points.sublist(1))
      ..add(newPressure);

    SensorSeverity pressureSeverity = SensorSeverity.normal;
    if (newPressure > 1100) {
      pressureSeverity = SensorSeverity.critical;
    } else if (newPressure > 1030) {
      pressureSeverity = SensorSeverity.warning;
    }

    _pressureMetric = SensorMetric(
      name: 'Tekanan Biogas',
      currentValue: newPressure,
      unit: 'hPa',
      maxValue: 1200.0,
      severity: pressureSeverity,
      history7Points: updatedPressureHistory,
      sensorType: SensorType.pressure,
    );

    final mq4OutDelta = (random.nextDouble() - 0.4) * 3.0;
    final newMq4Out = double.parse(
        (_mq4OutdoorMetric.currentValue + mq4OutDelta).clamp(5.0, 200.0).toStringAsFixed(1));
    final updatedMq4OutHistory = List<double>.from(_mq4OutdoorMetric.history7Points.sublist(1))
      ..add(newMq4Out);
    SensorSeverity mq4OutSeverity = SensorSeverity.normal;
    if (newMq4Out > 100) {
      mq4OutSeverity = SensorSeverity.critical;
    } else if (newMq4Out > 40) {
      mq4OutSeverity = SensorSeverity.warning;
    }
    _mq4OutdoorMetric = SensorMetric(
      name: 'Gas Metana (Luar)',
      currentValue: newMq4Out,
      unit: 'ppm',
      maxValue: 200.0,
      severity: mq4OutSeverity,
      history7Points: updatedMq4OutHistory,
      sensorType: SensorType.mq4Outdoor,
    );

    final mq4DigDelta = (random.nextDouble() - 0.45) * 80.0;
    final newMq4Dig = double.parse(
        (_mq4BiodgesterMetric.currentValue + mq4DigDelta).clamp(3000.0, 10000.0).toStringAsFixed(0));
    final updatedMq4DigHistory = List<double>.from(_mq4BiodgesterMetric.history7Points.sublist(1))
      ..add(newMq4Dig);
    SensorSeverity mq4DigSeverity = SensorSeverity.normal;
    if (newMq4Dig > 8000) {
      mq4DigSeverity = SensorSeverity.critical;
    } else if (newMq4Dig > 6500) {
      mq4DigSeverity = SensorSeverity.warning;
    }
    _mq4BiodgesterMetric = SensorMetric(
      name: 'Gas Metana (Digester)',
      currentValue: newMq4Dig,
      unit: 'ppm',
      maxValue: 10000.0,
      severity: mq4DigSeverity,
      history7Points: updatedMq4DigHistory,
      sensorType: SensorType.mq4Biodigester,
    );

    final mq136Delta = (random.nextDouble() - 0.45) * 0.6;
    final newMq136 = double.parse(
        (_mq136Metric.currentValue + mq136Delta).clamp(0.5, 50.0).toStringAsFixed(1));
    final updatedMq136History = List<double>.from(_mq136Metric.history7Points.sublist(1))
      ..add(newMq136);
    SensorSeverity mq136Severity = SensorSeverity.normal;
    if (newMq136 > 20) {
      mq136Severity = SensorSeverity.critical;
    } else if (newMq136 > 10) {
      mq136Severity = SensorSeverity.warning;
    }
    _mq136Metric = SensorMetric(
      name: 'H₂S Pasca Filter',
      currentValue: newMq136,
      unit: 'ppm',
      maxValue: 50.0,
      severity: mq136Severity,
      history7Points: updatedMq136History,
      sensorType: SensorType.mq136,
    );

    notifyListeners();
  }

  // Authentication & Login/Logout
  bool login(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    DemoUserCredential? matched;
    for (final cred in demoCredentials) {
      if (cred.email.toLowerCase() == cleanEmail) {
        matched = cred;
        break;
      }
    }

    if (matched != null) {
      if (cleanPassword == matched.password || cleanPassword.length >= 6) {
        _currentRole = matched.role;
        _isLoggedIn = true;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } else {
      if (cleanEmail.contains('@') && cleanPassword.length >= 6) {
        if (cleanEmail.contains('pengawas') || cleanEmail.contains('rw') || cleanEmail.contains('sari')) {
          _currentRole = UserRole.pengawas;
        } else {
          _currentRole = UserRole.operator;
        }
        _isLoggedIn = true;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    }
  }

  // Login dengan Akun Google
  void loginWithGoogleAccount({
    required String email,
    required String displayName,
    String? phone,
    String? rt,
    String? rw,
  }) {
    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.contains('pengawas') || cleanEmail.contains('rw') || cleanEmail.contains('sari')) {
      _pengawasProfile = UserProfile(
        id: _pengawasProfile.id,
        name: displayName.isNotEmpty ? displayName : _pengawasProfile.name,
        email: email,
        phone: _pengawasProfile.phone,
        role: UserRole.pengawas,
        rw: _pengawasProfile.rw,
        rt: _pengawasProfile.rt,
      );
      _currentRole = UserRole.pengawas;
    } else {
      _operatorProfile = UserProfile(
        id: _operatorProfile.id,
        name: displayName.isNotEmpty ? displayName : _operatorProfile.name,
        email: email,
        phone: _operatorProfile.phone,
        role: UserRole.operator,
        rw: _operatorProfile.rw,
        rt: _operatorProfile.rt,
      );
      _currentRole = UserRole.operator;
    }

    _isLoggedIn = true;
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Role switching between Operator and Pengawas
  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void updateMachineLocation(String name, String location) {
    machineName = name;
    machineLocation = location;
    notifyListeners();
  }

  // Operator Actions: Verify Waste Submission
  void verifySubmission(String submissionId, bool accepted) {
    final index = _submissions.indexWhere((s) => s.id == submissionId);
    if (index != -1) {
      final sub = _submissions[index];
      sub.status = accepted ? SubmissionStatus.diterima : SubmissionStatus.ditolak;
      sub.verifiedAt = DateTime.now();
      sub.operatorName = _operatorProfile.name;

      if (accepted && sub.citizenId == _wargaProfile.id) {
        _wargaProfile.points += sub.points;
        _wargaProfile.currentMonthKg += sub.weightKg;
        _wargaProfile.monthlySubmissionsCount += 1;
      }

      notifyListeners();
    }
  }

  // Operator Actions: Complete Claim
  void completeClaim(String claimId) {
    final index = _claims.indexWhere((c) => c.id == claimId);
    if (index != -1) {
      _claims[index].status = ClaimStatus.selesai;
      _claims[index].completedAt = DateTime.now();
      notifyListeners();
    }
  }

  // Operator Actions: Dismiss AI Alert
  void dismissAlert(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      _alerts[index].isDismissed = true;
      notifyListeners();
    }
  }

  // Pengawas RW Metrics
  double get totalWasteKgRW {
    double base = 512.5;
    for (final s in _submissions) {
      if (s.status == SubmissionStatus.diterima) {
        base += s.weightKg;
      }
    }
    return base;
  }

  double get totalBiogasM3RW => (totalWasteKgRW * 0.42);
  double get totalDigestateLRW => (totalWasteKgRW * 0.78);
  int get activeKkCount => 84;
  int get totalKkRW => 120;

  List<RtParticipationData> get rtParticipationList {
    return [
      RtParticipationData(
        rtName: 'RT 01',
        activeKk: 18,
        totalKk: 22,
        totalWasteKg: 112.4,
        isTargetReached: true,
      ),
      RtParticipationData(
        rtName: 'RT 02',
        activeKk: 16,
        totalKk: 20,
        totalWasteKg: 104.8,
        isTargetReached: true,
      ),
      RtParticipationData(
        rtName: 'RT 03',
        activeKk: 15,
        totalKk: 20,
        totalWasteKg: 88.6,
        isTargetReached: false,
      ),
      RtParticipationData(
        rtName: 'RT 04',
        activeKk: 14,
        totalKk: 18,
        totalWasteKg: 79.2,
        isTargetReached: false,
      ),
      RtParticipationData(
        rtName: 'RT 05',
        activeKk: 11,
        totalKk: 20,
        totalWasteKg: 68.5,
        isTargetReached: false,
      ),
      RtParticipationData(
        rtName: 'RT 06',
        activeKk: 10,
        totalKk: 20,
        totalWasteKg: 59.0,
        isTargetReached: false,
      ),
    ];
  }

  List<MonthlyParticipationTrend> get monthlyParticipationTrends {
    return [
      MonthlyParticipationTrend(monthLabel: 'Apr', activeKk: 45, wasteKg: 280),
      MonthlyParticipationTrend(monthLabel: 'Mei', activeKk: 56, wasteKg: 340),
      MonthlyParticipationTrend(monthLabel: 'Jun', activeKk: 64, wasteKg: 395),
      MonthlyParticipationTrend(monthLabel: 'Jul', activeKk: 72, wasteKg: 440),
      MonthlyParticipationTrend(monthLabel: 'Agu', activeKk: 78, wasteKg: 490),
      MonthlyParticipationTrend(monthLabel: 'Sep', activeKk: 84, wasteKg: 520),
    ];
  }

  void addGeneratedReport(GeneratedReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorSimulationTimer?.cancel();
    super.dispose();
  }
}
