import 'package:flutter/material.dart';
import '../data/resep_data.dart';
import '../database/database.dart';
import '../models/bookmark.dart';
import '../models/koleksi_bookmark.dart';
import '../models/langkah_masak.dart';
import '../utils/session_manager.dart';

// ── Screen ────────────────────────────────────────────────────────────────────
class ResepDetailScreen extends StatefulWidget {
  final ResepData resep;

  const ResepDetailScreen({super.key, required this.resep});

  @override
  State<ResepDetailScreen> createState() => _ResepDetailScreenState();
}

class _ResepDetailScreenState extends State<ResepDetailScreen> {
  int _currentImageIndex = 0;
  bool _bookmarked = false;

  List<LangkahMasak> _langkahList = [];
  bool _langkahLoading = true;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _creamBg = Color(0xFFFDFAF7);
  static const _darkBrown = Color(0xFF2C1A10);

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.resep.isBookmarked;
    _loadLangkah();
  }

  Future<void> _loadLangkah() async {
    final idResep = int.tryParse(widget.resep.id);
    if (idResep == null) {
      setState(() => _langkahLoading = false);
      return;
    }
    final db = Database();
    final list = await db.getLangkahByResep(idResep);
    setState(() {
      _langkahList = list;
      _langkahLoading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    final idPengguna = SessionManager.instance.idPengguna;
    final idResep = int.tryParse(widget.resep.id);

    if (idPengguna == null || idResep == null) {
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
    if (!mounted) return;
    setState(() {
      _bookmarked = !_bookmarked;
      widget.resep.isBookmarked = _bookmarked;
    });
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
                      _buildLangkahSlider(),
                      _buildBahanSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Top App Bar (floating) ─────────────────────────────────
          _buildTopBar(),
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
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                style: const TextStyle(fontSize: 13, color: _terracotta),
              ),
              const Spacer(),
              _infoChip(Icons.timer_outlined,
                  '${widget.resep.durasiMasak} menit'),
              const SizedBox(width: 8),
              _infoChip(
                  Icons.people_outline_rounded, '${widget.resep.porsi} porsi'),
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

  // ── Langkah Slider (Horizontal) ─────────────────────────────────────────────
  Widget _buildLangkahSlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Langkah Memasak',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _darkBrown,
              ),
            ),
          ),
          if (_langkahLoading)
            const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(
                  color: _terracotta,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_langkahList.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Belum ada langkah memasak.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                itemCount: _langkahList.length,
                itemBuilder: (_, i) => _buildLangkahCard(_langkahList[i], i),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLangkahCard(LangkahMasak langkah, int index) {
    final hasFoto = langkah.fotoLangkah != null &&
        langkah.fotoLangkah!.isNotEmpty;

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Foto langkah ──
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: hasFoto
                ? Image.network(
                    langkah.fotoLangkah!,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _langkahFotoPlaceholder(),
                  )
                : _langkahFotoPlaceholder(),
          ),
          // ── Nomor + deskripsi ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _terracotta,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Langkah ${langkah.nomorUrut}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      langkah.deskripsiLangkah,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _langkahFotoPlaceholder() {
    return Container(
      height: 110,
      width: double.infinity,
      color: const Color(0xFFF3EDE6),
      child: const Icon(
        Icons.restaurant_outlined,
        color: Color(0xFFD9B8A8),
        size: 36,
      ),
    );
  }

  // ── Bahan-Bahan Section ─────────────────────────────────────────────────────
  Widget _buildBahanSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bahan-Bahan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _darkBrown,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.resep.bahanSections.map((section) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (section.judul.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        section.judul,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _brown,
                        ),
                      ),
                    ),
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
          }),
          const Divider(color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }
}