import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_state.dart';
import '../../widgets/app_header.dart';
import 'tabs/operator_dashboard_tab.dart';
import 'tabs/operator_setoran_tab.dart';
import 'tabs/operator_digestate_tab.dart';

class OperatorMainScreen extends StatefulWidget {
  const OperatorMainScreen({super.key});

  @override
  State<OperatorMainScreen> createState() => _OperatorMainScreenState();
}

class _OperatorMainScreenState extends State<OperatorMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final tabs = const [
      OperatorDashboardTab(),
      OperatorSetoranTab(),
      OperatorDigestateTab(),
    ];

    return Scaffold(
      appBar: const AppHeader(),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary, // Hijau tema biodigester
          unselectedItemColor: const Color(0xFF6B7280),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard IoT',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.inventory_2_outlined),
                  if (state.pendingSubmissionsCount > 0)
                    Positioned(
                      top: -2,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${state.pendingSubmissionsCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.inventory_2),
              label: 'Setoran',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.water_drop_outlined),
                  if (state.pendingClaimsCount > 0)
                    Positioned(
                      top: -2,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${state.pendingClaimsCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.water_drop),
              label: 'Digestate',
            ),
          ],
        ),
      ),
    );
  }
}
