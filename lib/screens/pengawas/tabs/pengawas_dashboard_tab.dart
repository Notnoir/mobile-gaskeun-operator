import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/app_state.dart';

class PengawasDashboardTab extends StatefulWidget {
  final VoidCallback? onNavigateToLaporan;

  const PengawasDashboardTab({
    super.key,
    this.onNavigateToLaporan,
  });

  @override
  State<PengawasDashboardTab> createState() => _PengawasDashboardTabState();
}

class _PengawasDashboardTabState extends State<PengawasDashboardTab> {
  String _timeRange = 'Okt 2026';
  bool _showDetailedTables = false;

  final List<String> _timeRangeOptions = [
    'Okt 2026',
    'Sep 2026',
    'Agu 2026',
    '3 Bulan Terakhir',
    'Tahun 2026',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.activeProfile;
    final rtList = state.rtParticipationList;
    final trends = state.monthlyParticipationTrends;

    // Hitung persentase partisipasi RW
    final double participationRate = state.totalKkRW > 0
        ? (state.activeKkCount / state.totalKkRW) * 100
        : 68.4;

    // Estimasi jam api & reduksi gas metana
    final int flameHours = (state.totalBiogasM3RW * 3).toInt();
    final int co2SavedKg = (state.totalWasteKgRW * 0.27).toInt();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Sambutan & Status Wilayah Pengawas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Halo, ${profile.name.isNotEmpty ? profile.name : "Bu Sari Handayani"}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('ðŸ‘‹', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketua RW 05 â€¢ Kelurahan Sukamaju â€¢ Periode 2024â€“2027',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Filter Periode Chip
                    PopupMenuButton<String>(
                      initialValue: _timeRange,
                      onSelected: (val) => setState(() => _timeRange = val),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      itemBuilder: (ctx) => _timeRangeOptions.map((opt) {
                        return PopupMenuItem(
                          value: opt,
                          child: Text(
                            opt,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: opt == _timeRange
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: opt == _timeRange
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                            ),
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _timeRange,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.expand_more_rounded,
                              size: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sinkronisasi RTDB Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sinkronisasi Realtime RTDB',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'â€¢ Live Terhubung',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. 4 Kartu Metrik Utama RW (FR-RW-01) Grid 2x2
          Row(
            children: [
              // Metrik 1: Sampah Terkelola
              Expanded(
                child: _buildMetricCard(
                  title: 'Sampah Terkelola',
                  value: Formatters.number(state.totalWasteKgRW),
                  unit: 'kg',
                  subtitle: 'Target 2.0 Ton (71%)',
                  progress: 0.71,
                  progressColor: AppColors.primaryContainer,
                  icon: Icons.delete_sweep_rounded,
                  iconBg: AppColors.primaryContainer.withOpacity(0.15),
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Metrik 2: Partisipasi KK
              Expanded(
                child: _buildMetricCard(
                  title: 'Partisipasi KK',
                  value: '${participationRate.toStringAsFixed(1)}%',
                  unit: '',
                  subtitle: '${state.activeKkCount} / ${state.totalKkRW} KK Aktif',
                  progress: participationRate / 100.0,
                  progressColor: AppColors.tertiaryContainer,
                  icon: Icons.group_rounded,
                  iconBg: AppColors.tertiaryContainer.withOpacity(0.2),
                  iconColor: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Metrik 3: Biogas Dihasilkan
              Expanded(
                child: _buildMetricCard(
                  title: 'Biogas Hasil',
                  value: Formatters.number(state.totalBiogasM3RW),
                  unit: 'mÂ³',
                  subtitle: 'â‰ˆ $flameHours Jam Api Warga',
                  progress: 0.78,
                  progressColor: AppColors.secondaryContainer,
                  icon: Icons.local_fire_department_rounded,
                  iconBg: AppColors.secondaryContainer.withOpacity(0.2),
                  iconColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              // Metrik 4: Reduksi Emisi
              Expanded(
                child: _buildMetricCard(
                  title: 'Reduksi Emisi',
                  value: '$co2SavedKg',
                  unit: 'kg',
                  subtitle: 'Gas metana dicegah',
                  progress: 0.85,
                  progressColor: AppColors.primary,
                  icon: Icons.co2_rounded,
                  iconBg: AppColors.primaryContainer.withOpacity(0.2),
                  iconColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Statistik Partisipasi Per-RT (FR-RW-02)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peringkat Partisipasi RT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rasio keluarga aktif memilah sampah organik',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Horizontal Bar Charts untuk masing-masing RT
                ...rtList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final rt = entry.value;
                  final isTop = index == 0 || rt.rtName == 'RT 02';
                  final barColor = isTop
                      ? AppColors.primaryContainer
                      : (index == 1 ? AppColors.primary : (index == 2 ? AppColors.tertiaryContainer : AppColors.cardBorder));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rt.rtName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: isTop ? FontWeight.w700 : FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                if (isTop) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Juara 1',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.onPrimaryContainer,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Text('ðŸ†', style: TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '${rt.participationRate.toStringAsFixed(0)}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isTop ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Bar Container
                        Stack(
                          children: [
                            Container(
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: (rt.participationRate / 100.0).clamp(0.05, 1.0),
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 4),
                // Highlight Card Insight
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ðŸ’¡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'RT 02 mencatat pemilahan tertinggi berkat komitmen sosialisasi berkala kader dasawisma lingkungan.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                // Toggle Detail Tabel / Trend FL-Chart
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showDetailedTables = !_showDetailedTables),
                    icon: Icon(
                      _showDetailedTables ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      _showDetailedTables ? 'Sembunyikan Grafik Tren' : 'Lihat Grafik Tren & Tabel Detail',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                if (_showDetailedTables) ...[
                  const Divider(height: 24),
                  Text(
                    'Tren Partisipasi 6 Bulan Terakhir',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < trends.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      trends[idx].monthLabel,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: trends.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.activeKk.toDouble(),
                                color: e.key == trends.length - 1
                                    ? AppColors.primary
                                    : AppColors.primaryLight,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Ringkasan Kondisi Biodigester RW 05 (FR-RW-03)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kondisi Biodigester RW 05',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Instalasi TPS Sentral Komunal',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Normal & Aman',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 3 Indikator Ringkas Non-Teknis
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthIndicator(
                        label: 'Stabilitas pH',
                        value: '7.2',
                        status: 'Ideal',
                        valueColor: AppColors.primary,
                        statusColor: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildHealthIndicator(
                        label: 'Suhu Reaktor',
                        value: '${state.temperatureMetric.currentValue}Â°C',
                        status: 'Optimal',
                        valueColor: AppColors.onSurface,
                        statusColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildHealthIndicator(
                        label: 'Tekanan Gas',
                        value: '${state.pressureMetric.currentValue.toStringAsFixed(2)} kPa',
                        status: 'Kapasitas Pas',
                        valueColor: AppColors.secondary,
                        statusColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Banner Quick Action: Rekap / Ekspor PDF RW
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.surfaceContainerLowest,
                  AppColors.surfaceContainerLow,
                  AppColors.surfaceContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Laporan Rapat Bulanan RW',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Unduh & cetak rekapitulasi data RT 01â€“06',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.onNavigateToLaporan,
                  icon: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required double progress,
    required Color progressColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Mini Progress Bar
          Stack(
            children: [
              Container(
                height: 5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.05, 1.0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator({
    required String label,
    required String value,
    required String status,
    required Color valueColor,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
