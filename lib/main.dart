import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const KaryaRasaApp());
}

class KaryaRasaApp extends StatelessWidget {
  const KaryaRasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaryaRasa',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brown),
        fontFamily: 'Georgia',
      ),
      home: const KaryaRasaShell(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
      },
    );
  }
}

class AppColors {
  static const background = Color(0xFFF8F7F6);
  static const brown = Color(0xFF6E473C);
  static const terracotta = Color(0xFFC6572F);
  static const olive = Color(0xFF91A365);
  static const cream = Color(0xFFFFF8EA);
  static const gold = Color(0xFFD9AE23);
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF8390A6);
}

class KaryaRasaShell extends StatefulWidget {
  const KaryaRasaShell({super.key});

  @override
  State<KaryaRasaShell> createState() => _KaryaRasaShellState();
}

class _KaryaRasaShellState extends State<KaryaRasaShell> {
  final PageController _pageController = PageController();
  int selectedIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openPage(int value) {
    setState(() => selectedIndex = value);
    _pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) => setState(() => selectedIndex = value),
        children: const [
          HomeScreen(),
          SearchScreen(),
          _SimpleScreen(title: 'Simpan', icon: Icons.bookmark_border_rounded),
          _SimpleScreen(title: 'Profil', icon: Icons.person_outline_rounded),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: selectedIndex,
        onChanged: _openPage,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _TopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18),
                      _HeroRecipeCard(),
                      SizedBox(height: 34),
                      _QuickExploreSection(),
                      SizedBox(height: 38),
                      _RecommendationSection(),
                      SizedBox(height: 40),
                      _HistorySection(),
                      SizedBox(height: 28),
                    ],
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

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Color(0xE6F8F7F6),
        border: Border(bottom: BorderSide(color: Color(0x1AD5B534))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      child: Row(
        children: [
          const Text(
            'KaryaRasa',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.only(left: 12, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, size: 15, color: AppColors.muted),
                  SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      'Cari resep...',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/login'),
            child: Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x33D5B534), width: 2),
              ),
              child: Image.asset(
                'assets/images/figma_home_avatar.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroRecipeCard extends StatelessWidget {
  const _HeroRecipeCard();

  static const heroImage = 'assets/images/figma_home_hero.png';
  static const sideImageOne = 'assets/images/figma_home_bubble1.png';
  static const sideImageTwo = 'assets/images/figma_home_bubble2.png';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: SizedBox(
        height: 447.5,
        width: 358,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(48),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _NetworkFoodImage(url: heroImage),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.74),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 28,
                right: 30,
                bottom: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UNGGULAN NUSANTARA',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        fontFamily: 'Arial',
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Selamat Datang!\nTemukan Jiwa Kuliner\nNusantara',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 31,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Resep Hari Ini: ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Rendang Minang (Sumatera Barat)',
                            style: TextStyle(color: AppColors.gold),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.22,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 25,
                top: 14,
                child: Column(
                  children: [
                    _SmallFoodBubble(url: sideImageOne),
                    SizedBox(height: 3),
                    _SmallFoodBubble(url: sideImageTwo),
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

class _QuickExploreSection extends StatelessWidget {
  const _QuickExploreSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Warisan Rasa'),
                SizedBox(height: 16),
                _CategoryPill(
                  title: 'Makanan',
                  color: AppColors.brown,
                  textColor: Colors.white,
                  imageUrl:
                      'assets/images/figma_home_food.png',
                ),
                SizedBox(height: 12),
                _CategoryPill(
                  title: 'Jajanan',
                  color: AppColors.olive,
                  textColor: Colors.white,
                  imageUrl:
                      'assets/images/figma_home_snack.png',
                ),
                SizedBox(height: 12),
                _CategoryPill(
                  title: 'Minuman',
                  color: AppColors.cream,
                  textColor: AppColors.brown,
                  borderColor: Color(0xFFF5DFA8),
                  imageUrl:
                      'assets/images/figma_home_drink.png',
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SectionTitle('Jelajahi Daerah'),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RegionButton(
                        label: 'SUMATERA',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _RegionButton(
                        label: 'JAWA',
                        icon: Icons.temple_hindu,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _RegionButton(
                        label: 'BALI/NT',
                        icon: Icons.festival,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _RegionButton(
                        label: 'SULAWESI',
                        icon: Icons.castle,
                      ),
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

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.title,
    required this.color,
    required this.textColor,
    required this.imageUrl,
    this.borderColor,
  });

  final String title;
  final Color color;
  final Color textColor;
  final String imageUrl;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(34),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      padding: const EdgeInsets.only(left: 12, right: 18),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: _NetworkFoodImage(url: imageUrl),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionButton extends StatelessWidget {
  const _RegionButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6E7B93),
                fontFamily: 'Arial',
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 76, right: 38),
          child: Row(
            children: [
              const Expanded(
                child: _SectionTitle('Rekomendasi Minggu Ini', size: 25),
              ),
              _CircleIconButton(icon: Icons.chevron_left_rounded, onTap: () {}),
              const SizedBox(width: 10),
              _CircleIconButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            width: 270,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(42),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: const [
                      SizedBox(
                        height: 158,
                        width: double.infinity,
                        child: _NetworkFoodImage(
                          url: 'assets/images/figma_home_reco.png',
                        ),
                      ),
                      Positioned(right: 14, top: 14, child: _LikeButton()),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 20, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gudeg Jogja Istimewa',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontFamily: 'Arial',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        _RatingRow(),
                        SizedBox(height: 12),
                        Text(
                          'Nangka muda manis yang dimasak perlahan dengan santan kental khas Yogyakarta.',
                          style: TextStyle(
                            color: Color(0xFF6E7B93),
                            fontFamily: 'Arial',
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Belajar Sejarah Kuliner', size: 25),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 186,
              color: AppColors.brown,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 24, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ayam Betutu',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontFamily: 'Arial',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 18),
                          Expanded(
                            child: Text(
                              'Asal-usul bumbu Base Genep yang dibawa oleh pemuka agama ke pulau Dewata.',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Arial',
                                fontSize: 14,
                                height: 1.55,
                              ),
                            ),
                          ),
                          Text(
                            'BACA SELENGKAPNYA >',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: const Color(0xFFA39E91)),
                        Positioned(
                          right: -40,
                          top: -70,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0x55725B37),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(
                            Icons.face_3_rounded,
                            color: Color(0xFF393431),
                            size: 76,
                          ),
                        ),
                      ],
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
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const categories = [
    _ImageTileData('Hidangan Utama', 'assets/images/figma_cat_hidangan.png'),
    _ImageTileData('Jajanan Pasar', 'assets/images/figma_cat_jajanan.png'),
    _ImageTileData(
      'Minuman Tradisional',
      'assets/images/figma_cat_minuman.png',
    ),
    _ImageTileData('Gulai & Kari', 'assets/images/figma_cat_gulai.png'),
    _ImageTileData('Nasi & Sambal', 'assets/images/figma_cat_nasi.png'),
    _ImageTileData('Kudapan Sore', 'assets/images/figma_cat_kudapan.png'),
  ];

  static const regions = [
    _ImageTileData('Sumatera', 'assets/images/figma_cat_hidangan.png'),
    _ImageTileData('Jawa', 'assets/images/figma_cat_jajanan.png'),
    _ImageTileData('Bali', 'assets/images/figma_bali.png'),
    _ImageTileData('Sulawesi', 'assets/images/figma_cat_gulai.png'),
    _ImageTileData('Papua', 'assets/images/figma_cat_kudapan.png'),
  ];

  static const results = [
    _RecipeCardData(
      title: 'Sate Lilit Ikan Bali',
      description:
          'Sate khas Bali dengan rempah melimpah di atas batang serai.',
      time: '12 min',
      rating: '4.9',
      imageUrl: 'assets/images/figma_bali.png',
    ),
    _RecipeCardData(
      title: 'Pempek Lenggang',
      description: 'Pempek dipanggang dengan balutan telur kocok gurih.',
      time: '15 min',
      rating: '4.7',
      imageUrl: 'assets/images/figma_pempek.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFFDFAF6)),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _FigmaSearchHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SearchSectionHeader(
                          title: 'Kategori Populer',
                          action: 'Lihat Semua',
                        ),
                        SizedBox(height: 18),
                        _PopularCategoryGrid(),
                        SizedBox(height: 34),
                        _SearchTitle('Tren Pencarian Terpopuler'),
                        SizedBox(height: 18),
                        _TrendChips(),
                        SizedBox(height: 34),
                        _SearchTitle('Jelajah Per Daerah'),
                        SizedBox(height: 20),
                        _RegionTabs(),
                        SizedBox(height: 20),
                        _RegionalScroller(),
                        SizedBox(height: 38),
                        _SearchTitle('Hasil Pencarian Terkait'),
                        SizedBox(height: 18),
                        _SearchResultsGrid(),
                      ],
                    ),
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

class _FigmaSearchHeader extends StatelessWidget {
  const _FigmaSearchHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFAF6).withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0x0DE61919), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 233.55,
            height: 40,
            child: Image.asset(
              'assets/images/figma_search_logo.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                ),
                const Positioned(
                  left: 12,
                  top: 14,
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5C2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE6D5A7)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF8D7A4D),
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSectionHeader extends StatelessWidget {
  const _SearchSectionHeader({required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SearchTitle(title)),
        Text(
          action,
          style: const TextStyle(
            fontFamily: 'Arial',
            color: Color(0xFFE61919),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SearchTitle extends StatelessWidget {
  const _SearchTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Arial',
        color: Color(0xFF1E293B),
        fontSize: 18,
        height: 1.55,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PopularCategoryGrid extends StatelessWidget {
  const _PopularCategoryGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: SearchScreen.categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 182 / 128,
      ),
      itemBuilder: (context, index) {
        final item = SearchScreen.categories[index];
        return _ImageOverlayCard(
          title: item.title,
          imageUrl: item.imageUrl,
          radius: 24,
          trailing: const Icon(
            Icons.favorite_border_rounded,
            color: Colors.white,
            size: 24,
          ),
        );
      },
    );
  }
}

class _TrendChips extends StatelessWidget {
  const _TrendChips();

  @override
  Widget build(BuildContext context) {
    final trends = [
      'Rendang Minang',
      'Sate Madura',
      'Kerak Telor',
      'Ayam Betutu',
      'Gudeg',
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trends.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.brown.withValues(alpha: 0.20),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              trends[index],
              style: const TextStyle(
                fontFamily: 'Arial',
                color: AppColors.brown,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RegionTabs extends StatelessWidget {
  const _RegionTabs();

  @override
  Widget build(BuildContext context) {
    final tabs = ['Makanan', 'Minuman', 'Camilan'];

    return Container(
      height: 31,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 22),
            padding: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(
              border: active
                  ? const Border(
                      bottom: BorderSide(color: Color(0xFFE61919), width: 2),
                    )
                  : null,
            ),
            child: Text(
              tabs[index],
              style: TextStyle(
                fontFamily: 'Arial',
                color: active ? const Color(0xFFE61919) : AppColors.muted,
                fontSize: 14,
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _RegionalScroller extends StatelessWidget {
  const _RegionalScroller();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 184,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SearchScreen.regions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = SearchScreen.regions[index];
          return SizedBox(
            width: 128,
            height: 160,
            child: _ImageOverlayCard(
              title: item.title,
              imageUrl: item.imageUrl,
              radius: 16,
              alignTitleBottom: 12,
            ),
          );
        },
      ),
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  const _SearchResultsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: SearchScreen.results.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 180 / 282,
      ),
      itemBuilder: (context, index) {
        return _SearchRecipeCard(data: SearchScreen.results[index]);
      },
    );
  }
}

class _SearchRecipeCard extends StatelessWidget {
  const _SearchRecipeCard({required this.data});

  final _RecipeCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _NetworkFoodImage(url: data.imageUrl),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    height: 25,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFEAB308),
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          data.rating,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: Color(0xFF0F172A),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      data.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: Color(0xFF64748B),
                        fontSize: 10,
                        height: 1.6,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFFE61919),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data.time,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: Color(0xFFE61919),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

class _ImageOverlayCard extends StatelessWidget {
  const _ImageOverlayCard({
    required this.title,
    required this.imageUrl,
    required this.radius,
    this.trailing,
    this.alignTitleBottom = 8,
  });

  final String title;
  final String imageUrl;
  final double radius;
  final Widget? trailing;
  final double alignTitleBottom;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _NetworkFoodImage(url: imageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.02),
                  Colors.black.withValues(alpha: 0.70),
                ],
              ),
            ),
          ),
          if (trailing != null) Positioned(right: 8, top: 8, child: trailing!),
          Positioned(
            left: 12,
            right: 10,
            bottom: alignTitleBottom,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Arial',
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.muted, size: 44),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Arial',
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTileData {
  const _ImageTileData(this.title, this.imageUrl);

  final String title;
  final String imageUrl;
}

class _RecipeCardData {
  const _RecipeCardData({
    required this.title,
    required this.description,
    required this.time,
    required this.rating,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String time;
  final String rating;
  final String imageUrl;
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_rounded, 'Beranda'),
      _NavItem(Icons.explore_outlined, 'Jelajah'),
      _NavItem(Icons.bookmark_border_rounded, 'Simpan'),
      _NavItem(Icons.person_outline_rounded, 'Profil'),
    ];

    return Container(
      height: 66,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECEEF4))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final active = selectedIndex == index;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onChanged(index),
            child: SizedBox(
              width: 52,
              height: 50,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      color: active
                          ? const Color(0xFFA54B2D)
                          : const Color(0xFF94A3B8),
                      size: index == 1 ? 20 : 18,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: active
                            ? const Color(0xFFA54B2D)
                            : const Color(0xFF94A3B8),
                        fontFamily: 'Arial',
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  _NavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.size = 22});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: AppColors.brown,
          fontSize: size,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: AppColors.gold, size: 21),
        ),
      ),
    );
  }
}

class _SmallFoodBubble extends StatelessWidget {
  const _SmallFoodBubble({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: _NetworkFoodImage(url: url),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite_rounded,
        color: Color(0xFFF04F57),
        size: 20,
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.star_rounded, color: AppColors.gold, size: 17),
        Icon(Icons.star_rounded, color: AppColors.gold, size: 17),
        Icon(Icons.star_rounded, color: AppColors.gold, size: 17),
        Icon(Icons.star_rounded, color: AppColors.gold, size: 17),
        Icon(Icons.star_half_rounded, color: AppColors.gold, size: 17),
        SizedBox(width: 6),
        Text(
          '(4.9)',
          style: TextStyle(
            color: AppColors.muted,
            fontFamily: 'Arial',
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _NetworkFoodImage extends StatelessWidget {
  const _NetworkFoodImage({required this.url});

  final String url;

  static const _assetByUrl = {
    'https://images.unsplash.com/photo-1604908176997-43165204d9f7?auto=format&fit=crop&w=900&q=85':
        'assets/images/hero_rendang.jpg',
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=300&q=80':
        'assets/images/bubble_food_1.jpg',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=300&q=80':
        'assets/images/bubble_food_2.jpg',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=220&q=80':
        'assets/images/category_makanan.jpg',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=220&q=80':
        'assets/images/category_jajanan.jpg',
    'https://images.unsplash.com/photo-1497534446932-c925b458314e?auto=format&fit=crop&w=220&q=80':
        'assets/images/category_minuman.jpg',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=700&q=85':
        'assets/images/category_makanan.jpg',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=600&q=85':
        'assets/images/category_makanan.jpg',
    'https://images.unsplash.com/photo-1497534446932-c925b458314e?auto=format&fit=crop&w=600&q=85':
        'assets/images/drink.jpg',
    'https://images.unsplash.com/photo-1565299507177-b0ac66763828?auto=format&fit=crop&w=600&q=85':
        'assets/images/curry.jpg',
    'https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=600&q=85':
        'assets/images/dessert.jpg',
    'https://images.unsplash.com/photo-1604908176997-43165204d9f7?auto=format&fit=crop&w=500&q=85':
        'assets/images/hero_rendang.jpg',
    'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=500&q=85':
        'assets/images/category_makanan.jpg',
    'https://images.unsplash.com/photo-1529563021893-cc83c992d75d?auto=format&fit=crop&w=500&q=85':
        'assets/images/sate.jpg',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=500&q=85':
        'assets/images/category_jajanan.jpg',
    'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=500&q=85':
        'assets/images/pempek.jpg',
    'https://images.unsplash.com/photo-1529563021893-cc83c992d75d?auto=format&fit=crop&w=600&q=85':
        'assets/images/sate.jpg',
    'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=600&q=85':
        'assets/images/pempek.jpg',
  };

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(url, fit: BoxFit.cover);
    }

    final asset = _assetByUrl[url];
    if (asset != null) {
      return Image.asset(asset, fit: BoxFit.cover);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2C312E), Color(0xFF7C574A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.white70,
              size: 42,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFECE8E2),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}
