import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/resep_data.dart';
import '../database/database.dart';
import '../models/bookmark.dart';
import '../models/koleksi_bookmark.dart';
import '../utils/session_manager.dart';
import 'resep_detail_screen.dart';
import 'artikel_screen.dart';
import '../models/artikel.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _creamBg = Color(0xFFFDFAF7);
  static const _heroBg = Color(0xFF772F1A);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF1E1E1E) : _creamBg;
  Color get cardColor => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get textColor => isDark ? Colors.white : const Color(0xFF2C1A10);

  List<ResepData> get _savedRecipes =>
      kResepList.where((r) => r.isBookmarked).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _syncBookmarks();
    _syncSavedArtikel();
  }

  Future<void> _syncBookmarks() async {
    final idPengguna = SessionManager.instance.idPengguna;
    if (idPengguna == null) return;
    await syncBookmarkState(idPengguna);
    if (mounted) setState(() {});
  }

  Future<void> _toggleBookmark(ResepData recipe) async {
    final idPengguna = SessionManager.instance.idPengguna;
    final idResep = int.tryParse(recipe.id);
    if (idPengguna == null || idResep == null) {
      setState(() => recipe.isBookmarked = !recipe.isBookmarked);
      return;
    }

    final db = Database();
    if (recipe.isBookmarked) {
      await db.deleteBookmark(idResep, idPengguna);
    } else {
      final koleksiList = await db.getKoleksiByPengguna(idPengguna);
      int idBookmark;
      if (koleksiList.isEmpty) {
        idBookmark = await db.insertKoleksi(KoleksiBookmark(
          idPengguna: idPengguna,
          judulBookmark: 'Favorit',
        ));
      } else {
        idBookmark = koleksiList.first.idBookmark!;
      }
      await db.insertBookmark(Bookmark(
        idResep: idResep,
        idPengguna: idPengguna,
        idBookmark: idBookmark,
        tglDibuat: DateTime.now().toIso8601String(),
      ));
    }
    setState(() => recipe.isBookmarked = !recipe.isBookmarked);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Hero Header ─────────────────────────────────────────────────
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
              'Bookmark',   // ← ganti: 'Simpan' / 'Jelajah' / 'Artikel Kuliner'
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
          // ── Separator ────────────────────────────────────────────────────
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

          // ── Tab Bar (hanya Resep & Artikel) ─────────────────────────────
          Container(
            color: bgColor,
            child: TabBar(
              controller: _tabController,
              labelColor: _terracotta,
              unselectedLabelColor: Colors.grey[500],
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
              indicatorColor: _terracotta,
              indicatorWeight: 2.5,
              tabs: const [
                Tab(text: 'Resep'),
                Tab(text: 'Artikel'),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResepTab(),
                _buildArtikelTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResepTab() {
    return RefreshIndicator(
      color: _terracotta,
      onRefresh: _syncBookmarks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resep Tersimpan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 14),
              _savedRecipes.isEmpty
                  ? _buildEmptyInline()
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _savedRecipes.length,
                      itemBuilder: (context, i) =>
                          _buildSavedCard(_savedRecipes[i]),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyInline() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.bookmark_border_rounded, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Belum ada resep tersimpan',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(ResepData recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => ResepDetailScreen(resep: recipe),
            ))
            .then((_) => _syncBookmarks());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox.expand(
                    child: Image.network(
                      recipe.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: _brown.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _terracotta.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      recipe.daerah.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _toggleBookmark(recipe),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        recipe.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 15,
                        color: recipe.isBookmarked ? _terracotta : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            recipe.nama,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<Artikel> _savedArtikel = [];

  Future<void> _syncSavedArtikel() async {
    final idPengguna = SessionManager.instance.idPengguna;
    if (idPengguna == null) return;
    try {
      final db = Database();
      final list = await db.getArtikelDisimpanByPengguna(idPengguna);
      for (final a in list) {
        a.isSaved = true;
      }
      if (mounted) setState(() {
        _savedArtikel = list;
      });
    } catch (e) {
      debugPrint('syncSavedArtikel: $e');
    }
  }

  Widget _buildArtikelTab() {
    return RefreshIndicator(
      color: _terracotta,
      onRefresh: () async {
        await _syncSavedArtikel();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Artikel Tersimpan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 14),
              _savedArtikel.isEmpty
                  ? _buildEmptyInlineArtikel()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedArtikel.length,
                      itemBuilder: (context, i) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSavedArtikelCard(_savedArtikel[i]),
                          ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyInlineArtikel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Belum ada artikel tersimpan',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedArtikelCard(Artikel artikel) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
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
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.network(
                  artikel.fotoArtikel ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: _brown.withValues(alpha: 0.3)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artikel.kategori,
                      style: TextStyle(
                        color: _terracotta,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artikel.judulArtikel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      artikel.penulis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
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

  Widget _buildEmptyTab(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500])),
        ],
      ),
    );
  }
}