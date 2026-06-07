import 'package:flutter/material.dart';

class KaryaRasaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const KaryaRasaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _activeColor = Color(0xFFC6572F);
  static const _inactiveColor = Color(0xFF9E9E9E);
  static const _gold = Color(0xFFD9AE23);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Beranda', active: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.explore_rounded, label: 'Jelajah', active: currentIndex == 1, onTap: () => onTap(1)),
              // Tombol Bagikan di tengah
              GestureDetector(
                onTap: () => onTap(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Kreasi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _gold,
                      ),
                    ),
                  ],
                ),
              ),
              _NavItem(icon: Icons.soup_kitchen_outlined, label: 'Racik', active: currentIndex == 3, onTap: () => onTap(3)),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', active: currentIndex == 4, activeIcon: Icons.person_rounded, onTap: () => onTap(4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  static const _activeColor = Color(0xFFC6572F);
  static const _inactiveColor = Color(0xFF9E9E9E);

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? _activeColor : _inactiveColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? (activeIcon ?? icon) : icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}