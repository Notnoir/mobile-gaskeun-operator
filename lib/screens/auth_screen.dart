import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/user_model.dart';
import '../providers/app_state.dart';
import '../services/auth_service.dart';
import '../services/staff_registry_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const AuthScreen({super.key, this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authResult = await AuthService().signInWithGoogle();

      if (authResult == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;

      // 1. Dapatkan daftar seluruh role yang diizinkan untuk akun Google ini
      final authorizedRoles = await StaffRegistryService().getAuthorizedRoles(
        email: authResult.email,
        uid: authResult.firebaseUser?.uid,
      );

      if (authorizedRoles.isEmpty) {
        await AuthService().signOut();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Akses Ditolak: Akun (${authResult.email}) tidak terdaftar dalam daftar izin Petugas (Operator / Pengawas RW).\n\nSilakan gunakan aplikasi GasKeun Warga untuk akun warga, atau hubungi administrator RW.';
        });
        return;
      }

      // 2. Jika akun di-whitelist untuk KEDUA role, munculkan dialog pilihan portal masuk
      UserRole targetRole;
      if (authorizedRoles.length > 1) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final chosenRole = await _showRolePickerDialog(
          context,
          authResult.email,
          authorizedRoles,
        );

        if (chosenRole == null) {
          // Pengguna membatalkan pemilihan portal
          await AuthService().signOut();
          return;
        }
        targetRole = chosenRole;
        if (!mounted) return;
        setState(() => _isLoading = true);
      } else {
        targetRole = authorizedRoles.first;
      }

      final appState = context.read<AppState>();
      await appState.loginWithGoogleAccount(
        email: authResult.email,
        displayName: authResult.displayName,
        uid: authResult.firebaseUser?.uid,
        targetRole: targetRole,
      );

      setState(() => _isLoading = false);

      final roleName = appState.currentRole.displayName;
      _showSuccessNotification(
        'Berhasil masuk sebagai $roleName: ${authResult.displayName}',
      );
      widget.onLoginSuccess?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Tidak dapat menghubungkan Akun Google: $e\n(Pastikan SHA-1 terdaftar di Firebase Console).';
      });
    }
  }

  Future<UserRole?> _showRolePickerDialog(
    BuildContext context,
    String email,
    Set<UserRole> roles,
  ) {
    return showModalBottomSheet<UserRole>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.manage_accounts_rounded, color: AppColors.info, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Portal Petugas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Akun Anda terdaftar dengan izin untuk kedua portal. Silakan pilih portal yang ingin dibuka:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),
                _buildRolePickerCard(
                  context: ctx,
                  role: UserRole.operator,
                  title: 'Portal Operator Lapangan',
                  subtitle: 'Monitoring telemetri sensor IoT & verifikasi setoran sampah',
                  icon: Icons.precision_manufacturing_rounded,
                  color: AppColors.info,
                ),
                const SizedBox(height: 10),
                _buildRolePickerCard(
                  context: ctx,
                  role: UserRole.pengawas,
                  title: 'Portal Pengawas RW',
                  subtitle: 'Statistik partisipasi warga KK & ekspor laporan PDF',
                  icon: Icons.assessment_rounded,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx, null),
                    child: const Text('Batal Masuk', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRolePickerCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, role),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Brand Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.info.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.precision_manufacturing_rounded, color: AppColors.info, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GasKeun Ops & RW',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Portal Petugas Operator & Pengawas RW',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Masuk Portal Petugas',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Akses terbatas khusus untuk Petugas Operator Lapangan dan Pengawas RW yang telah terdaftar dalam sistem resmi.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Error banner if any
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tombol Google Sign In Petugas
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleAuth,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.info),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                              height: 22,
                              width: 22,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Masuk dengan Akun Google Petugas',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Security & Whitelist Information Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.infoLight.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.shield_outlined, color: AppColors.info, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Sistem Akses Terproteksi (Whitelist)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hanya akun Google yang terdaftar dalam daftar izin resmi petugas (Operator Biodigester atau Pengawas RW) yang dapat mengakses aplikasi ini. Akun warga biasa wajib menggunakan aplikasi GasKeun Warga.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Feature Preview Cards
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.precision_manufacturing_rounded, color: AppColors.info, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Portal Operator: Monitoring Sensor IoT & Validasi Setoran',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.assessment_rounded, color: Colors.deepPurple, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Portal Pengawas RW: Statistik Partisipasi & Ekspor Laporan PDF',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
