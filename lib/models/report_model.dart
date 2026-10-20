class RtParticipationData {
  final String rtName;
  final int activeKk;
  final int totalKk;
  final double totalWasteKg;
  final bool isTargetReached;

  RtParticipationData({
    required this.rtName,
    required this.activeKk,
    required this.totalKk,
    required this.totalWasteKg,
    required this.isTargetReached,
  });

  double get participationRate => totalKk == 0 ? 0 : (activeKk / totalKk) * 100;
}

class MonthlyParticipationTrend {
  final String monthLabel;
  final int activeKk;
  final double wasteKg;

  MonthlyParticipationTrend({
    required this.monthLabel,
    required this.activeKk,
    required this.wasteKg,
  });
}

class GeneratedReport {
  final String id;
  final String title;
  final String period;
  final String fileName;
  final String fileSize;
  final DateTime generatedAt;

  GeneratedReport({
    required this.id,
    required this.title,
    required this.period,
    required this.fileName,
    required this.fileSize,
    required this.generatedAt,
  });
}
