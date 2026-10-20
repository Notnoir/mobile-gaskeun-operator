import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class WargaEdukasiTab extends StatelessWidget {
  const WargaEdukasiTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Tahukah Anda
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF115E59)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tahukah Anda?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Setiap 10 kg sampah organik dapur yang diolah biodigester dapat menghasilkan biogas setara dengan 1/2 tabung gas LPG portabel, serta menghasilkan 7 liter pupuk organik cair!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Panduan Pemilahan Sampah Biodigester',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pastikan sampah yang Anda bawa memenuhi kriteria agar bakteri pengurai bekerja optimal.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Yang Boleh Masuk (Centang Hijau)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Boleh Masuk Biodigester',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCheckItem('Sisa sayuran mentah & daun-daunan segar/layu'),
                _buildCheckItem('Kulit buah-buahan lunak (pisang, pepaya, mangga, dll.)'),
                _buildCheckItem('Sisa nasi, bubur, mie, dan olahan tepung'),
                _buildCheckItem('Ampas kelapa, ampas kopi, dan kantong teh (tanpa tali/staples)'),
                _buildCheckItem('Sisa kuah sayur atau makanan berair (tanpa minyak tebal)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Yang Tidak Boleh Masuk (Silang Merah)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.danger.withOpacity(0.4), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.dangerLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: AppColors.danger, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Dilarang Masuk Biodigester',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCrossItem('Plastik, styrofoam, kertas berlapis lilin, dan kemasan sachet'),
                _buildCrossItem('Tulang hewan berukuran besar & cangkang kerang keras'),
                _buildCrossItem('Minyak goreng jelantah bekas pakai dalam jumlah banyak'),
                _buildCrossItem('Bahan kimia, sabun detergen, disinfektan, atau obat-obatan'),
                _buildCrossItem('Kotoran hewan peliharaan (kucing/anjing yang memakan daging pabrikan)'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tips Praktis di Rumah (Expandable)
          const Text(
            'Tips Praktis dari Komunitas',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildExpandableTip(
            title: 'Gunakan Ember Bertutup Rapat',
            content:
                'Sediakan wadah kecil bertutup di area wastafel dapur Anda. Tutup rapat agar tidak memicu bau dan lalat sebelum dibawa ke biodigester.',
          ),
          _buildExpandableTip(
            title: 'Potong Kecil Sayur & Buah',
            content:
                'Memotong sisa kulit buah atau batang sayur menjadi bagian lebih kecil mempercepat proses fermentasi bakteri di dalam reaktor biogas hingga 40%.',
          ),
          _buildExpandableTip(
            title: 'Waktu Setoran Terbaik',
            content:
                'Setoran sampah organik paling optimal diserahkan antara pukul 08:00 - 10:00 WIB agar langsung dimasukkan ke reaktor saat suhu awal mulai stabil.',
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrossItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTip({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          title: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
              child: Text(
                content,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
