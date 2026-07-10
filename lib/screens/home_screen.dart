import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/bottom_nav_bar.dart';
import '../data/resep_data.dart';
import '../utils/session_manager.dart';
import 'resep_detail_screen.dart';
import 'search_screen.dart';
import 'kreasi_screen.dart';
import '../database/database.dart';
import '../models/artikel.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _olive = Color(0xFF91A365);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFDFAF7);
  static const _heroBg = Color(0xFF772F1A);

  List<Artikel> _artikelList = [];

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF1E1E1E) : _creamBg;
  Color get cardColor => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get textColor => isDark ? Colors.white : const Color(0xFF2C1A10);
  Color get secondaryTextColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;
  Color get shimmerBase => isDark ? Colors.grey[800]! : Colors.grey[300]!;
  Color get shimmerHighlight => isDark ? Colors.grey[700]! : Colors.grey[100]!;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await loadResepFromDatabase(start: kResepList.length, limit: 10, append: true);
    if (mounted) setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = Database();
    final artikels = await db.getAllArtikel();
    if (mounted) setState(() => _artikelList = artikels);
    await _syncBookmarks();
  }

  Future<void> _syncBookmarks() async {
    final idPengguna = SessionManager.instance.idPengguna;
    if (idPengguna == null) return;
    await syncBookmarkState(idPengguna);
    if (mounted) setState(() {});
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed('/search');
    } else if (index == 2) {
      Navigator.of(context).pushNamed('/kreasi');
    } else if (index == 3) {
      Navigator.of(context).pushNamed('/racik');
    } else if (index == 4) {
      Navigator.of(context).pushNamed('/profile');
    } else {
      setState(() => _navIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                color: _terracotta,
                onRefresh: () async {
                  await loadResepFromDatabase();
                  await _loadData();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (kResepList.isEmpty) ...[
                        _buildShimmerPlaceholder(),
                        _buildShimmerPlaceholder(),
                        _buildShimmerPlaceholder(),
                      ] else ...[
                        _buildHeroBanner(),
                        const SizedBox(height: 20),
                        _buildWarisanAndDaerah(),
                        const SizedBox(height: 20),
                        _buildRekomendasi(),
                        const SizedBox(height: 20),
                        _buildBelajarSejarah(),
                      ],
                      const SizedBox(height: 24),
                      if (_isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Center(child: CircularProgressIndicator(color: _terracotta)),
                        ),
                    ],
                  ),  // closes Column
                ),  // closes SingleChildScrollView
              ),  // closes RefreshIndicator
            ),  // closes Expanded
            KaryaRasaBottomNav(currentIndex: _navIndex, onTap: _onNavTap),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        'KaryaRasa',
        style: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ── Hero Banner ──────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
  final resepHariIni = kResepList.isNotEmpty ? kResepList.first : null;
  return GestureDetector(
    onTap: resepHariIni == null ? null : () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResepDetailScreen(resep: resepHariIni),
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background — gambar pertama dari resep hari ini
              if (resepHariIni != null && resepHariIni.imageUrls.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: resepHariIni.imageUrls.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(color: _brown),
                )
              else
                Container(color: _brown),
              // Dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              // Thumbnail stack on right — gambar ke-2 dan ke-3 dari resep
              if (resepHariIni != null && resepHariIni.imageUrls.length > 1)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Column(
                    children: [
                      _miniThumb(resepHariIni.imageUrls[1]),
                      if (resepHariIni.imageUrls.length > 2) ...[
                        const SizedBox(height: 6),
                        _miniThumb(resepHariIni.imageUrls[2]),
                      ],
                    ],
                  ),
                ),
              // Text content
              Positioned(
                left: 16,
                bottom: 16,
                right: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _terracotta.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'UNGGULAN NUSANTARA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Selamat Datang!\nTemukan Jiwa Kuliner\nNusantara',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.circle, color: _terracotta, size: 6),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            kResepList.isNotEmpty
  ? 'Resep Hari Ini: ${kResepList.first.nama} (${kResepList.first.daerah})'
  : 'Resep Hari Ini: -',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
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
    ),
  );
  }

  Widget _miniThumb(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 68,
        height: 68,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: shimmerBase,
            highlightColor: shimmerHighlight,
            child: Container(color: cardColor),
          ),
          errorWidget: (context, url, error) => Container(color: _brown.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  // ── Warisan Rasa + Jelajahi Daerah ───────────────────────────────────────
  Widget _buildWarisanAndDaerah() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warisan Rasa
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warisan Rasa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                _warisanPill(
                  'https://images.unsplash.com/photo-1512058454905-6b841e7ad132?auto=format&fit=crop&w=100&q=80',
                  'Makanan',
                  _brown,
                  Colors.white,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SearchScreen(initialCategory: 'Makanan'),
                  )),
                ),
                const SizedBox(height: 8),
                _warisanPill(
                  'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=100&q=80',
                  'Jajanan',
                  _olive,
                  Colors.white,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SearchScreen(initialCategory: 'Snack'),
                  )),
                ),
                const SizedBox(height: 8),
                _warisanPill(
                  'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=100&q=80',
                  'Minuman',
                  const Color(0xFFEDE8DF),
                  _brown,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SearchScreen(initialCategory: 'Minuman'),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Jelajahi Daerah
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jelajahi Daerah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                _daerahGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _warisanPill(String imgUrl, String label, Color bgColor, Color textColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipOval(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CachedNetworkImage(
                imageUrl: imgUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: textColor.withValues(alpha: 0.1)),
                errorWidget: (context, url, error) => Container(
                  color: textColor.withValues(alpha: 0.2),
                  child: Icon(Icons.restaurant, color: textColor, size: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _daerahGrid() {
    const items = [
      {'label': 'SUMATERA', 'icon': Icons.temple_hindu_rounded},
      {'label': 'JAWA', 'icon': Icons.account_balance_rounded},
      {'label': 'BALI', 'icon': Icons.temple_buddhist_rounded},
      {'label': 'SULAWESI', 'icon': Icons.landscape_rounded},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.1,
      children: items.map((item) {
        final label = item['label'] as String;
        // Ubah label (uppercase) ke query daerah yang cocok dengan data
        final daerahQuery = label[0] + label.substring(1).toLowerCase(); // "JAWA" → "Jawa"
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SearchScreen(initialSearchQuery: daerahQuery),
          )),
          child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'] as IconData, color: _gold, size: 26),
              const SizedBox(height: 4),
              Text(
                item['label'] as String,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: 0.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        );
      }).toList(),
    );
  }

  // ── Rekomendasi Minggu Ini ───────────────────────────────────────────────
  Widget _buildRekomendasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rekomendasi Minggu Ini',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  _navArrow(Icons.chevron_left_rounded),
                  const SizedBox(width: 4),
                  _navArrow(Icons.chevron_right_rounded),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 270,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: kResepList.take(3).map((resep) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _rekomendasiCard(
                  resep.nama,
                  resep.sejarahSingkat,
                  resep.imageUrls.first,
                  resep.rating.round() > 0 ? resep.rating.round() : 5, // Fallback to 5 visually if no comments exist
                  resep.likeCount,
                  resep: resep,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _navArrow(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
        color: cardColor,
      ),
      child: Icon(icon, size: 18, color: _brown),
    );
  }

  Widget _rekomendasiCard(
    String title,
    String desc,
    String imgUrl,
    int stars,
    int reviewCount, {
    required ResepData resep,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResepDetailScreen(resep: resep),
          ),
        );
      },
      child: Container(
      width: 200,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with heart
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: shimmerBase,
                      highlightColor: shimmerHighlight,
                      child: Container(color: cardColor),
                    ),
                    errorWidget: (context, url, error) => Container(color: _brown.withValues(alpha: 0.3)),
                  ),
                ),
              ),

            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                        color: _gold,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($reviewCount)',
                      style: TextStyle(fontSize: 10, color: secondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: secondaryTextColor, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      ),  // closes Container
    );    // closes GestureDetector
  }

  // ── Belajar Sejarah Kuliner ──────────────────────────────────────────────
  Widget _buildBelajarSejarah() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belajar Sejarah Kuliner',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._artikelList.take(3).map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _sejarahCard(a),
              )),
        ],
      ),
    );
  }

  Widget _sejarahCard(Artikel artikel) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: _brown,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artikel.judulArtikel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      artikel.excerpt,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(artikel: artikel),
                    )),
                    child: Row(
                      children: [
                        const Text(
                          'BACA SELENGKAPNYA',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_rounded, color: _gold, size: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
              child: SizedBox(
                height: double.infinity,
                child: Image.network(
                  artikel.fotoArtikel ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _brown.withValues(alpha: 0.5),
                    child: const Icon(Icons.restaurant, color: Colors.white54, size: 40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}