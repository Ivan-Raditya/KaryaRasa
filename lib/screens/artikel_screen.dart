import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database.dart';
import '../models/artikel.dart';
import '../models/simpan_artikel.dart';
import '../utils/session_manager.dart';
import 'article_detail_screen.dart';

// ── Data Model ────────────────────────────────────────────────────────────────


// ── Screen ────────────────────────────────────────────────────────────────────
class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _creamBg = Color(0xFFFDFAF7);
  static const _heroBg = Color(0xFF772F1A);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _loadArtikel();
  }

  List<Artikel> _artikelList = [];
  bool _isLoading = true;

  Future<void> _loadArtikel() async {
    setState(() => _isLoading = true);
    try {
      final db = Database();
      final list = await db.getAllArtikel();
      final idPengguna = SessionManager.instance.idPengguna;
      if (idPengguna != null) {
        final savedList = await db.getArtikelDisimpanByPengguna(idPengguna);
        final savedIds = savedList.map((a) => a.idArtikel).toSet();
        for (final a in list) {
          a.isSaved = savedIds.contains(a.idArtikel);
        }
      }
      if (mounted) setState(() { _artikelList = list; _isLoading = false; });
    } catch (e) {
      debugPrint('loadArtikel: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: RefreshIndicator(
                  color: _terracotta,
                  onRefresh: _loadArtikel,
                  child: _buildArtikelList(),
                ),
              ),
            ),

          ],
        ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Hero Header ─────────────────────────────────────────────────
Container(
  decoration: BoxDecoration(
    color: _heroBg,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 17),
            ),
          ),
          Expanded(
            child: Text(
              'Artikel Kuliner',   // ← ganti: 'Simpan' / 'Jelajah' / 'Artikel Kuliner'
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    ),
  ),
),
        // ── Separator ─────────────────────────────────────────────────
        Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _terracotta.withValues(alpha: 0.7),
                _brown.withValues(alpha: 0.4),
                _terracotta.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Article List ────────────────────────────────────────────────────────────
  Widget _buildArtikelList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _terracotta));
    }
    if (_artikelList.isEmpty) {
      return const Center(child: Text('Belum ada artikel.'));
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _artikelList.length,
      itemBuilder: (context, index) {
        final artikel = _artikelList[index];
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeaturedArtikelCard(
              artikel: artikel,
              onTap: () => _openArtikel(artikel),
              onToggleSave: () => _toggleSave(artikel),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ArtikelListCard(
            artikel: artikel,
            onTap: () => _openArtikel(artikel),
            onToggleSave: () => _toggleSave(artikel),
          ),
        );
      },
    );
  }

  void _openArtikel(Artikel artikel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(artikel: artikel),
      ),
    ).then((_) => _loadArtikel());
  }

  Future<void> _toggleSave(Artikel artikel) async {
    final idPengguna = SessionManager.instance.idPengguna;
    final idArtikel = artikel.idArtikel;
    if (idPengguna == null || idArtikel == null) {
      setState(() => artikel.isSaved = !artikel.isSaved);
      return;
    }
    final db = Database();
    if (artikel.isSaved) {
      await db.hapusSimpanArtikel(idPengguna, idArtikel);
    } else {
      await db.simpanArtikel(SimpanArtikel(
        idPengguna: idPengguna,
        idArtikel: idArtikel,
        tglDisimpan: DateTime.now().toIso8601String(),
      ));
    }
    setState(() => artikel.isSaved = !artikel.isSaved);
  }
}

// ── Featured Article Card ─────────────────────────────────────────────────────
class _FeaturedArtikelCard extends StatelessWidget {
  final Artikel artikel;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _brown = Color(0xFF4A2B20);

  const _FeaturedArtikelCard({
    required this.artikel,
    required this.onTap,
    required this.onToggleSave,
  });
  // (tidak berubah, tapi field di atas harus sudah Artikel)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Hero image
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Image.network(
                  artikel.fotoArtikel ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: _brown),
                ),
              ),
              // Gradient overlay
              Container(
                height: 260,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              // Featured badge
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _terracotta,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'UNGGULAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bookmark/Save button
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: onToggleSave,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      artikel.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: artikel.isSaved ? _terracotta : Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ),
              ),
              // Text content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        artikel.kategori.toUpperCase(), // sama, tidak berubah
                        style: const TextStyle(
                          color: Color(0xFF2C1A10),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      artikel.judulArtikel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          artikel.penulis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${artikel.menitBaca} min baca',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
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
    );
  }
}

// ── Article List Card ─────────────────────────────────────────────────────────
class _ArtikelListCard extends StatelessWidget {
  final Artikel artikel;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);

  const _ArtikelListCard({
    required this.artikel,
    required this.onTap,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: SizedBox(
                width: 110,
                height: 110,
                child: Image.network(
                  artikel.fotoArtikel ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: _brown.withValues(alpha: 0.3)),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Save button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _terracotta.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            artikel.kategori,
                            style: TextStyle(
                              color: _terracotta,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onToggleSave,
                          child: Icon(
                            artikel.isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: artikel.isSaved ? _terracotta : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      artikel.judulArtikel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C1A10),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline_rounded,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            artikel.penulis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(
                          '${artikel.menitBaca} min',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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
}