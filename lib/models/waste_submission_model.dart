enum SubmissionStatus {
  menunggu,
  diterima,
  ditolak,
}

extension SubmissionStatusExtension on SubmissionStatus {
  String get label {
    switch (this) {
      case SubmissionStatus.menunggu:
        return 'Menunggu';
      case SubmissionStatus.diterima:
        return 'Diterima';
      case SubmissionStatus.ditolak:
        return 'Ditolak';
    }
  }
}

class WasteSubmission {
  final String id;
  final String ticketCode;
  final String citizenId;
  final String citizenName;
  final String citizenPhone;
  final String citizenRt;
  final double weightKg;
  final int points;
  final String wasteCategory;
  final DateTime createdAt;
  SubmissionStatus status;
  DateTime? verifiedAt;
  String? operatorName;

  WasteSubmission({
    required this.id,
    required this.ticketCode,
    required this.citizenId,
    required this.citizenName,
    required this.citizenPhone,
    required this.citizenRt,
    required this.weightKg,
    required this.points,
    this.wasteCategory = 'Organik Basah / Sisa Dapur',
    required this.createdAt,
    this.status = SubmissionStatus.menunggu,
    this.verifiedAt,
    this.operatorName,
  });
}
