import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/waste_submission_model.dart';
import '../../../providers/app_state.dart';

class OperatorSetoranTab extends StatefulWidget {
  const OperatorSetoranTab({super.key});

  @override
  State<OperatorSetoranTab> createState() => _OperatorSetoranTabState();
}

class _OperatorSetoranTabState extends State<OperatorSetoranTab> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'menunggu'; // 'semua', 'menunggu', 'selesai'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAcceptConfirmation(BuildContext context, WasteSubmission sub, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Penerimaan Sampah', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Warga: ${sub.citizenName} (${sub.citizenRt})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Berat Sampah: ${Formatters.weight(sub.weightKg)}', style: const TextStyle(fontSize: 13)),
            Text('Kategori: ${sub.wasteCategory}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: AppColors.primaryDark, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Poin yang akan dikreditkan: +${sub.points} pts',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              state.verifySubmission(sub.id, true);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Setoran tiket ${sub.ticketCode} diterima! +${sub.points} pts telah ditambahkan ke akun warga.'),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Terima Setoran'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final query = _searchController.text.toLowerCase().trim();

    var list = state.submissions.where((s) {
      if (_filter == 'menunggu' && s.status != SubmissionStatus.menunggu) return false;
      if (_filter == 'selesai' && s.status == SubmissionStatus.menunggu) return false;

      if (query.isNotEmpty) {
        final matchName = s.citizenName.toLowerCase().contains(query);
        final matchTicket = s.ticketCode.toLowerCase().contains(query);
        final matchRt = s.citizenRt.toLowerCase().contains(query);
        return matchName || matchTicket || matchRt;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Antrian Header Stats
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
                        color: AppColors.warningLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hourglass_top, color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Antrian Setoran Warga', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('${state.pendingSubmissionsCount} setoran menunggu verifikasi', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: state.pendingSubmissionsCount > 0 ? AppColors.warning : AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${state.pendingSubmissionsCount} Menunggu',
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
              hintText: 'Cari nama warga, RT, atau kode tiket...',
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
          const SizedBox(height: 12),

          // Filter chips
          Row(
            children: [
              _buildFilterChip('Menunggu', 'menunggu', state.pendingSubmissionsCount),
              const SizedBox(width: 8),
              _buildFilterChip('Selesai', 'selesai', null),
              const SizedBox(width: 8),
              _buildFilterChip('Semua', 'semua', null),
            ],
          ),
          const SizedBox(height: 16),

          // Submissions List
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Center(
                child: Column(
                  children: const [
                    Icon(Icons.inbox, size: 40, color: AppColors.textMuted),
                    SizedBox(height: 8),
                    Text('Tidak ada data setoran yang cocok.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ...list.map((sub) => _buildSubmissionCard(context, sub, state)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String key, int? count) {
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, WasteSubmission sub, AppState state) {
    final isPending = sub.status == SubmissionStatus.menunggu;
    final isAccepted = sub.status == SubmissionStatus.diterima;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending ? AppColors.warning.withOpacity(0.5) : AppColors.cardBorder,
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
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      sub.citizenName.substring(0, 1),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sub.citizenName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('${sub.citizenRt} • ${sub.citizenPhone}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  sub.ticketCode,
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
                  const Text('Berat Aktual:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(Formatters.weight(sub.weightKg), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reward Poin:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('+${sub.points} pts', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Kategori:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(sub.wasteCategory, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Formatters.dateTime(sub.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              if (isPending)
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => state.verifySubmission(sub.id, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Tolak', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showAcceptConfirmation(context, sub, state),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Terima', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAccepted ? AppColors.primaryLight : AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sub.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAccepted ? AppColors.primaryDark : AppColors.danger,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
