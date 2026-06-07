import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_nav_bar.dart';
import '../data/resep_data.dart';
import '../database/database.dart';
import '../models/bookmark.dart';
import '../models/koleksi_bookmark.dart';
import '../utils/session_manager.dart';
import 'resep_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchQuery;

  const SearchScreen({
    super.key,
    this.initialCategory,
    this.initialSearchQuery,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _activeCategory = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _activeCategory = widget.initialCategory!;
    }
    if (widget.initialSearchQuery != null) {
      _searchQuery = widget.initialSearchQuery!;
      _searchController.text = widget.initialSearchQuery!;
    }
  }

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFDFAF6);
  static const _heroBg = Color(0xFF772F1A);

  // Kategori disesuaikan dengan nilai kategoriResep di DB
  final List<String> _categories = [
    'Semua', 'Makanan', 'Minuman', 'Dessert', 'Snack', 'Vegetarian',
  ];

  List<ResepData> get _filteredRecipes {
    return kResepList.where((r) {
      final matchQuery = _searchQuery.isEmpty ||
          r.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.daerah.toLowerCase().contains(_searchQuery.toLowerCase());
      // Filter kategori: cocokkan dengan field kategori yang sudah disimpan di ResepData
      final matchCategory = _activeCategory == 'Semua' ||
          r.kategori.toLowerCase() == _activeCategory.toLowerCase();
      return matchQuery && matchCategory;
    }).toList();
  }

  Future<void> _toggleBookmark(ResepData recipe) async {
    final idPengguna = SessionManager.instance.idPengguna;
    final idResep = int.tryParse(recipe.id);
    if (idPengguna == null || idResep == null) {
      // Belum login — toggle lokal saja
      setState(() => recipe.isBookmarked = !recipe.isBookmarked);
      return;
    }

    final db = Database();
    if (recipe.isBookmarked) {
      // Hapus bookmark dari DB
      await db.deleteBookmark(idResep, idPengguna);
    } else {
      // Pastikan ada koleksi default
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: Column(
        children: [
            // ── Hero Header ──────────────────────────────────────────────
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
              'Jelajah',   // ← ganti: 'Simpan' / 'Jelajah' / 'Artikel Kuliner'
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
            // ── Separator ───────────────────────────────────────────────
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
            // ── Search Bar ───────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDE8),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari resep, bahan, atau daerah...',
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // ── Category Chips ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final active = cat == _activeCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _activeCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? _terracotta : const Color(0xFFF0EDE8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : _brown,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // ── Results ─────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: _terracotta,
                onRefresh: () async {
                  await loadResepFromDatabase();
                  if (mounted) setState(() {});
                },
                child: _filteredRecipes.isEmpty
                    ? Stack(children: [
                        ListView(), // agar RefreshIndicator bisa ditarik saat kosong
                        _buildEmpty(),
                      ])
                    : CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? '${_filteredRecipes.length} Resep Ditemukan'
                                  : 'Hasil untuk "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _buildRecipeCard(_filteredRecipes[i]),
                              childCount: _filteredRecipes.length,
                            ),
                          ),
                        ),
                      ],
                    ),
              ),  // closes RefreshIndicator
            ),

            // ── Bottom Nav ──────────────────────────────────────────────────
            KaryaRasaBottomNav(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushReplacementNamed('/');
                } else if (index == 2) {
                  Navigator.of(context).pushReplacementNamed('/kreasi');
                } else if (index == 3) {
                  Navigator.of(context).pushReplacementNamed('/racik');
                } else if (index == 4) {
                  Navigator.of(context).pushNamed('/profile');
                }
              },
            ),
          ],
        ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Resep tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba kata kunci lain',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(ResepData recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResepDetailScreen(resep: recipe),
          ),
        ).then((_) => setState(() {}));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: SizedBox.expand(
                      child: Image.network(
                        recipe.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: _brown.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                  // Region badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _terracotta.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        recipe.daerah.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  // Bookmark icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleBookmark(recipe),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          recipe.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 14,
                          color: recipe.isBookmarked ? _terracotta : _brown,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.nama,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C1A10),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: _gold, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.rating}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(
                        '${recipe.durasiMasak} mnt',
                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
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