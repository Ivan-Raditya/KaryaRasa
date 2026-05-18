import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _darkBrown = Color(0xFF772F1A);
  static const _brown = Color(0xFF4A2B20);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFAF6F1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
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
                        // "Profil" pill
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User info row (inside dark section)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
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
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF9E9E9E),
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Name + occupation
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fulan bin Fulan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _gold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Mahasiswa',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Email
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            Text(
                              'fulanoeser@example.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
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
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0xFFF0EDE8), indent: 16, endIndent: 16),
                  _menuItem(Icons.edit_rounded, 'Edit Profil', () {}),
                  _divider(),
                  _menuItem(Icons.bookmark_rounded, 'Penanda', () {
                    Navigator.of(context).pushNamed('/bookmark');
                  }),
                  _divider(),
                  _menuItem(Icons.person_rounded, 'Akun', () {}),
                  _divider(),
                  _menuItem(Icons.settings_rounded, 'Pengaturan', () {}),
                  _divider(),
                  _menuItem(Icons.logout_rounded, 'Keluar', () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Bottom Nav ─────────────────────────────────────────────────
          KaryaRasaBottomNav(
            currentIndex: 3,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/');
              } else if (index == 1) {
                Navigator.of(context).pushNamed('/search');
              } else if (index == 2) {
                Navigator.of(context).pushNamed('/bookmark');
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
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
    return const Divider(height: 1, color: Color(0xFFF0EDE8), indent: 58, endIndent: 20);
  }
}
