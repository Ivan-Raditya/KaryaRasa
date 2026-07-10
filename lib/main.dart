import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'screens/kreasi_screen.dart';
import 'screens/racik_screen.dart';
import 'utils/preferences_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await PreferencesManager.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PreferencesManager.instance.themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'KaryaRasa',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFC6572F),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFFDFAF7),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFC6572F),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          initialRoute: '/splash',
          onGenerateRoute: (settings) {
  Widget page;
  switch (settings.name) {
    case '/splash':   page = const SplashScreen(); break;
    case '/login':    page = const LoginScreen(); break;
    case '/register': page = const RegisterScreen(); break;
    case '/':         page = const HomeScreen(); break;
    case '/profile':  page = const ProfileScreen(); break;
    case '/search':   page = const SearchScreen(); break;
    case '/bookmark': page = const BookmarkScreen(); break;
    case '/artikel':  page = const ArtikelScreen(); break;
    case '/kreasi':   page = const KreasiScreen(); break;
    case '/racik':    page = const RacikScreen(); break;
    default:          page = const HomeScreen();
  }
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
},
        );
      },
    );
  }
}