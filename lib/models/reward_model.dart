enum ClaimStatus {
  menunggu,
  selesai,
}

extension ClaimStatusExtension on ClaimStatus {
  String get label {
    switch (this) {
      case ClaimStatus.menunggu:
        return 'Menunggu Pengambilan';
      case ClaimStatus.selesai:
        return 'Selesai Diambil';
    }
  }
}

class RewardItem {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  int stock;
  final String unit;
  final String iconType;

  RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.stock,
    required this.unit,
    this.iconType = 'liquid',
  });
}

class RewardClaim {
  final String id;
  final String voucherCode;
  final String citizenId;
  final String citizenName;
  final String citizenPhone;
  final String rewardId;
  final String rewardName;
  final int pointsCost;
  final int quantity;
  final DateTime requestedAt;
  ClaimStatus status;
  DateTime? completedAt;

  RewardClaim({
    required this.id,
    required this.voucherCode,
    required this.citizenId,
    required this.citizenName,
    required this.citizenPhone,
    required this.rewardId,
    required this.rewardName,
    required this.pointsCost,
    this.quantity = 1,
    required this.requestedAt,
    this.status = ClaimStatus.menunggu,
    this.completedAt,
  });
}
