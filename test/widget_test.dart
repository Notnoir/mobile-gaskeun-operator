import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gaskeun_operator_rw/main.dart';
import 'package:gaskeun_operator_rw/providers/app_state.dart';
import 'package:gaskeun_operator_rw/models/user_model.dart';
import 'package:gaskeun_operator_rw/models/waste_submission_model.dart';
import 'package:gaskeun_operator_rw/services/staff_registry_service.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('GasKeunOperatorRwApp renders AuthScreen with Google Sign-In and whitelist info',
      (WidgetTester tester) async {
    final state = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunOperatorRwApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AuthScreen elements
    expect(find.text('GasKeun Ops & RW'), findsOneWidget);
    expect(find.text('Masuk Portal Petugas'), findsOneWidget);
    expect(find.text('Masuk dengan Akun Google Petugas'), findsOneWidget);
    expect(find.text('Sistem Akses Terproteksi (Whitelist)'), findsOneWidget);

    // Verify manual email & password login form is removed
    expect(find.text('Pilih Akun Petugas:'), findsNothing);
    expect(find.text('Email Petugas'), findsNothing);
    expect(find.text('Kata Sandi (Password)'), findsNothing);
    expect(find.text('Masuk ke Portal Petugas'), findsNothing);

    state.dispose();
  });

  testWidgets('Logging in as Operator navigates to OperatorMainScreen',
      (WidgetTester tester) async {
    final state = AppState();
    state.login('operator@gaskeun.id', 'password123');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunOperatorRwApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Operator header & tabs
    expect(find.text('GasKeun Ops & RW'), findsWidgets);
    expect(find.text('Dashboard IoT'), findsOneWidget);
    expect(find.text('Setoran'), findsOneWidget);
    expect(find.text('Operator'), findsOneWidget);
    expect(find.text('Mode RW'), findsNothing);
    expect(find.byTooltip('Keluar Akun'), findsOneWidget);

    state.dispose();
  });

  testWidgets('Logging in as Pengawas navigates to PengawasMainScreen',
      (WidgetTester tester) async {
    final state = AppState();
    state.login('pengawas@gaskeun.id', 'password123');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunOperatorRwApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify Pengawas header & tabs
    expect(find.text('GasKeun Ops & RW'), findsWidgets);
    expect(find.text('Dashboard RW'), findsOneWidget);
    expect(find.text('Laporan PDF'), findsOneWidget);
    expect(find.text('Pengawas RW'), findsOneWidget);
    expect(find.text('Mode Operator'), findsNothing);
    expect(find.byTooltip('Keluar Akun'), findsOneWidget);

    state.dispose();
  });

  testWidgets('Logging out returns to AuthScreen',
      (WidgetTester tester) async {
    final state = AppState();
    state.login('operator@gaskeun.id', 'password123');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const GasKeunOperatorRwApp(),
      ),
    );
    await tester.pumpAndSettle();

    state.logout();
    await tester.pumpAndSettle();

    expect(find.text('GasKeun Ops & RW'), findsOneWidget);
    expect(find.text('Masuk Portal Petugas'), findsOneWidget);
    expect(find.text('Masuk dengan Akun Google Petugas'), findsOneWidget);

    state.dispose();
  });

  test('Unauthorized citizen account is rejected from staff portal (Approach 2)', () {
    final state = AppState();
    final isAllowed = state.login('warga.biasa@gmail.com', 'password123');
    expect(isAllowed, isFalse);
    expect(state.isLoggedIn, isFalse);
    state.dispose();
  });

  test('Account whitelisted in both roles can log in as either Operator or Pengawas', () {
    final staff = StaffRegistryService();
    staff.registerStaffEmail('multirole@gaskeun.id', UserRole.operator);
    staff.registerStaffEmail('multirole@gaskeun.id', UserRole.pengawas);

    final state = AppState();
    // Test login as Operator
    final opSuccess = state.login('multirole@gaskeun.id', 'password123', targetRole: UserRole.operator);
    expect(opSuccess, isTrue);
    expect(state.currentRole, UserRole.operator);

    // Test login as Pengawas
    final rwSuccess = state.login('multirole@gaskeun.id', 'password123', targetRole: UserRole.pengawas);
    expect(rwSuccess, isTrue);
    expect(state.currentRole, UserRole.pengawas);

    state.dispose();
  });

  test('AppState IoT alert dismiss and verification flow', () {
    final state = AppState();
    expect(state.currentRole, UserRole.operator);

    // Verify unverified submission exists
    final sub = state.submissions.firstWhere((s) => s.status == SubmissionStatus.menunggu);
    state.verifySubmission(sub.id, true);

    final updated = state.submissions.firstWhere((s) => s.id == sub.id);
    expect(updated.status, SubmissionStatus.diterima);

    state.dispose();
  });
}
