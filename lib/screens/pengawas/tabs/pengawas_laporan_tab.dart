import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/report_model.dart';
import '../../../providers/app_state.dart';
import '../../../services/pdf_report_service.dart';

class PengawasLaporanTab extends StatefulWidget {
  const PengawasLaporanTab({super.key});

  @override
  State<PengawasLaporanTab> createState() => _PengawasLaporanTabState();
}

class _PengawasLaporanTabState extends State<PengawasLaporanTab> {
  String _selectedMonth = 'September';
  int _selectedYear = 2026;
  bool _isGenerating = false;

  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final List<int> _years = [2025, 2026, 2027];

  Future<void> _generatePdfReport(AppState state) async {
    setState(() => _isGenerating = true);

    try {
      await PdfReportService.printOrShareReport(
        appState: state,
        month: _selectedMonth,
        year: _selectedYear,
      );

      final fileName = 'Laporan_GasKeun_RW05_${_selectedMonth}_$_selectedYear.pdf';
      final newReport = GeneratedReport(
        id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Laporan Ekosistem Biodigester RW 05',
        period: '$_selectedMonth $_selectedYear',
        fileName: fileName,
        fileSize: '425 KB',
        generatedAt: DateTime.now(),
      );

      state.addGeneratedReport(newReport);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan PDF $fileName berhasil dibuat & siap dibagikan!'),
            backgroundColor: AppColors.primaryDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final reports = state.reports;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Generator Laporan
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.picture_as_pdf, color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Ekspor Laporan Bulanan RW', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Format PDF siap cetak / kirim ke Kelurahan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Pilih Periode Laporan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Bulan',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMonth = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        value: _selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Tahun',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedYear = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isGenerating ? null : () => _generatePdfReport(state),
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.file_download_outlined, size: 20),
                  label: Text(_isGenerating ? 'Membuat Dokumen PDF...' : 'Ekspor & Cetak PDF Laporan'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Riwayat Laporan Terbuat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Arsip Laporan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${reports.length} File Tersimpan', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),

          if (reports.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Center(
                child: Text('Belum ada arsip laporan yang digenerate.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            )
          else
            ...reports.map((rep) => _buildReportItem(rep, state)),
        ],
      ),
    );
  }

  Widget _buildReportItem(GeneratedReport report, AppState state) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.period, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(report.fileName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${report.fileSize} • Dibuat ${Formatters.date(report.generatedAt)}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.primaryDark),
            tooltip: 'Cetak / Buka PDF',
            onPressed: () {
              final parts = report.period.split(' ');
              final month = parts.isNotEmpty ? parts[0] : 'September';
              final year = parts.length > 1 ? int.tryParse(parts[1]) ?? 2026 : 2026;
              PdfReportService.printOrShareReport(appState: state, month: month, year: year);
            },
          ),
        ],
      ),
    );
  }
}
