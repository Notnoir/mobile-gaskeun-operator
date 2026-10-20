import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/app_state.dart';

class PengawasDashboardTab extends StatefulWidget {
  const PengawasDashboardTab({super.key});

  @override
  State<PengawasDashboardTab> createState() => _PengawasDashboardTabState();
}

class _PengawasDashboardTabState extends State<PengawasDashboardTab> {
  String _timeRange = 'Bulan Ini'; // 'Bulan Ini', '3 Bulan', '6 Bulan'

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rtList = state.rtParticipationList;
    final trends = state.monthlyParticipationTrends;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Period Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Kinerja RW 05',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _timeRange,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    items: ['Bulan Ini', '3 Bulan Terakhir', '6 Bulan Terakhir']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _timeRange = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Metric Cards (Grid 2 Kolom per PRD)
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Sampah',
                  value: Formatters.weight(state.totalWasteKgRW),
                  subText: '+14% vs bulan lalu',
                  isPositive: true,
                  icon: Icons.delete_outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'Biogas Dihasilkan',
                  value: '${Formatters.number(state.totalBiogasM3RW)} m³',
                  subText: 'Setara 24 tabung gas',
                  isPositive: true,
                  icon: Icons.local_fire_department_outlined,
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Produksi Digestate',
                  value: '${Formatters.number(state.totalDigestateLRW)} L',
                  subText: '36 botol dibagikan',
                  isPositive: true,
                  icon: Icons.water_drop_outlined,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKpiCard(
                  title: 'KK Berpartisipasi',
                  value: '${state.activeKkCount} / ${state.totalKkRW} KK',
                  subText: '70% Target tercapai',
                  isPositive: true,
                  icon: Icons.groups_outlined,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart: Tren Partisipasi Warga 6 Bulan Terakhir
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Tren Partisipasi Warga (KK Aktif)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '6 Bulan Terakhir',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 170,
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
                              final index = val.toInt();
                              if (index >= 0 && index < trends.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    trends[index].monthLabel,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (val, meta) {
                              if (val % 25 == 0) {
                                return Text('${val.toInt()}', style: const TextStyle(fontSize: 9, color: AppColors.textMuted));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (val) => FlLine(color: AppColors.cardBorder, strokeWidth: 0.8),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: trends.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.activeKk.toDouble(),
                              color: e.key == trends.length - 1 ? AppColors.primary : const Color(0xFF6EE7B7),
                              width: 18,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tabel Partisipasi per RT
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Tabel Partisipasi per RT',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Target min. 70% KK',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 8,
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Wilayah RT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('KK Aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Total Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Partisipasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                    rows: rtList.map((rt) {
                      return DataRow(
                        cells: [
                          DataCell(Text(rt.rtName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataCell(Text('${rt.activeKk}/${rt.totalKk}', style: const TextStyle(fontSize: 12))),
                          DataCell(Text('${rt.totalWasteKg} kg', style: const TextStyle(fontSize: 12))),
                          DataCell(Text('${rt.participationRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: rt.isTargetReached ? AppColors.primary : AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  rt.isTargetReached ? 'Optimal' : 'Rendah',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: rt.isTargetReached ? AppColors.primaryDark : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subText,
    required bool isPositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: isPositive ? AppColors.primary : AppColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isPositive ? AppColors.primaryDark : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
