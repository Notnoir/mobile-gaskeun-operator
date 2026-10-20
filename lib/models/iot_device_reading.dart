class IotDeviceReading {
  final double temperatureC;
  final double pressureKpa;
  final int mq4HolderRaw;
  final int mq4BiodigesterRaw;
  final int mq136FilterAmbientRaw;
  final String quality;
  final int sequence;
  final String source;
  final DateTime timestamp;

  IotDeviceReading({
    required this.temperatureC,
    required this.pressureKpa,
    required this.mq4HolderRaw,
    required this.mq4BiodigesterRaw,
    required this.mq136FilterAmbientRaw,
    required this.quality,
    required this.sequence,
    required this.source,
    required this.timestamp,
  });

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? defaultVal;
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? defaultVal);
    }
    return defaultVal;
  }

  factory IotDeviceReading.fromJson(Map<dynamic, dynamic> json) {
    final rawTimestamp = json['timestamp_ms'];
    DateTime time;
    if (rawTimestamp is num) {
      time = DateTime.fromMillisecondsSinceEpoch(rawTimestamp.toInt());
    } else if (rawTimestamp is String) {
      final parsed = int.tryParse(rawTimestamp);
      time = parsed != null
          ? DateTime.fromMillisecondsSinceEpoch(parsed)
          : DateTime.now();
    } else {
      time = DateTime.now();
    }

    return IotDeviceReading(
      temperatureC: _parseDouble(json['temperature_c']),
      pressureKpa: _parseDouble(json['pressure_kpa']),
      mq4HolderRaw: _parseInt(json['mq4_holder_raw']),
      mq4BiodigesterRaw: _parseInt(json['mq4_biodigester_raw']),
      mq136FilterAmbientRaw: _parseInt(json['mq136_filter_ambient_raw']),
      quality: json['quality']?.toString() ?? 'normal',
      sequence: _parseInt(json['sequence']),
      source: json['source']?.toString() ?? 'device',
      timestamp: time,
    );
  }

  /// Status apakah perangkat aktif mengirim data dalam rentang 24 jam terakhir
  bool get isOnline {
    final diff = DateTime.now().difference(timestamp);
    return diff.inHours.abs() < 24;
  }
}
