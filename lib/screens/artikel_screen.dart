import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'article_detail_screen.dart';

// ── Data Model ────────────────────────────────────────────────────────────────
class ArtikelData {
  final String id;
  final String judul;
  final String penulis;
  final String tanggal;
  final String kategori;
  final String imageUrl;
  final String excerpt;
  final int menit;
  final bool isLiked;

  const ArtikelData({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.tanggal,
    required this.kategori,
    required this.imageUrl,
    required this.excerpt,
    required this.menit,
    this.isLiked = false,
  });
}

const kArtikelList = [
  ArtikelData(
    id: '1',
    judul: 'Ayam Betutu: Puncak Kelezatan Rempah dari Pulau Dewata',
    penulis: 'Budi Santoso',
    tanggal: '23 Mei 2024',
    kategori: 'Sejarah Kuliner',
    imageUrl:
        'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
    excerpt:
        'Hidangan legendaris Bali dengan bumbu rempah yang kaya dan meresap sempurna, menawarkan perpaduan rasa yang tak terlupakan.',
    menit: 8,
    isLiked: true,
  ),
  ArtikelData(
    id: '2',
    judul: 'Rendang: Warisan Kuliner Minangkabau yang Mendunia',
    penulis: 'Sari Dewi',
    tanggal: '20 Mei 2024',
    kategori: 'Budaya & Tradisi',
    imageUrl:
        'https://images.unsplash.com/photo-1574653853027-5382a3d23a15?auto=format&fit=crop&w=800&q=80',
    excerpt:
        'Rendang bukan sekadar masakan—ia adalah simbol ketahanan budaya Minang yang telah diakui UNESCO sebagai Warisan Budaya Tak Benda.',
    menit: 12,
    isLiked: false,
  ),
  ArtikelData(
    id: '3',
    judul: 'Nasi Liwet Solo: Cita Rasa Kerajaan Mataram Islam',
    penulis: 'Ahmad Rizky',
    tanggal: '17 Mei 2024',
    kategori: 'Sejarah Kuliner',
    imageUrl:
        'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80',
    excerpt:
        'Nasi liwet yang gurih dan aromatik ini konon berasal dari dapur Keraton Mataram, menjadi hidangan favorit para raja Jawa.',
    menit: 6,
    isLiked: false,
  ),
  ArtikelData(
    id: '4',
    judul: 'Pempek Palembang: Lebih dari Sekadar Gorengan',
    penulis: 'Rina Lestari',
    tanggal: '14 Mei 2024',
    kategori: 'Jajanan Nusantara',
    imageUrl:
        'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80',
    excerpt:
        'Pempek telah menjadi ikon kuliner Sumatera Selatan selama berabad-abad. Cuko asam manisnya adalah jiwa dari hidangan rakyat ini.',
    menit: 10,
    isLiked: true,
  ),
  ArtikelData(
    id: '5',
    judul: 'Gudeg: Simfoni Rasa Manis dari Tanah Ngayogyakarta',
    penulis: 'Dewi Kusuma',
    tanggal: '11 Mei 2024',
    kategori: 'Sejarah Kuliner',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80',
    excerpt:
        'Nangka muda yang dimasak berjam-jam dalam santan dan gula merah ini bukan hanya makanan, melainkan cerminan filosofi hidup orang Jawa.',
    menit: 7,
    isLiked: false,
  ),
  ArtikelData(
    id: '6',
    judul: 'Soto Betawi: Kuah Santan Kental yang Menghangatkan Jiwa',
    penulis: 'Fajar Nugraha',
    tanggal: '8 Mei 2024',
    kategori: 'Kuliner Kota',
    imageUrl:
        'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=400&q=80',
    excerpt:
        'Di balik kuah santan kental Soto Betawi tersimpan sejarah akulturasi budaya Betawi dengan pengaruh Arab, China, dan Belanda.',
    menit: 9,
    isLiked: false,
  ),
];

const _kategoris = [
  'Semua',
  'Sejarah Kuliner',
  'Budaya & Tradisi',
  'Jajanan Nusantara',
  'Kuliner Kota',
];

// ── Screen ────────────────────────────────────────────────────────────────────
class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  String _selectedKategori = 'Semua';
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _creamBg = Color(0xFFFDFAF7);

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed('/');
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed('/search');
    } else if (index == 2) {
      Navigator.of(context).pushReplacementNamed('/bookmark');
    } else if (index == 3) {
      Navigator.of(context).pushReplacementNamed('/profile');
    }
  }

  List<ArtikelData> get _filteredArtikel {
    if (_selectedKategori == 'Semua') return kArtikelList;
    return kArtikelList
        .where((a) => a.kategori == _selectedKategori)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
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
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildKategoriChips(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildArtikelList(),
              ),
            ),
            KaryaRasaBottomNav(
              currentIndex: _navIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: _creamBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _brown),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Artikel Kuliner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C1A10),
                  ),
                ),
                Text(
                  'Sejarah & Budaya Nusantara',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: const Icon(Icons.search_rounded,
                size: 20, color: _brown),
          ),
        ],
      ),
    );
  }

  // ── Kategori Filter Chips ───────────────────────────────────────────────────
  Widget _buildKategoriChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _kategoris.length,
        itemBuilder: (_, i) {
          final k = _kategoris[i];
          final selected = k == _selectedKategori;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedKategori = k);
              _fadeCtrl.reset();
              _fadeCtrl.forward();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? _terracotta : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      selected ? _terracotta : const Color(0xFFDDDDDD),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _terracotta.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                k,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Article List ────────────────────────────────────────────────────────────
  Widget _buildArtikelList() {
    final list = _filteredArtikel;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'Belum ada artikel',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final artikel = list[index];
        // First article = featured card
        if (index == 0 && _selectedKategori == 'Semua') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FeaturedArtikelCard(
              artikel: artikel,
              onTap: () => _openArtikel(artikel),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ArtikelListCard(
            artikel: artikel,
            onTap: () => _openArtikel(artikel),
          ),
        );
      },
    );
  }

  void _openArtikel(ArtikelData artikel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(artikel: artikel),
      ),
    );
  }
}

// ── Featured Article Card ─────────────────────────────────────────────────────
class _FeaturedArtikelCard extends StatefulWidget {
  final ArtikelData artikel;
  final VoidCallback onTap;

  const _FeaturedArtikelCard({required this.artikel, required this.onTap});

  @override
  State<_FeaturedArtikelCard> createState() => _FeaturedArtikelCardState();
}

class _FeaturedArtikelCardState extends State<_FeaturedArtikelCard> {
  bool _liked = false;

  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);
  static const _brown = Color(0xFF4A2B20);

  @override
  void initState() {
    super.initState();
    _liked = widget.artikel.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                  widget.artikel.imageUrl,
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
              // Like button
              Positioned(
                top: 14,
                right: 14,
                child: GestureDetector(
                  onTap: () => setState(() => _liked = !_liked),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          _liked ? Colors.red : Colors.grey[400],
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
                        widget.artikel.kategori.toUpperCase(),
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
                      widget.artikel.judul,
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
                          widget.artikel.penulis,
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
                          '${widget.artikel.menit} min baca',
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
class _ArtikelListCard extends StatefulWidget {
  final ArtikelData artikel;
  final VoidCallback onTap;

  const _ArtikelListCard({required this.artikel, required this.onTap});

  @override
  State<_ArtikelListCard> createState() => _ArtikelListCardState();
}

class _ArtikelListCardState extends State<_ArtikelListCard> {
  bool _liked = false;

  static const _brown = Color(0xFF4A2B20);
  static const _terracotta = Color(0xFFC6572F);
  static const _gold = Color(0xFFD9AE23);

  @override
  void initState() {
    super.initState();
    _liked = widget.artikel.isLiked;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
                  widget.artikel.imageUrl,
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
                    // Category + Like
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
                            widget.artikel.kategori,
                            style: TextStyle(
                              color: _terracotta,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _liked = !_liked),
                          child: Icon(
                            _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _liked ? Colors.red : Colors.grey[400],
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.artikel.judul,
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
                            widget.artikel.penulis,
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
                          '${widget.artikel.menit} min',
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
