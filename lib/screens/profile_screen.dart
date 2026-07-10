import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/session_manager.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  static const _darkBrown = Color(0xFF772F1A);
  static const _brown = Color(0xFF4A2B20);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFAF6F1);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF1E1E1E) : _creamBg;
  Color get cardColor => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get textColor => isDark ? Colors.white : Colors.black87;
  Color get secondaryTextColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;

  @override
  Widget build(BuildContext context) {
    final session = SessionManager.instance;
    final pengguna = session.penggunaLogin;
    final nama = pengguna?.nama ?? 'Pengguna';
    final email = pengguna?.email ?? '';
    final role = pengguna?.role ?? 'user';
    final fotoProfile = pengguna?.fotoProfile;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Dark Brown Header Section ──────────────────────────────────
          Container(
            color: _darkBrown,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top bar with back button + title pill
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: _gold, width: 1.5),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Text(
                            'Profil',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'PlayfairDisplay',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User info row
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0C8BE),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                image: fotoProfile != null && fotoProfile.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(fotoProfile),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (fotoProfile == null || fotoProfile.isEmpty)
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFF9E9E9E),
                                      size: 40,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            // Name + role
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nama,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: _gold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    role,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: secondaryTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(width: 4),
                              Icon(Icons.email_outlined, size: 14, color: Colors.grey[500]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Menu Items ─────────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Divider(height: 1, color: isDark ? const Color(0xFF333333) : const Color(0xFFF0EDE8), indent: 16, endIndent: 16),
                  _menuItem(Icons.edit_rounded, 'Edit Profil', () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    )).then((_) => setState(() {}));
                  }),
                  _divider(),
                  _menuItem(Icons.bookmark_rounded, 'Penanda', () {
                    Navigator.of(context).pushNamed('/bookmark');
                  }),
                  _divider(),
                  _menuItem(Icons.person_rounded, 'Akun', () {}),
                  _divider(),
                  _menuItem(Icons.settings_rounded, 'Pengaturan', () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ));
                  }),
                  _divider(),
                  _menuItem(Icons.logout_rounded, 'Keluar', () {
                    SessionManager.instance.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Bottom Nav ─────────────────────────────────────────────────
          KaryaRasaBottomNav(
            currentIndex: 4,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/');
              } else if (index == 1) {
                Navigator.of(context).pushNamed('/search');
              } else if (index == 2) {
                Navigator.of(context).pushNamed('/kreasi');
              } else if (index == 3) {
                Navigator.of(context).pushReplacementNamed('/racik');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF772F1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: isDark ? const Color(0xFF333333) : const Color(0xFFF0EDE8), indent: 58, endIndent: 20);
  }
}