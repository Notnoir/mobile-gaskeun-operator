import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class PdfReportService {
  static const PdfColor emerald50 = PdfColor.fromInt(0xFFECFDF5);
  static const PdfColor emerald600 = PdfColor.fromInt(0xFF059669);
  static const PdfColor emerald700 = PdfColor.fromInt(0xFF047857);
  static const PdfColor emerald800 = PdfColor.fromInt(0xFF065F46);
  static const PdfColor emerald900 = PdfColor.fromInt(0xFF064E3B);

  static Future<Uint8List> generateMonthlyReport({
    required AppState appState,
    required String month,
    required int year,
  }) async {
    final pdf = pw.Document();
    final numberFmt = NumberFormat('#,##0.#', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // Header / Kop Dokumen
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: emerald700, width: 2),
                ),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GASKEUN RW 05',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: emerald800,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Sistem Pengelolaan Sampah Organik & Biodigester Mandiri',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Kelurahan Sukajaya, Kecamatan Mandiri — Wilayah RW 05',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: emerald50,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: emerald600),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'LAPORAN BULANAN',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: emerald900,
                          ),
                        ),
                        pw.Text(
                          '$month $year',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: emerald800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Ringkasan Eksekutif
            pw.Text(
              '1. Ringkasan Eksekutif Capaian Pengolahan Sampah',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Row(
              children: [
                _buildPdfMetricCard(
                  title: 'Total Sampah Organik',
                  value: '${numberFmt.format(appState.totalWasteKgRW)} kg',
                  sub: '+14% vs bulan lalu',
                  color: emerald700,
                ),
                pw.SizedBox(width: 10),
                _buildPdfMetricCard(
                  title: 'Produksi Biogas',
                  value: '${numberFmt.format(appState.totalBiogasM3RW)} m³',
                  sub: 'Konversi kompor warga',
                  color: PdfColors.teal700,
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              children: [
                _buildPdfMetricCard(
                  title: 'Produksi Digestate',
                  value: '${numberFmt.format(appState.totalDigestateLRW)} Liter',
                  sub: 'Pupuk cair organik',
                  color: PdfColors.green700,
                ),
                pw.SizedBox(width: 10),
                _buildPdfMetricCard(
                  title: 'Partisipasi Warga',
                  value: '${appState.activeKkCount} / ${appState.totalKkRW} KK',
                  sub: 'Tingkat adopsi 70%',
                  color: PdfColors.blue700,
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Rincian per RT
            pw.Text(
              '2. Rincian Partisipasi Warga per Rukun Tetangga (RT)',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    _tableCell('Unit RT', isHeader: true),
                    _tableCell('KK Berpartisipasi', isHeader: true),
                    _tableCell('Tingkat Partisipasi', isHeader: true),
                    _tableCell('Total Sampah (kg)', isHeader: true),
                    _tableCell('Status Target', isHeader: true),
                  ],
                ),
                // Data Rows
                ...appState.rtParticipationList.map((rt) {
                  return pw.TableRow(
                    children: [
                      _tableCell(rt.rtName),
                      _tableCell('${rt.activeKk} dari ${rt.totalKk} KK'),
                      _tableCell('${rt.participationRate.toStringAsFixed(0)}%'),
                      _tableCell('${rt.totalWasteKg} kg'),
                      _tableCell(
                        rt.isTargetReached ? 'Tercapai (>=70%)' : 'Perlu Peningkatan',
                        color: rt.isTargetReached ? emerald700 : PdfColors.amber800,
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),

            // Informasi Fasilitas
            pw.Text(
              '3. Status Operasional Mesin Biodigester',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• Unit Biodigester: ${appState.machineName}'),
                  pw.Text('• Lokasi: ${appState.machineLocation}'),
                  pw.Text('• Kondisi Sensor: Suhu Rata-rata ${appState.temperatureMetric.currentValue}°C (Normal)'),
                  pw.Text('• Tekanan Rata-rata: ${appState.pressureMetric.currentValue} hPa'),
                  pw.Text('• Total Insiden Mesin: 0 insiden bulan ini'),
                ],
              ),
            ),
            pw.SizedBox(height: 36),

            // Tanda Tangan
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Mengetahui,', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Ketua RW 05', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 40),
                    pw.Text('( Bu Sari Handayani )', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('ID: RW-05-SRI', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Diverifikasi oleh,', style: const pw.TextStyle(fontSize: 10)),
                    pw.Text('Petugas Operator Lapangan', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 40),
                    pw.Text('( Pak Anton )', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('ID: OPR-BD05-ANT', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfMetricCard({
    required String title,
    required String value,
    required String sub,
    required PdfColor color,
  }) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              sub,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.grey800 : PdfColors.grey900),
        ),
      ),
    );
  }

  static Future<void> printOrShareReport({
    required AppState appState,
    required String month,
    required int year,
  }) async {
    final pdfBytes = await generateMonthlyReport(
      appState: appState,
      month: month,
      year: year,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Laporan_GasKeun_${month}_$year.pdf',
    );
  }
}
