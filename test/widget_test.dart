import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:gaskeun_operator_rw/main.dart';
import 'package:gaskeun_operator_rw/providers/app_state.dart';
import 'package:gaskeun_operator_rw/models/user_model.dart';
import 'package:gaskeun_operator_rw/models/waste_submission_model.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('GasKeunOperatorRwApp renders AuthScreen with Operator and Pengawas options',
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
    expect(find.text('Pilih Akun Petugas:'), findsOneWidget);
    expect(find.text('Operator'), findsOneWidget);
    expect(find.text('Pengawas RW'), findsOneWidget);
    expect(find.text('Masuk dengan Akun Google Petugas'), findsOneWidget);
    expect(find.text('Email Petugas'), findsOneWidget);
    expect(find.text('Kata Sandi (Password)'), findsOneWidget);
    expect(find.text('Masuk ke Portal Petugas'), findsOneWidget);

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
    expect(find.text('Mode RW'), findsOneWidget);
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
    expect(find.text('Mode Operator'), findsOneWidget);
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
    expect(find.text('Pilih Akun Petugas:'), findsOneWidget);

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
