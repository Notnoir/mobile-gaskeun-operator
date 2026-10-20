import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/waste_submission_model.dart';
import '../../../providers/app_state.dart';

class WargaSetorTab extends StatefulWidget {
  const WargaSetorTab({super.key});

  @override
  State<WargaSetorTab> createState() => _WargaSetorTabState();
}

class _WargaSetorTabState extends State<WargaSetorTab> {
  final TextEditingController _weightController = TextEditingController();
  String _selectedCategory = 'Sisa Dapur & Sayuran';
  int _estimatedPoints = 0;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Sisa Dapur & Sayuran',
    'Nasi, Roti & Olahan Biji',
    'Kulit Buah-buahan',
    'Ampas Kelapa & Teh/Kopi',
    'Sisa Makanan Matang (Tanpa Tulang Keras)',
  ];

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculatePoints);
  }

  void _calculatePoints() {
    final text = _weightController.text.replaceAll(',', '.').trim();
    final weight = double.tryParse(text);
    setState(() {
      if (weight != null && weight > 0) {
        _estimatedPoints = (weight * 100).round();
      } else {
        _estimatedPoints = 0;
      }
    });
  }

  Future<void> _openGoogleMapsRoute() async {
    // RW Biodigester coordinates mock
    const googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=-6.200000,106.816666';
    final uri = Uri.parse(googleMapsUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Membuka rute ke Fasilitas Biodigester RW 05...')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menavigasi ke Fasilitas Biodigester RW 05')),
        );
      }
    }
  }

  void _submitWaste() {
    final text = _weightController.text.replaceAll(',', '.').trim();
    final weight = double.tryParse(text);

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan estimasi berat sampah yang valid'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final state = context.read<AppState>();
      final submission = state.submitWaste(
        weightKg: weight,
        category: _selectedCategory,
      );

      setState(() {
        _isSubmitting = false;
        _weightController.clear();
        _estimatedPoints = 0;
      });

      _showTicketDialog(submission);
    });
  }

  void _showTicketDialog(WasteSubmission submission) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'Tiket Setoran Dibuat!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tunjukkan kode tiket ini kepada petugas operator biodigester saat menyerahkan ember sampah.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'KODE TIKET DIGITAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    submission.ticketCode,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                      letterSpacing: 2,
                    ),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimasi Berat:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(Formatters.weight(submission.weightKg), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimasi Poin:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text('+${submission.points} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Facility Location Card with Maps route button
          Container(
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on, color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fasilitas Biodigester Terdekat',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.machineLocation,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openGoogleMapsRoute,
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Buka Rute di Google Maps'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Peringatan Organik Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warning.withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Peringatan Jenis Sampah',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Hanya terima sampah organik basah/lunak yang sudah dipilah. Dilarang mencampur dengan plastik, tulang besar, atau minyak jelantah berlebih.',
                        style: TextStyle(fontSize: 11, color: Color(0xFFB45309), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Form Setor Sampah
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Formulir Pengajuan Setoran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Kategori Sampah Organik',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Estimasi Berat Sampah (kg)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Contoh: 1.5 atau 2.8',
                    prefixIcon: const Icon(Icons.scale, color: AppColors.primary),
                    suffixText: 'kg',
                    suffixStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Live points conversion banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Konversi Standar:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('1 kg = 100 poin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Estimasi Reward:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                            '+$_estimatedPoints pts',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: (_isSubmitting || _estimatedPoints <= 0) ? null : _submitWaste,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Konfirmasi & Buat Tiket Setoran'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
