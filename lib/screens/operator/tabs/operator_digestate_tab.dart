import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/reward_model.dart';
import '../../../providers/app_state.dart';

class OperatorDigestateTab extends StatefulWidget {
  const OperatorDigestateTab({super.key});

  @override
  State<OperatorDigestateTab> createState() => _OperatorDigestateTabState();
}

class _OperatorDigestateTabState extends State<OperatorDigestateTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final query = _searchController.text.toLowerCase().trim();

    final claims = state.claims.where((c) {
      if (query.isNotEmpty) {
        final matchName = c.citizenName.toLowerCase().contains(query);
        final matchVoucher = c.voucherCode.toLowerCase().contains(query);
        final matchPhone = c.citizenPhone.contains(query);
        return matchName || matchVoucher || matchPhone;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.infoLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.water_drop, color: AppColors.info, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Klaim Pupuk Digestate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('${state.pendingClaimsCount} permintaan menunggu penyerahan', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: state.pendingClaimsCount > 0 ? AppColors.info : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.pendingClaimsCount} Antrian',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari nama warga atau kode voucher...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          if (claims.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: Text('Tidak ada klaim reward.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            ...claims.map((claim) => _buildClaimCard(context, claim, state)),
        ],
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, RewardClaim claim, AppState state) {
    final isPending = claim.status == ClaimStatus.menunggu;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.info.withOpacity(0.5) : AppColors.cardBorder,
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.infoLight,
                    child: Text(
                      claim.citizenName.substring(0, 1),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.info),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(claim.citizenName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(claim.citizenPhone, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  claim.voucherCode,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
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
                  const Text('Item Produk:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(claim.rewardName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Poin Ditukar:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('${claim.pointsCost} pts', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Formatters.dateTime(claim.requestedAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              if (isPending)
                ElevatedButton.icon(
                  onPressed: () {
                    state.completeClaim(claim.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Klaim ${claim.voucherCode} atas nama ${claim.citizenName} ditandai selesai!'),
                        backgroundColor: AppColors.primaryDark,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Tandai Selesai', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Selesai Diserahkan',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
