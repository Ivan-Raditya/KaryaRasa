import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/bookmark_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/artikel_screen.dart';
import 'screens/article_detail_screen.dart';
import 'utils/supabase_config.dart';
import 'screens/bagikan_resep_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaryaRasa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC6572F)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/splash',
      routes: {
        '/splash':   (context) => const SplashScreen(),
        '/login':    (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/':         (context) => const HomeScreen(),
        '/profile':  (context) => const ProfileScreen(),
        '/search':   (context) => const SearchScreen(),
        '/bookmark': (context) => const BookmarkScreen(),
        '/artikel':  (context) => const ArtikelScreen(),
        '/bagikan-resep':  (context) => const BagikanResepScreen(), 
      },
    );
  }
}