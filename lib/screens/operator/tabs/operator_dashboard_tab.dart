import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/iot_sensor_model.dart';
import '../../../providers/app_state.dart';

class OperatorDashboardTab extends StatelessWidget {
  const OperatorDashboardTab({super.key});

  void _showEditMachineDialog(BuildContext context, AppState state) {
    final nameController = TextEditingController(text: state.machineName);
    final locController = TextEditingController(text: state.machineLocation);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ubah Informasi Mesin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Unit Biodigester'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locController,
              decoration: const InputDecoration(labelText: 'Lokasi Penempatan'),
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
              state.updateMachineLocation(nameController.text.trim(), locController.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final temp = state.temperatureMetric;
    final pressure = state.pressureMetric;
    final mq4Out = state.mq4OutdoorMetric;
    final mq4Dig = state.mq4BiodigesterMetric;
    final mq136 = state.mq136Metric;
    final alerts = state.activeAlerts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Machine Info Card
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
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.machineName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                      onPressed: () => _showEditMachineDialog(context, state),
                      tooltip: 'Ubah Data Mesin',
                    ),
                  ],
                ),
                Text(
                  state.machineLocation,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.sensors, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Status IoT: Online (Polling 30s)', style: TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => state.triggerSensorFluctuation(),
                      icon: const Icon(Icons.refresh, size: 14, color: AppColors.primaryDark),
                      label: const Text('Perbarui Data', style: TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Predictive Alert Banner (if any)
          if (alerts.isNotEmpty) ...[
            ...alerts.map((alert) => _buildAlertBanner(context, alert, state)),
            const SizedBox(height: 16),
          ],

          const Text(
            'Monitoring Sensor Reaktor Real-time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Row 1 — Suhu & Tekanan Gas (existing)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSensorCard(
                  metric: temp,
                  icon: Icons.thermostat,
                  lineColor: const Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  metric: pressure,
                  icon: Icons.speed,
                  lineColor: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Gas Sensor Header
          Row(
            children: const [
              Icon(Icons.gas_meter_outlined, size: 16, color: AppColors.primaryDark),
              SizedBox(width: 6),
              Text(
                'Sensor Gas (MQ-Series)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2 — MQ-4 #1 (Luar) & MQ-4 #2 (Digester)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSensorCard(
                  metric: mq4Out,
                  icon: Icons.outdoor_grill_outlined,
                  lineColor: const Color(0xFFEF4444),
                  placementLabel: mq4Out.sensorType.placementInfo,
                  sensorCode: mq4Out.sensorType.sensorCode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  metric: mq4Dig,
                  icon: Icons.biotech_outlined,
                  lineColor: const Color(0xFF8B5CF6),
                  placementLabel: mq4Dig.sensorType.placementInfo,
                  sensorCode: mq4Dig.sensorType.sensorCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3 — MQ-136 (full width)
          _buildSensorCard(
            metric: mq136,
            icon: Icons.filter_alt_outlined,
            lineColor: const Color(0xFF10B981),
            placementLabel: mq136.sensorType.placementInfo,
            sensorCode: mq136.sensorType.sensorCode,
          ),
          const SizedBox(height: 20),

          // Quick Operational Summary
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
                const Text(
                  'Panduan Operator Harian',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildGuideRow(
                  icon: Icons.check_circle_outline,
                  color: AppColors.primary,
                  title: 'Batas Suhu Optimal: 35°C – 39°C',
                  desc: 'Suhu mesofilik terbaik untuk aktivitas mikroorganisme pengurai.',
                ),
                const SizedBox(height: 8),
                _buildGuideRow(
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  title: 'Batas Tekanan Aman: < 1.100 hPa',
                  desc: 'Buka katup distribusi ke kompor warga jika tekanan mendekati 1.150 hPa.',
                ),
                const SizedBox(height: 8),
                _buildGuideRow(
                  icon: Icons.gas_meter_outlined,
                  color: AppColors.danger,
                  title: 'MQ-4 Luar: Batas Peringatan > 40 ppm',
                  desc: 'Jika sensor luar > 40 ppm, periksa kemungkinan kebocoran saluran gas.',
                ),
                const SizedBox(height: 8),
                _buildGuideRow(
                  icon: Icons.biotech_outlined,
                  color: const Color(0xFF8B5CF6),
                  title: 'MQ-4 Digester: Normal 3.000 – 6.500 ppm',
                  desc: 'Konsentrasi metana tinggi di dalam digester adalah tanda fermentasi berjalan baik.',
                ),
                const SizedBox(height: 8),
                _buildGuideRow(
                  icon: Icons.filter_alt_outlined,
                  color: AppColors.primary,
                  title: 'MQ-136 H₂S Pasca Filter: < 10 ppm',
                  desc: 'Nilai H₂S pasca filter harus rendah. Ganti media filter jika > 10 ppm.',
                ),
                const SizedBox(height: 8),
                _buildGuideRow(
                  icon: Icons.info_outline,
                  color: AppColors.info,
                  title: 'Verifikasi Fisik Setoran',
                  desc: 'Pastikan timbangan sesuai tiket dan tidak ada sampah anorganik.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context, PredictiveAlert alert, AppState state) {
    Color bg = AppColors.warningLight;
    Color border = AppColors.warning;
    Color textCol = const Color(0xFF92400E);

    if (alert.severity == SensorSeverity.critical) {
      bg = AppColors.dangerLight;
      border = AppColors.danger;
      textCol = const Color(0xFF991B1B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: border, size: 18),
              const SizedBox(width: 8),
              Text(
                'AI Alert: ${alert.title}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textCol),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            alert.message,
            style: TextStyle(fontSize: 12, color: textCol.withOpacity(0.9), height: 1.3),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => state.dismissAlert(alert.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: border,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 32),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tandai Selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required SensorMetric metric,
    required IconData icon,
    required Color lineColor,
    String? placementLabel,
    String? sensorCode,
  }) {
    Color statusColor;
    Color statusBg;
    if (metric.severity == SensorSeverity.normal) {
      statusColor = AppColors.primary;
      statusBg = AppColors.primaryLight;
    } else if (metric.severity == SensorSeverity.warning) {
      statusColor = AppColors.warning;
      statusBg = AppColors.warningLight;
    } else {
      statusColor = AppColors.danger;
      statusBg = AppColors.dangerLight;
    }

    final progress = (metric.currentValue / metric.maxValue).clamp(0.0, 1.0);

    // Format value: show 1 decimal for small float values, 0 decimal for large integers
    final String valueText = metric.unit == 'ppm' && metric.currentValue >= 100
        ? metric.currentValue.toStringAsFixed(0)
        : metric.currentValue.toStringAsFixed(1);

    // Sparkline spots
    final spots = metric.history7Points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

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
              Row(
                children: [
                  Icon(icon, color: lineColor, size: 20),
                  if (sensorCode != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: lineColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        sensorCode,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: lineColor),
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  metric.severity.label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            metric.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          if (placementLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              placementLabel,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                valueText,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                metric.unit,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mini Gauge Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),

          // Sparkline Chart (Histori 7 Terakhir)
          const Text('Histori 7 Titik Terakhir:', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          SizedBox(
            height: 48,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
