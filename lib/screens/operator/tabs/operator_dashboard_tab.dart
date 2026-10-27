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
                      children: [
                        Icon(
                          Icons.sensors,
                          size: 16,
                          color: state.isDeviceOnline ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.isDeviceOnline
                              ? 'IoT Live: ${state.deviceId}'
                              : 'IoT Terhubung: ${state.deviceId}',
                          style: TextStyle(
                            fontSize: 11,
                            color: state.isDeviceOnline ? AppColors.success : AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (state.latestReading != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SEQ #${state.latestReading!.sequence}',
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.info),
                            ),
                          ),
                        ],
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                SizedBox(width: 10),
                                Text('Menghubungi Firebase...'),
                              ],
                            ),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        final success = await state.refreshFirebaseIotData();
                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Data sensor terbaru berhasil ditarik dari Firebase! (${state.temperatureMetric.currentValue}°C, ${state.pressureMetric.currentValue} kPa)',
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          final err = state.iotLastError ?? 'Periksa koneksi internet / Rules Firebase';
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Firebase notice: $err'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
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
                if (!state.isUsingRealFirebase && state.iotLastError != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 15, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Status Koneksi: ${state.iotLastError}. Pastikan Rules di Firebase Console mengizinkan ".read": true.',
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // AI Predictive Alert Banner (if any)
          if (alerts.isNotEmpty) ...[
            ...alerts.map((alert) => _buildAlertBanner(context, alert)),
            const SizedBox(height: 16),
          ],

          const Text(
            'Monitoring Sensor Reaktor Real-time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Row 1: Suhu & Tekanan Gas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSensorCard(
                  metric: temp,
                  icon: Icons.thermostat_rounded,
                  lineColor: const Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  metric: pressure,
                  icon: Icons.speed_rounded,
                  lineColor: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Gas Sensor Header
          Row(
            children: const [
              Icon(Icons.gas_meter_outlined, size: 16, color: AppColors.primaryDark),
              SizedBox(width: 6),
              Text(
                'Deteksi Kebocoran Gas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Gas Metana & Hidrogen Sulfida (Deteksi Kebocoran Gas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSensorCard(
                  metric: mq4Out,
                  icon: Icons.gas_meter_outlined,
                  lineColor: const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  metric: mq136,
                  icon: Icons.warning_amber_rounded,
                  lineColor: const Color(0xFF10B981),
                ),
              ),
            ],
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
                  title: 'Batas Tekanan Aman: < 8.0 kPa (Maksimal 10.0 kPa)',
                  desc: 'Buka katup distribusi ke kompor warga jika tekanan mendekati 9.0 – 10.0 kPa.',
                ),
                const SizedBox(height: 8),
                _buildGuideRow(
                  icon: Icons.gas_meter_outlined,
                  color: AppColors.danger,
                  title: 'Batas Peringatan Gas: > 40 ppm (Metana & H₂S)',
                  desc: 'Jika sensor metana atau hidrogen sulfida meningkat, periksa segera kemungkinan kebocoran pipa gas.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(BuildContext context, PredictiveAlert alert) {
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
    // Menghitung progress secara dinamis
    final double rawRatio = metric.maxValue > 0 ? (metric.currentValue / metric.maxValue) : 0.0;
    final double progress = rawRatio.clamp(0.0, 1.0);

    // Ketentuan warna & status:
    // Jika nilai mencapai atau melampaui batas maksimal (misal tekanan >= 10 kPa), bar langsung full & berwarna merah.
    // Berlaku untuk semua sensor.
    final bool isMaxOrCritical = metric.currentValue >= metric.maxValue ||
        metric.severity == SensorSeverity.critical ||
        progress >= 1.0;
    final bool isWarning = !isMaxOrCritical &&
        (metric.severity == SensorSeverity.warning || progress >= 0.75);

    final Color barColor = isMaxOrCritical
        ? AppColors.danger
        : (isWarning ? AppColors.warning : AppColors.primary);

    final Color statusColor = barColor;
    final Color statusBg = isMaxOrCritical
        ? AppColors.dangerLight
        : (isWarning ? AppColors.warningLight : AppColors.primaryLight);

    final String statusLabel = isMaxOrCritical
        ? (metric.currentValue >= metric.maxValue ? 'Bahaya' : 'Kritis')
        : (isWarning ? 'Peringatan' : 'Normal');

    // Format nilai
    final String valueText = metric.unit == 'kPa'
        ? metric.currentValue.toStringAsFixed(2)
        : (metric.unit == 'ppm' && metric.currentValue >= 100
            ? metric.currentValue.toStringAsFixed(0)
            : metric.currentValue.toStringAsFixed(1));

    // Sparkline spots
    final spots = metric.history7Points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaxOrCritical ? AppColors.danger.withOpacity(0.5) : AppColors.cardBorder,
          width: isMaxOrCritical ? 1.5 : 1.0,
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
                  statusLabel,
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
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isMaxOrCritical ? AppColors.danger : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                metric.unit,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Label Skala & Persentase Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skala: 0 – ${metric.maxValue.toStringAsFixed(metric.maxValue < 20 ? 1 : 0)} ${metric.unit}',
                style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Dynamic Gauge Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5EEFF),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 12),

          // Sparkline Chart (Histori 7 Titik Terakhir)
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
