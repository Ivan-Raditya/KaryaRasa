import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/resep_data.dart';
import '../database/database.dart';
import '../models/riwayat_kreasi_ai.dart';
import '../models/hasil_rekomendasi_ai.dart';
import '../utils/session_manager.dart';
import '../widgets/bottom_nav_bar.dart';
import 'resep_detail_screen.dart';
import '../utils/supabase_config.dart'; // untuk generateEmbedding

class RacikScreen extends StatefulWidget {
  const RacikScreen({super.key});

  @override
  State<RacikScreen> createState() => _RacikScreenState();
}

class _RacikScreenState extends State<RacikScreen> {
  // ── Warna (konsisten dengan project) ──────────────────────────────────────
  static const _brown      = Color(0xFF5D4D37);
  static const _terracotta = Color(0xFFB14D28);
  static const _gold       = Color(0xFFD5B534);
  static const _creamBg    = Color(0xFFF8F7F6);
  static const _chipBg     = Color(0x338DA38B);
  static const _chipBorder = Color(0x4C8DA38B);
  static const _divider    = Color(0x19D5B534);

  // ── State ──────────────────────────────────────────────────────────────────
  final TextEditingController _inputController = TextEditingController();
  final List<String> _bahanList = [];
  List<_HasilRacik> _hasilList = [];

  bool _isLoading = false;
  bool _sudahCari = false;
  String? _errorMsg;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // ── Tambah bahan dari input ────────────────────────────────────────────────
  void _tambahBahan() {
    final teks = _inputController.text.trim();
    if (teks.isEmpty) return;

    // Pisahkan jika ada koma (misal: "Telur, Tahu, Bayam")
    final items = teks.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    setState(() {
      for (final item in items) {
        if (!_bahanList.contains(item)) {
          _bahanList.add(item);
        }
      }
      _hasilList.clear();
      _sudahCari = false;
    });
    _inputController.clear();
  }

  // ── Hapus bahan dari chip ──────────────────────────────────────────────────
  void _hapusBahan(String bahan) {
    setState(() {
      _bahanList.remove(bahan);
      _hasilList.clear();
      _sudahCari = false;
    });
  }

  // ── Cari rekomendasi ───────────────────────────────────────────────────────
Future<void> _cariRekomendasi() async {
  if (_bahanList.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tambahkan minimal 1 bahan terlebih dahulu')),
    );
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMsg  = null;
    _hasilList = [];
  });

  try {
    final db         = Database();
    final idPengguna = SessionManager.instance.idPengguna;
    final bahanInput = _bahanList.join(', ');

    // 1. Simpan riwayat kreasi
    int? idKreasi;
    if (idPengguna != null) {
      idKreasi = await db.insertKreasi(
        RiwayatKreasiAI(idPengguna: idPengguna, bahanInput: bahanInput),
      );
    }

    // 2. Generate embedding dari input bahan user
    final queryEmbedding = await generateEmbedding(bahanInput);

    List<_HasilRacik> top = [];

    if (queryEmbedding != null) {
      // ── Path A: pgvector ──────────────────────────────────────────────
      final pgResult = await db.cariResepPgvector(queryEmbedding, limit: 5);

      for (final row in pgResult) {
        final idResep   = row['idResep'] as int?;
        final similarity = (row['similarity'] as num?)?.toDouble() ?? 0.0;
        if (idResep == null) continue;

        // Cari data lokal dari kResepList supaya tidak perlu query ulang
        final resepLocal = kResepList.firstWhere(
          (r) => r.id == idResep.toString(),
          orElse: () => throw StateError('not found'),
        );

        // Konversi similarity (0–1) ke skor persentase (1–100)
        final skor = (similarity * 100).round().clamp(1, 100);
        top.add(_HasilRacik(resep: resepLocal, skor: skor));
      }
    } else {
      // ── Path B: fallback ke algoritma teks lama ───────────────────────
      final bahanLower = _bahanList.map((b) => b.toLowerCase()).toList();
      final kandidat   = <_HasilRacik>[];

      for (final resep in kResepList) {
        final semuaBahan = resep.bahanSections
            .expand((s) => s.items)
            .map((i) => i.nama.toLowerCase())
            .toList();
        if (semuaBahan.isEmpty) continue;

        int cocok = 0;
        for (final bahan in bahanLower) {
          if (semuaBahan.any((b) => b.contains(bahan) || bahan.contains(b))) {
            cocok++;
          }
        }
        if (cocok == 0) continue;

        final skor = ((cocok / semuaBahan.length) * 100).round().clamp(1, 100);
        kandidat.add(_HasilRacik(resep: resep, skor: skor));
      }

      kandidat.sort((a, b) => b.skor.compareTo(a.skor));
      top = kandidat.take(5).toList();
    }

    // 3. Simpan hasil ke database
    if (idKreasi != null) {
      for (final h in top) {
        final idResep = int.tryParse(h.resep.id);
        if (idResep == null) continue;
        await db.insertHasilAI(
          HasilRekomendasiAI(
            idKreasi: idKreasi,
            idResep: idResep,
            skorKecocokan: h.skor,
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _hasilList = top;
      _sudahCari = true;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMsg  = 'Gagal memuat rekomendasi. Coba lagi.';
      _isLoading = false;
    });
  }
}
  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputSection(),
                    const Divider(color: _divider, thickness: 1, height: 1),
                    if (_sudahCari || _isLoading) _buildHasilSection(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: _creamBg.withValues(alpha: 0.8),
        border: const Border(
          bottom: BorderSide(color: _divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: _brown),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Racik',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _brown,
                  letterSpacing: -0.45,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // balance back button
        ],
      ),
    );
  }

  // ── Input Section ──────────────────────────────────────────────────────────
  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            'Kreasi Bahan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _brown,
              letterSpacing: -0.60,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Punya bahan apa di dapur? Biar kami carikan\nresep nusantara yang cocok.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _brown.withValues(alpha: 0.7),
              height: 1.43,
            ),
          ),
          const SizedBox(height: 16),

          // Search bar
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF2EBE1),
              borderRadius: BorderRadius.circular(48),
              border: Border.all(color: _divider),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.kitchen_outlined, color: _brown, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: (_) => _tambahBahan(),
                    decoration: InputDecoration(
                      hintText: 'Tambah bahan (Telur, Tahu...)',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: _brown.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: _brown,
                    ),
                  ),
                ),
                // Tombol tambah
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: GestureDetector(
                    onTap: _tambahBahan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Chip bahan
          if (_bahanList.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bahanList
                  .map((bahan) => _BahanChip(
                        label: bahan,
                        onDelete: () => _hapusBahan(bahan),
                      ))
                  .toList(),
            ),

          const SizedBox(height: 20),

          // Tombol cari
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _cariRekomendasi,
              style: ElevatedButton.styleFrom(
                backgroundColor: _terracotta,
                disabledBackgroundColor: _terracotta.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Carikan Resep',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hasil Section ──────────────────────────────────────────────────────────
  Widget _buildHasilSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header hasil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Menu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _brown,
                ),
              ),
              if (_hasilList.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x198DA38B),
                    border: Border.all(color: const Color(0x338DA38B)),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${_hasilList.length} Hasil Ditemukan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8DA38B),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Loading
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(color: _terracotta),
              ),
            ),

          // Error
          if (_errorMsg != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _errorMsg!,
                  style: GoogleFonts.plusJakartaSans(color: Colors.red),
                ),
              ),
            ),

          // Kosong
          if (!_isLoading && _sudahCari && _hasilList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded,
                        size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 12),
                    Text(
                      'Tidak ada resep yang cocok.\nCoba tambah bahan lain.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Kartu hasil
          if (!_isLoading && _hasilList.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _hasilList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ResepCard(
                hasil: _hasilList[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ResepDetailScreen(resep: _hasilList[i].resep),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return KaryaRasaBottomNav(
      currentIndex: 3, // index Racik
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        } else if (index == 1) {
          Navigator.of(context).pushNamed('/search');
        } else if (index == 2) {
          Navigator.of(context).pushNamed('/kreasi');
        } else if (index == 4) {
          Navigator.of(context).pushNamed('/profile');
        }
      },
    );
  }
}

// ── Model lokal untuk hasil ────────────────────────────────────────────────
class _HasilRacik {
  final ResepData resep;
  final int skor;
  const _HasilRacik({required this.resep, required this.skor});
}

// ── Widget: Chip bahan ─────────────────────────────────────────────────────
class _BahanChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  static const _brown     = Color(0xFF5D4D37);
  static const _chipBg    = Color(0x338DA38B);
  static const _chipBorder = Color(0x4C8DA38B);

  const _BahanChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _chipBg,
        border: Border.all(color: _chipBorder),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_outlined, size: 14, color: _brown),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _brown,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded, size: 14, color: _brown),
          ),
        ],
      ),
    );
  }
}

// ── Widget: Kartu resep ────────────────────────────────────────────────────
class _ResepCard extends StatelessWidget {
  final _HasilRacik hasil;
  final VoidCallback onTap;

  static const _gold = Color(0xFFD5B534);
  static const _brown = Color(0xFF5D4D37);

  const _ResepCard({required this.hasil, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final resep     = hasil.resep;
    final imageUrl  = resep.imageUrls.isNotEmpty ? resep.imageUrls.first : '';
    final skor      = hasil.skor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x19D5B534)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gambar
            SizedBox(
              width: double.infinity,
              height: 200,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),

            // Gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.80),
                    ],
                  ),
                ),
              ),
            ),

            // Info resep (bawah)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resep.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${resep.daerah} • ${resep.durasiMasak} Menit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Badge skor kecocokan
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 12, color: _brown),
                    const SizedBox(width: 4),
                    Text(
                      '$skor% Cocok',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _brown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: const Color(0xFFEDE0D4),
      child: const Center(
        child: Icon(Icons.restaurant_rounded,
            size: 48, color: Color(0xFFB09070)),
      ),
    );
  }
}
