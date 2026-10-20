import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/reward_model.dart';
import '../../../providers/app_state.dart';

class WargaTukarTab extends StatelessWidget {
  const WargaTukarTab({super.key});

  void _showRedemptionDialog(BuildContext context, RewardItem item) {
    final state = context.read<AppState>();
    final userPoints = state.wargaProfile.points;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Penukaran Poin', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menukar poin dengan:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saldo Saat Ini:', style: TextStyle(fontSize: 12)),
                      Text('${userPoints} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Biaya Penukaran:', style: TextStyle(fontSize: 12, color: AppColors.danger)),
                      Text('-${item.pointsCost} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    ],
                  ),
                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sisa Saldo Poin:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('${userPoints - item.pointsCost} pts', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final success = state.claimReward(item, 1);
              if (success) {
                _showSuccessClaimDialog(context, item);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 42),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Ya, Tukar Sekarang'),
          ),
        ],
      ),
    );
  }

  void _showSuccessClaimDialog(BuildContext context, RewardItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 14),
            const Text(
              'Penukaran Berhasil!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Anda telah menukar ${item.name}. Permintaan pengambilan telah dikirimkan ke petugas biodigester.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.storefront, color: AppColors.primaryDark, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ambil produk di Fasilitas Biodigester RW 05 pada jam operasional (08:00 - 17:00 WIB).',
                      style: TextStyle(fontSize: 11, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final userPoints = state.wargaProfile.points;
    final rewards = state.rewards;
    final claims = state.claims.where((c) => c.citizenId == state.wargaProfile.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poin Balance Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Saldo Poin Aktif', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('Gunakan untuk klaim reward', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Text(
                  Formatters.points(userPoints),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Katalog Reward Komunitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...rewards.map((item) => _buildRewardCard(context, item, userPoints)),

          const SizedBox(height: 24),
          const Text(
            'Riwayat Klaim Saya',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (claims.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: Text(
                  'Belum ada penukaran reward.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ...claims.map((claim) => _buildClaimHistoryCard(claim)),
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, RewardItem item, int userPoints) {
    final canAfford = userPoints >= item.pointsCost;
    final hasStock = item.stock > 0;
    final isAvailable = canAfford && hasStock;

    IconData itemIcon;
    if (item.iconType == 'liquid') {
      itemIcon = Icons.water_drop;
    } else if (item.iconType == 'compost') {
      itemIcon = Icons.eco;
    } else {
      itemIcon = Icons.spa;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(itemIcon, color: AppColors.primaryDark, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.points(item.pointsCost),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sisa Stok: ${item.stock} ${item.unit}',
                    style: TextStyle(
                      fontSize: 11,
                      color: hasStock ? AppColors.textSecondary : AppColors.danger,
                      fontWeight: hasStock ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isAvailable ? () => _showRedemptionDialog(context, item) : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(110, 40),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.cardBorder,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  !hasStock
                      ? 'Stok Habis'
                      : (!canAfford ? 'Poin Kurang' : 'Tukar Poin'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClaimHistoryCard(RewardClaim claim) {
    final isDone = claim.status == ClaimStatus.selesai;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDone ? AppColors.primaryLight : AppColors.warningLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_circle_outline : Icons.pending_actions,
              color: isDone ? AppColors.primary : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(claim.rewardName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Kode Voucher: ${claim.voucherCode}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                const SizedBox(height: 2),
                Text(Formatters.dateTime(claim.requestedAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDone ? AppColors.primaryLight : AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              claim.status.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDone ? AppColors.primaryDark : const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
