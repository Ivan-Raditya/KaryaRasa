import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _activeCategory = 'Semua';
  String _searchQuery = '';

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFDFAF6);

  final List<String> _categories = [
    'Semua', 'Nusantara', 'Tradisional', 'Modern', 'Vegetarian', 'Dessert',
  ];

  final List<Map<String, dynamic>> _allRecipes = [
    {'name': 'Rendang Padang', 'region': 'SUMATERA BARAT', 'rating': 4.9, 'image': 'https://images.unsplash.com/photo-1574653853027-5382a3d23a15?auto=format&fit=crop&w=400&q=80', 'time': '120 menit'},
    {'name': 'Gudeg Yogyakarta', 'region': 'YOGYAKARTA', 'rating': 4.7, 'image': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=400&q=80', 'time': '90 menit'},
    {'name': 'Soto Betawi', 'region': 'DKI JAKARTA', 'rating': 4.6, 'image': 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=400&q=80', 'time': '60 menit'},
    {'name': 'Ayam Betutu', 'region': 'BALI', 'rating': 4.8, 'image': 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=400&q=80', 'time': '180 menit'},
    {'name': 'Pempek Palembang', 'region': 'SUMATERA SELATAN', 'rating': 4.5, 'image': 'https://images.unsplash.com/photo-1512058454905-6b841e7ad132?auto=format&fit=crop&w=400&q=80', 'time': '45 menit'},
    {'name': 'Sate Madura', 'region': 'JAWA TIMUR', 'rating': 4.7, 'image': 'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=400&q=80', 'time': '40 menit'},
    {'name': 'Gado-Gado Betawi', 'region': 'DKI JAKARTA', 'rating': 4.4, 'image': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=400&q=80', 'time': '30 menit'},
    {'name': 'Coto Makassar', 'region': 'SULAWESI SELATAN', 'rating': 4.6, 'image': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=400&q=80', 'time': '75 menit'},
  ];

  List<Map<String, dynamic>> get _filteredRecipes {
    return _allRecipes.where((r) {
      final matchQuery = _searchQuery.isEmpty ||
          (r['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (r['region'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchQuery;
    }).toList();
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EDE8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: _brown, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Jelajah',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C1A10),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  Container(
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
                ],
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
              child: _filteredRecipes.isEmpty
                  ? _buildEmpty()
                  : CustomScrollView(
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
            ),

            // ── Bottom Nav ──────────────────────────────────────────────────
            KaryaRasaBottomNav(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) {
                  Navigator.of(context).pushReplacementNamed('/');
                } else if (index == 2) {
                  Navigator.of(context).pushReplacementNamed('/bookmark');
                } else if (index == 3) {
                  Navigator.of(context).pushNamed('/profile');
                }
              },
            ),
          ],
        ),
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

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
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
                      recipe['image'] as String,
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
                      recipe['region'] as String,
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
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmark_border_rounded, size: 14, color: _brown),
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
                  recipe['name'] as String,
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
                      '${recipe['rating']}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 2),
                    Text(
                      recipe['time'] as String,
                      style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
