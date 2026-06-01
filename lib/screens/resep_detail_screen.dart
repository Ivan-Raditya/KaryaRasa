import 'package:flutter/material.dart';
import '../data/resep_data.dart';
import '../database/database.dart';
import '../models/bookmark.dart';
import '../models/koleksi_bookmark.dart';
import '../utils/session_manager.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
class ResepDetailScreen extends StatefulWidget {
  final ResepData resep;

  const ResepDetailScreen({super.key, required this.resep});

  @override
  State<ResepDetailScreen> createState() => _ResepDetailScreenState();
}

class _ResepDetailScreenState extends State<ResepDetailScreen>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  bool _bookmarked = false;
  bool _isCooking = false;
  late TabController _tabCtrl;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFDFAF7);
  static const _darkBrown = Color(0xFF2C1A10);

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.resep.isBookmarked;
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  Future<void> _toggleBookmark() async {
    final idPengguna = SessionManager.instance.idPengguna;
    final idResep = int.tryParse(widget.resep.id);

    if (idPengguna == null || idResep == null) {
      // Belum login — toggle lokal saja
      setState(() {
        _bookmarked = !_bookmarked;
        widget.resep.isBookmarked = _bookmarked;
      });
      return;
    }

    final db = Database();
    if (_bookmarked) {
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
    setState(() {
      _bookmarked = !_bookmarked;
      widget.resep.isBookmarked = _bookmarked;
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Hero Image Slider ──────────────────────────────────
              _buildHeroSlider(),
              // ── Scrollable Content ─────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      _buildSejarahSection(),
                      _buildTabBar(),
                      _buildTabContent(),
                      _buildVideoSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Top App Bar (floating) ─────────────────────────────────
          _buildTopBar(),
          // ── Bottom CTA ────────────────────────────────────────────
          _buildBottomCta(),
        ],
      ),
    );
  }

  // ── Hero Image Slider ───────────────────────────────────────────────────────
  Widget _buildHeroSlider() {
    final images = widget.resep.imageUrls;
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (_, i) => Image.network(
              images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(color: _brown),
            ),
          ),
          // Title pill overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _darkBrown.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.resep.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          // Page indicator dots
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: i == _currentImageIndex ? 18 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _currentImageIndex
                        ? _terracotta
                        : Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating Top Bar ────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: _brown, size: 16),
              ),
            ),
            GestureDetector(
              onTap: _toggleBookmark,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8)
                  ],
                ),
                child: Icon(
                  _bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _bookmarked ? _terracotta : _brown,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Title + Info Section ────────────────────────────────────────────────────
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.resep.nama,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: _darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 14, color: _terracotta),
              const SizedBox(width: 4),
              Text(
                widget.resep.daerah,
                style:
                    const TextStyle(fontSize: 13, color: _terracotta),
              ),
              const Spacer(),
              _infoChip(Icons.timer_outlined, '${widget.resep.durasiMasak} menit'),
              const SizedBox(width: 8),
              _infoChip(Icons.people_outline_rounded,
                  '${widget.resep.porsi} porsi'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDE6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _brown),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _brown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sejarah Section ─────────────────────────────────────────────────────────
  Widget _buildSejarahSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sejarah Singkat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.resep.sejarahSingkat,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Tab Bar ─────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDE8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: _terracotta,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Bahan-Bahan'),
          Tab(text: 'Cara Membuat'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  // ── Tab Content ─────────────────────────────────────────────────────────────
  Widget _buildTabContent() {
    return AnimatedBuilder(
      animation: _tabCtrl,
      builder: (_, __) {
        if (_tabCtrl.index == 0) {
          return _buildBahanTab();
        } else {
          return _buildCaraMembuatTab();
        }
      },
    );
  }

  Widget _buildBahanTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.resep.bahanSections.map((section) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.judul,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _darkBrown,
                  ),
                ),
                const SizedBox(height: 8),
                ...section.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _terracotta,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${item.jumlah} ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _darkBrown,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.nama,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCaraMembuatTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cara Membuat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _darkBrown,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.resep.langkah.asMap().entries.map((e) {
            final idx = e.key + 1;
            final text = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _terracotta,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$idx',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Video Section ───────────────────────────────────────────────────────────
  Widget _buildVideoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tonton Video Pembuatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _darkBrown,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    widget.resep.videoThumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: _brown.withValues(alpha: 0.5)),
                  ),
                ),
                // Dark overlay
                Container(
                  height: 180,
                  color: _darkBrown.withValues(alpha: 0.45),
                ),
                // Play button pill
                GestureDetector(
                  onTap: () {
                    setState(() => _isCooking = !_isCooking);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka video pembuatan...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _terracotta,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _terracotta.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Mulai Memasak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom CTA ──────────────────────────────────────────────────────────────
  Widget _buildBottomCta() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: _creamBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Bookmark
            GestureDetector(
              onTap: _toggleBookmark,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _bookmarked
                      ? _terracotta.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _bookmarked
                        ? _terracotta.withValues(alpha: 0.3)
                        : const Color(0xFFEEEEEE),
                  ),
                ),
                child: Icon(
                  _bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _bookmarked ? _terracotta : Colors.grey,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Start cooking CTA
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _tabCtrl.animateTo(1);
                  setState(() {});
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _terracotta,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _terracotta.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Mulai Memasak',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}