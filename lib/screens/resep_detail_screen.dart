import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'cooking_mode_screen.dart';
import '../data/resep_data.dart';
import '../database/database.dart';
import '../models/bookmark.dart';
import '../models/koleksi_bookmark.dart';
import '../models/komentar.dart';
import '../models/langkah_masak.dart';
import '../utils/session_manager.dart';
import '../models/like_resep.dart';

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
  bool _liked = false;
int _likeCount = 0;
int _bookmarkCount = 0;

  List<LangkahMasak> _langkahList = [];
  bool _langkahLoading = true;

  final _komentarController = TextEditingController();
  int _komentarRating = 5;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _creamBg = Color(0xFFFDFAF7);
  static const _darkBrown = Color(0xFF2C1A10);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF1E1E1E) : _creamBg;
  Color get cardColor => isDark ? const Color(0xFF2C2C2C) : Colors.white;
  Color get textColor => isDark ? Colors.white : _darkBrown;
  Color get secondaryTextColor => isDark ? Colors.grey[400]! : Colors.grey[600]!;
  Color get shimmerBase => isDark ? Colors.grey[800]! : Colors.grey[300]!;
  Color get shimmerHighlight => isDark ? Colors.grey[700]! : Colors.grey[100]!;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.resep.isBookmarked;
    _loadLangkah();
    _loadLikeState();
  }

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
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
  Future<void> _loadLikeState() async {
  final idPengguna = SessionManager.instance.idPengguna;
  final idResep = int.tryParse(widget.resep.id);
  if (idResep == null) return;
  final db = Database();
  final liked = idPengguna != null
      ? await db.isResepDilike(idResep, idPengguna)
      : false;
  final likeCount     = await db.getLikeCount(idResep);
  final bookmarkCount = await db.getBookmarkCount(idResep);
  if (!mounted) return;
  setState(() {
    _liked         = liked;
    _likeCount     = likeCount;
    _bookmarkCount = bookmarkCount;
  });
}

Future<void> _toggleLike() async {
  final idPengguna = SessionManager.instance.idPengguna;
  final idResep    = int.tryParse(widget.resep.id);
  if (idPengguna == null || idResep == null) return;
  final db = Database();
  if (_liked) {
    await db.deleteLike(idResep, idPengguna);
    setState(() { _liked = false; _likeCount--; });
  } else {
    await db.insertLike(LikeResep(
      idResep: idResep,
      idPengguna: idPengguna,
      tglLike: DateTime.now().toIso8601String(),
    ));
    setState(() { _liked = true; _likeCount++; });
  }
}



Future<void> _postKomentar() async {
  final isi = _komentarController.text.trim();
  if (isi.isEmpty) return;

  final idPengguna = SessionManager.instance.idPengguna;
  final idResep = int.tryParse(widget.resep.id);

  if (idPengguna == null || idResep == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan login untuk berkomentar')),
    );
    return;
  }

  final komentar = Komentar(
    idResep: idResep,
    idPengguna: idPengguna,
    isiKomentar: isi,
    skorRating: _komentarRating,
  );

  try {
    await Database().insertKomentar(komentar);
    _komentarController.clear();
    setState(() => _komentarRating = 5);
    FocusScope.of(context).unfocus(); // dismiss keyboard
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim komentar: $e')),
      );
    }
  }
}

  void _showEditKomentarDialog(Komentar komentar) {
    if (komentar.idKomentar == null) return;
    
    final editController = TextEditingController(text: komentar.isiKomentar);
    int editRating = komentar.skorRating;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Edit Komentar', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setStateDialog(() => editRating = index + 1),
                        child: Icon(
                          index < editRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: editController,
                    maxLines: 3,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Tulis komentar...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _terracotta, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newIsi = editController.text.trim();
                    if (newIsi.isNotEmpty) {
                      try {
                        await Database().updateKomentar(komentar.idKomentar!, newIsi, editRating);
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal mengubah komentar: $e')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _terracotta,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteKomentarDialog(Komentar komentar) {
    if (komentar.idKomentar == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Komentar', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus komentar ini?', style: TextStyle(color: secondaryTextColor, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Database().deleteKomentar(komentar.idKomentar!);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus komentar: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
                      _buildAlatMasakSection(),
                      _buildLangkahSlider(),
                      _buildBahanSection(),
                      _buildKomentarSection(),
                      const SizedBox(height: 100), // Spasi ekstra untuk Floating Button
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Top App Bar (floating) ─────────────────────────────────
          _buildTopBar(),
          // ── Mulai Memasak Button (floating bottom) ─────────────────
          _buildMulaiMemasakButton(),
        ],
      ),
    );
  }

  Widget _buildMulaiMemasakButton() {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          if (widget.resep.langkah.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tidak ada langkah memasak.')),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CookingModeScreen(langkah: widget.resep.langkah),
            ),
          );
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: _terracotta,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: _terracotta.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Mulai Memasak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
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
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: shimmerBase,
                highlightColor: shimmerHighlight,
                child: Container(color: cardColor),
              ),
              errorWidget: (context, url, error) => Container(color: _brown),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(19),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8)
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.resep.nama,
                    style: const TextStyle(
                      color: _brown,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textColor,
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
          Row(
  children: [
    GestureDetector(
      onTap: _toggleLike,
      child: Row(
        children: [
          Icon(
            _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _liked ? Colors.red : _brown,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '$_likeCount',
            style: const TextStyle(fontSize: 13, color: _brown),
          ),
        ],
      ),
    ),
    const SizedBox(width: 16),
    Row(
      children: [
        Icon(Icons.bookmark_border_rounded, color: _brown, size: 20),
        const SizedBox(width: 4),
        Text(
          '$_bookmarkCount',
          style: const TextStyle(fontSize: 13, color: _brown),
        ),
      ],
    ),
  ],
),
const SizedBox(height: 16),
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
          Text(
            'Sejarah Singkat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
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

  // ── Alat Masak Section ───────────────────────────────────────────────────────
  Widget _buildAlatMasakSection() {
    if (widget.resep.alatMasak.isEmpty) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alat Masak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.resep.alatMasak.map((alat) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.kitchen_outlined, size: 16, color: _terracotta),
                    const SizedBox(width: 6),
                    Text(
                      alat,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Langkah Memasak',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
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
        color: cardColor,
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
                ? CachedNetworkImage(
                    imageUrl: langkah.fotoLangkah!,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: cardColor, height: 110),
                    ),
                    errorWidget: (context, url, error) => _langkahFotoPlaceholder(),
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
                      style: TextStyle(
                        color: cardColor,
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
          Text(
            'Bahan-Bahan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.resep.bahanSections.map((section) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textColor,
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

  // ── Komentar Section ─────────────────────────────────────────────────────────
  Widget _buildKomentarSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komentar & Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          // Bintang Rating
          Row(
            children: [
              Text('Berikan Rating:', style: TextStyle(fontSize: 13, color: textColor, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _komentarRating = index + 1),
                    child: Icon(
                      index < _komentarRating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Input Komentar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _komentarController,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: _terracotta, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _postKomentar,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: _terracotta,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: cardColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // List Komentar (Real-time Stream)
          StreamBuilder<List<Komentar>>(
            stream: Database().getKomentarStream(int.tryParse(widget.resep.id) ?? 0),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _terracotta));
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Gagal memuat komentar'));
              }

              final kList = snapshot.data ?? [];
              
              if (kList.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Belum ada komentar.\nJadilah yang pertama berkomentar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: kList.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Color(0xFFEEEEEE), height: 1),
                ),
                itemBuilder: (ctx, i) {
                  final k = kList[i];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFF3EDE6),
                        child: k.fotoProfile == null || k.fotoProfile!.isEmpty
                            ? const Icon(Icons.person, color: _brown, size: 20)
                            : null,
                        backgroundImage: k.fotoProfile != null && k.fotoProfile!.isNotEmpty
                            ? CachedNetworkImageProvider(k.fotoProfile!)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Konten
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    k.namaPengguna ?? 'Pengguna',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < k.skorRating ? Icons.star_rounded : Icons.star_border_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    );
                                  }),
                                ),
                                if (k.idPengguna == SessionManager.instance.idPengguna)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, size: 16, color: Colors.grey),
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        height: 32,
                                        child: Text('Edit', style: TextStyle(fontSize: 12)),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        height: 32,
                                        child: Text('Hapus', style: TextStyle(fontSize: 12, color: Colors.red)),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditKomentarDialog(k);
                                      } else if (value == 'delete') {
                                        _showDeleteKomentarDialog(k);
                                      }
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              k.isiKomentar,
                              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}