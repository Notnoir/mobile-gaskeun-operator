enum SensorSeverity {
  normal,
  warning,
  critical,
}

extension SensorSeverityExtension on SensorSeverity {
  String get label {
    switch (this) {
      case SensorSeverity.normal:
        return 'Normal';
      case SensorSeverity.warning:
        return 'Peringatan';
      case SensorSeverity.critical:
        return 'Kritis';
    }
  }
}

enum SensorType {
  temperature,
  pressure,
  mq4Outdoor,    // MQ-4: deteksi kebocoran gas, dipasang di luar
  mq4Biodigester, // MQ-4: dipasang di dalam biodigester
  mq136,         // MQ-136: deteksi H2S, dipasang setelah filter
}

extension SensorTypeExtension on SensorType {
  String get displayName {
    switch (this) {
      case SensorType.temperature:
        return 'Suhu Reaktor';
      case SensorType.pressure:
        return 'Tekanan Biogas';
      case SensorType.mq4Outdoor:
        return 'Gas Metana (Luar)';
      case SensorType.mq4Biodigester:
        return 'Gas Metana (Digester)';
      case SensorType.mq136:
        return 'H₂S Pasca Filter';
    }
  }

  String get sensorCode {
    switch (this) {
      case SensorType.temperature:
        return 'TEMP-01';
      case SensorType.pressure:
        return 'PRES-01';
      case SensorType.mq4Outdoor:
        return 'MQ4-EXT';
      case SensorType.mq4Biodigester:
        return 'MQ4-DIG';
      case SensorType.mq136:
        return 'MQ136-F';
    }
  }

  String get placementInfo {
    switch (this) {
      case SensorType.temperature:
        return 'Di dalam reaktor biodigester';
      case SensorType.pressure:
        return 'Saluran gas utama reaktor';
      case SensorType.mq4Outdoor:
        return 'Dipasang di luar — deteksi kebocoran gas';
      case SensorType.mq4Biodigester:
        return 'Dipasang di dalam biodigester';
      case SensorType.mq136:
        return 'Dipasang setelah filter (post-filter H₂S)';
    }
  }
}

class SensorMetric {
  final String name;
  final double currentValue;
  final String unit;
  final double maxValue;
  final SensorSeverity severity;
  final List<double> history7Points;
  final SensorType sensorType;

  SensorMetric({
    required this.name,
    required this.currentValue,
    required this.unit,
    required this.maxValue,
    required this.severity,
    required this.history7Points,
    this.sensorType = SensorType.temperature,
  });
}

class PredictiveAlert {
  final String id;
  final String title;
  final String message;
  final SensorSeverity severity;
  final DateTime timestamp;
  bool isDismissed;

  PredictiveAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isDismissed = false,
  });
}
