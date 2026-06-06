import '../utils/supabase_config.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/resep_data.dart';
import '../utils/session_manager.dart';
import '../database/database.dart';
import 'package:google_fonts/google_fonts.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _start();
  }

 Future<void> _start() async {
  // Tunggu resep selesai load
  await loadResepFromDatabase().catchError((e) => debugPrint('loadResep: $e'));

  // Seed embedding jalan di background
  _seedEmbeddingJikaPerlu();

  await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Cek apakah user sudah login via Supabase session
    final supabaseUser = Supabase.instance.client.auth.currentUser;
    if (supabaseUser != null && !SessionManager.instance.sudahLogin) {
      try {
        final db = Database();
        final pengguna = await db.getPenggunaByEmail(supabaseUser.email ?? '');
        if (pengguna != null) {
          SessionManager.instance.login(pengguna);
        }
      } catch (_) {}
    }

    if (!mounted) return;

    if (SessionManager.instance.sudahLogin) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
Future<void> _seedEmbeddingJikaPerlu() async {
  debugPrint('🌱 Seed embedding mulai, total resep: ${kResepList.length}');
  final db = Database();
  for (final resep in kResepList) {
    final idResep = int.tryParse(resep.id);
    if (idResep == null) {
      debugPrint('⚠️ idResep null untuk ${resep.nama}');
      continue;
    }

    final sudahAda = await db.cekEmbeddingAda(idResep);
    debugPrint('📋 ${resep.nama} — embedding sudah ada: $sudahAda');
    if (sudahAda) continue;

    final semuaBahan = resep.bahanSections
        .expand((s) => s.items)
        .map((b) => b.nama)
        .join(', ');
    final teks = '${resep.nama}. Bahan: $semuaBahan';
    debugPrint('🔄 Generate embedding untuk: ${resep.nama}');

    final embedding = await generateEmbedding(teks);
    if (embedding != null) {
      await db.updateEmbeddingResep(idResep, embedding);
      debugPrint('✅ Embedding: ${resep.nama}');
    } else {
      debugPrint('❌ Gagal generate: ${resep.nama}');
    }
  }
  debugPrint('🌱 Seed embedding selesai');
}
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image makanan (asset lokal, opacity 55%)
            Opacity(
              opacity: 0.55,
              child: Image.asset(
                'assets/images/Splash Screen.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
            ),

            // Gradient overlay bawah agar teks terbaca
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.5, 1.0],
                ),
              ),
            ),

            // Branding tengah layar
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                     Text(
                    'KaryaRasa',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                   SizedBox(height: 8),
                  Text(
                    'Rasa Warisan Budaya',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}