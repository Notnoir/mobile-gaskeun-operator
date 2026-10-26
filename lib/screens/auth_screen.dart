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
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final topHeight = constraints.maxHeight * 0.52;
          const overlap = 28.0;

          return Stack(
            children: [
              // 1. Top Illustration (bg-login-reg.png)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/bg-login-reg.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF0F3E36),
                          child: const Center(
                            child: Icon(Icons.precision_manufacturing_rounded, size: 64, color: Colors.white54),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay at bottom edge to smooth intersection with sheet
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Scrollable Content Layer (Card extends all the way down)
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        // Space revealing top illustration
                        SizedBox(height: topHeight - overlap),

                        // Bottom Sheet Card: Fills all the way to the bottom
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - (topHeight - overlap),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1F065F46),
                                blurRadius: 35,
                                offset: Offset(0, -12),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(24, 10, 24, 16 + bottomInset),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // iOS Grabber Indicator
                                  Center(
                                    child: Container(
                                      width: 38,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),

                                  // Header Title & Subtitle
                                  const Text(
                                    'Selamat Datang',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  const Text(
                                    'Masuk Portal Petugas',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Error Banner
                                  if (_errorMessage != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFCA5A5)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                color: Color(0xFFDC2626),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Google Sign-In Button
                                  _buildGoogleButton(),
                                  const SizedBox(height: 14),

                                  // Whitelist Security Card
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.infoLight.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.shield_outlined, color: AppColors.info, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Sistem Akses Terproteksi (Whitelist)',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.info,
                                                ),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                'Khusus Petugas Operator Lapangan & Pengawas RW yang telah terdaftar resmi.',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Portal Features Overview
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: const [
                                              Icon(Icons.precision_manufacturing_rounded, size: 16, color: AppColors.info),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Operator IoT',
                                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(width: 1, height: 16, color: const Color(0xFFE2E8F0)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Row(
                                            children: const [
                                              Icon(Icons.assessment_rounded, size: 16, color: Colors.deepPurple),
                                              SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Pengawas RW',
                                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Subfooter pinned at bottom of card
                              Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Column(
                                  children: const [
                                    Text(
                                      'GasKeun Ops & RW',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.0,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Komunitas • Lingkungan • Masa Depan',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== GOOGLE BUTTON ====================
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleAuth,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.info),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGoogleIcon(),
                  const SizedBox(width: 10),
                  const Text(
                    'Masuk dengan Akun Google Petugas',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Image.network(
      'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
      height: 20,
      width: 20,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF4285F4),
          ),
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
