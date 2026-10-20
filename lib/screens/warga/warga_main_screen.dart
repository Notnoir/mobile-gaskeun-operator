import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_header.dart';
import 'tabs/warga_home_tab.dart';
import 'tabs/warga_setor_tab.dart';
import 'tabs/warga_tukar_tab.dart';
import 'tabs/warga_edukasi_tab.dart';

class WargaMainScreen extends StatefulWidget {
  const WargaMainScreen({super.key});

  @override
  State<WargaMainScreen> createState() => _WargaMainScreenState();
}

class _WargaMainScreenState extends State<WargaMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      WargaHomeTab(
        onNavigateToSetor: () => setState(() => _currentIndex = 1),
        onNavigateToTukar: () => setState(() => _currentIndex = 2),
      ),
      const WargaSetorTab(),
      const WargaTukarTab(),
      const WargaEdukasiTab(),
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
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'Setor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_outlined),
              activeIcon: Icon(Icons.card_giftcard),
              label: 'Tukar Poin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Edukasi',
            ),
          ],
        ),
      ),
    );
  }
}
