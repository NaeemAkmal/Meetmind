import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/video_call_screen.dart';
import 'screens/ai_features_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/app_state.dart';
import 'providers/chat_provider.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skip database on web for now, will implement Firebase later
  if (!kIsWeb) {
    try {
      await DatabaseService().initDatabase();
    } catch (e) {
      print('Database initialization failed: $e');
    }
  }

  runApp(const MeetMindApp());
}

class MeetMindApp extends StatelessWidget {
  const MeetMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'MeetMind',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C63FF),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/chat': (context) => const ChatScreen(),
          '/video-call': (context) => const VideoCallScreen(),
          '/ai-features': (context) => const AIFeaturesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
        },
      ),
    );
  }
}
