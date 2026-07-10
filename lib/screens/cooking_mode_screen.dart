import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CookingModeScreen extends StatefulWidget {
  final List<String> langkah;
  
  const CookingModeScreen({super.key, required this.langkah});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2C1A10);

  @override
  void initState() {
    super.initState();
    // Prevent screen from sleeping while cooking
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Re-enable screen sleep when leaving cooking mode
    WakelockPlus.disable();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < widget.langkah.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // Dark mode for cooking
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mode Memasak',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: widget.langkah.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada langkah memasak.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: widget.langkah.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC6572F),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'LANGKAH ${index + 1} DARI ${widget.langkah.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                widget.langkah[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Navigation Controls
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        heroTag: 'prev',
                        onPressed: _currentIndex > 0 ? _prevPage : null,
                        backgroundColor: _currentIndex > 0 ? Colors.white24 : Colors.transparent,
                        elevation: 0,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _currentIndex > 0 ? Colors.white : Colors.white24,
                        ),
                      ),
                      
                      // Progress Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.langkah.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index 
                                ? const Color(0xFFC6572F) 
                                : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      FloatingActionButton(
                        heroTag: 'next',
                        onPressed: _currentIndex < widget.langkah.length - 1 ? _nextPage : null,
                        backgroundColor: _currentIndex < widget.langkah.length - 1 ? const Color(0xFFC6572F) : Colors.transparent,
                        elevation: 0,
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: _currentIndex < widget.langkah.length - 1 ? Colors.white : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
