import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../data/resep_data.dart';
import 'resep_detail_screen.dart';

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

  List<ResepData> get _savedRecipes {
    return kResepList.where((r) => r.isBookmarked).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: Column(
        children: [
          // ── Hero Header ─────────────────────────────────────────────────
          SizedBox(
            height: 110,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Food background
                Image.network(
                  'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: _brown),
                ),
                // Dark overlay
                Container(color: Colors.black.withValues(alpha: 0.45)),
                // Safe area + controls
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        // Title
                        const Expanded(
                          child: Text(
                            'Bookmark',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        // Search button
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab Bar ──────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: _terracotta,
              unselectedLabelColor: Colors.grey[500],
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              indicatorColor: _terracotta,
              indicatorWeight: 2.5,
              tabs: const [
                Tab(text: 'Resep'),
                Tab(text: 'Artikel'),
                Tab(text: 'Koleksi'),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Resep Tab ────────────────────────────────────────────
                _buildResepTab(),
                // ── Artikel Tab ──────────────────────────────────────────
                _buildEmptyTab('Belum ada artikel tersimpan', Icons.article_rounded),
                // ── Koleksi Tab ──────────────────────────────────────────
                _buildEmptyTab('Belum ada koleksi dibuat', Icons.collections_bookmark_rounded),
              ],
            ),
          ),

          // ── Bottom Nav ───────────────────────────────────────────────────
          KaryaRasaBottomNav(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/');
              } else if (index == 1) {
                Navigator.of(context).pushReplacementNamed('/search');
              } else if (index == 3) {
                Navigator.of(context).pushNamed('/profile');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResepTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Buat Koleksi Baru ──────────────────────────────────────
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _terracotta.withValues(alpha: 0.6),
                    width: 1.5,
                    // Simulated dashed with strokeAlign trick
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: _terracotta, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Buat Koleksi Baru',
                      style: TextStyle(
                        color: _terracotta,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Resep Tersimpan ─────────────────────────────────────────
            const Text(
              'Resep Tersimpan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C1A10),
              ),
            ),
            const SizedBox(height: 14),

            // Grid 2 kolom
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: _savedRecipes.length,
              itemBuilder: (context, i) => _buildSavedCard(_savedRecipes[i], i),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(ResepData recipe, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResepDetailScreen(resep: recipe),
          ),
        ).then((_) => setState(() {}));
      },
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
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
              // Region badge
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Bookmark icon top-right
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      recipe.isBookmarked = !recipe.isBookmarked;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
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
        // Name
        Text(
          recipe.nama,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C1A10),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
