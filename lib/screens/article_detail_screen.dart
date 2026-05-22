import 'package:flutter/material.dart';
import '../models/artikel.dart';
import '../database/database.dart';
import '../models/simpan_artikel.dart';
import '../utils/session_manager.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Artikel artikel;

  const ArticleDetailScreen({super.key, required this.artikel});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _saved = false;
  late AnimationController _heroCtrl;
  late Animation<double> _heroFade;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFDFAF7);
  static const _darkBrown = Color(0xFF2C1A10);

  List<Artikel> _related = [];

  Future<void> _loadRelated() async {
    try {
      final all = await Database().getAllArtikel();
      if (mounted) {
        setState(() {
          _related = all
              .where((a) => a.idArtikel != widget.artikel.idArtikel)
              .take(3)
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _saved = widget.artikel.isSaved;
    _loadRelated();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleSave() async {
    final idPengguna = SessionManager.instance.idPengguna;
    final idArtikel = widget.artikel.idArtikel;
    if (idPengguna == null || idArtikel == null) {
      setState(() => _saved = !_saved);
      return;
    }
    final db = Database();
    if (_saved) {
      await db.hapusSimpanArtikel(idPengguna, idArtikel);
    } else {
      await db.simpanArtikel(SimpanArtikel(
        idPengguna: idPengguna,
        idArtikel: idArtikel,
        tglDisimpan: DateTime.now().toIso8601String(),
      ));
    }
    setState(() {
      _saved = !_saved;
      widget.artikel.isSaved = _saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildOpeningQuote(),
                    _buildSection(),
                    _buildInlineImageSection(),
                    _buildBlockQuote(),
                    _buildBodyText(),
                    _buildCallout(),
                    _buildRelatedArticles(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
          _buildFloatingActions(),
        ],
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _creamBg,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _brown, size: 16),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _toggleSave,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _saved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: _saved ? _terracotta : _brown,
              size: 18,
            ),
          ),
        ),
      ],
      title: const Text(
        'KARYARASA',
        style: TextStyle(
          color: _brown,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          fontStyle: FontStyle.italic,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _heroFade,
          child: Image.network(
            widget.artikel.fotoArtikel ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: _brown),
          ),
        ),
      ),
    );
  }

  // ── Article Header ──────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'OLEH ${widget.artikel.penulis.toUpperCase()}',
                style: const TextStyle(
                  color: _terracotta,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Text('  •  ', style: TextStyle(color: Colors.grey)),
              Text(
                widget.artikel.tglDibuat,
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
              const Text('  •  ', style: TextStyle(color: Colors.grey)),
              Text(
                widget.artikel.kategori.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.artikel.judulArtikel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: _darkBrown,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDE6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: _brown),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.artikel.menitBaca} min baca',
                      style: const TextStyle(
                          fontSize: 11,
                          color: _brown,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share_outlined, size: 13, color: _gold),
                    const SizedBox(width: 4),
                    Text(
                      'Bagikan',
                      style: TextStyle(
                          fontSize: 11,
                          color: _gold,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  // ── Opening Quote ───────────────────────────────────────────────────────────
  Widget _buildOpeningQuote() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: _terracotta, width: 4),
          ),
        ),
        child: Text(
          '"${widget.artikel.excerpt}"',
          style: const TextStyle(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: _darkBrown,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  // ── Main Section ────────────────────────────────────────────────────────────
  Widget _buildSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                color: _terracotta,
                margin: const EdgeInsets.only(right: 10),
              ),
              const Text(
                'Ritual Rasa dari Bali',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'RAHASIA BASE GENEP',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Keunikan Ayam Betutu terletak pada proses pembuatannya yang sangat detail. Ayam dibuat dengan bumbu base genep—campuran komprehensif dari 15 jenis rempah termasuk kencur, jahe, kunyit, dan cabai yang diulek kasar. Proses memasaknya pun bukan sembarang masak; ayam dipijat perlahan agar bumbu meresap hingga ke tulang sebelum dimasak berjam-jam.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }

  // ── Inline Image ────────────────────────────────────────────────────────────
  Widget _buildInlineImageSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Secara tradisional, proses pemanggangan dilakukan di dalam sekam padi panas, menciptakan aroma smoky yang khas yang tidak bisa didapatkan dari teknik modern. Setiap gigitannya menceritakan sejarah panjang masyarakat agraris Bali yang menghargai waktu dan kesabaran dalam mengolah hasil bumi.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.75,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  'https://images.unsplash.com/photo-1606914501449-5a96b6ce24ca?auto=format&fit=crop&w=300&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: _brown.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Block Quote ─────────────────────────────────────────────────────────────
  Widget _buildBlockQuote() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _brown,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Icon(Icons.format_quote_rounded, color: _gold, size: 32),
            SizedBox(height: 8),
            Text(
              '"Ayam Betutu adalah simfoni rasa, perwujudan sejati dari kekayaan bumbu \'base genep\' yang tak tertandingi."',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body Text ───────────────────────────────────────────────────────────────
  Widget _buildBodyText() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Text(
        'Secara tradisional, proses pemanggangan dilakukan di dalam sekam padi panas, menciptakan aroma smoky yang khas yang tidak bisa didapatkan dari teknik modern. Setelah diungkep, ayam dipijat perlahan agar bumbu meresap hingga ke tulang sebelum dimasak berjam-jam.',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF555555),
          height: 1.75,
        ),
      ),
    );
  }

  // ── Callout ─────────────────────────────────────────────────────────────────
  Widget _buildCallout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _terracotta.withValues(alpha: 0.12),
              _gold.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _terracotta.withValues(alpha: 0.2),
          ),
        ),
        child: const Text(
          'Bukan sekadar hidangan, Ayam Betutu adalah pengalaman kuliner mendalam dan ikon Bali yang tak boleh dilewatkan.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _darkBrown,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Related Articles ────────────────────────────────────────────────────────
  Widget _buildRelatedArticles() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          const Text(
            'Artikel Terkait',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _darkBrown,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _related.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final rel = _related[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(artikel: rel),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 110,
                            width: 150,
                            child: Image.network(
                             rel.fotoArtikel ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: _brown.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rel.judulArtikel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _darkBrown,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 11, color: Colors.grey[400]),
                            const SizedBox(width: 3),
                            Text(
                             '± ${rel.menitBaca} min',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Floating Actions Bar ────────────────────────────────────────────────────
  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
            // Simpan
            GestureDetector(
              onTap: _toggleSave,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _saved
                      ? _terracotta.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _saved
                        ? _terracotta.withValues(alpha: 0.3)
                        : const Color(0xFFEEEEEE),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _saved ? _terracotta : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _saved ? 'Tersimpan' : 'Simpan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _saved ? _terracotta : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Bagikan
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _terracotta,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Bagikan Artikel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
}