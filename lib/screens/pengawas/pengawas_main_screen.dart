import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_header.dart';
import 'tabs/pengawas_dashboard_tab.dart';
import 'tabs/pengawas_laporan_tab.dart';

class PengawasMainScreen extends StatefulWidget {
  const PengawasMainScreen({super.key});

  @override
  State<PengawasMainScreen> createState() => _PengawasMainScreenState();
}

class _PengawasMainScreenState extends State<PengawasMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = const [
      PengawasDashboardTab(),
      PengawasLaporanTab(),
    ];

    return Scaffold(
      appBar: const AppHeader(),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Dashboard RW',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Laporan PDF',
            ),
          ],
        ),
      ),
    );
  }
}
