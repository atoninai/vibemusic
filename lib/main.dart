import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/music_provider.dart';
import 'screens/home_screen.dart';
import 'screens/library_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/permission_screen.dart';
import 'services/permission_service.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/mini_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const VibelandApp());
}

class VibelandApp extends StatelessWidget {
  const VibelandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MusicProvider(),
      child: MaterialApp(
        title: 'Vibeland',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _permissionsGranted = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permService = PermissionService();
    final hasStorage = await permService.hasStoragePermission();
    setState(() {
      _permissionsGranted = hasStorage;
      _checking = false;
    });

    if (_permissionsGranted) {
      _loadMusic();
    }
  }

  void _loadMusic() {
    final provider = Provider.of<MusicProvider>(context, listen: false);
    provider.loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (!_permissionsGranted) {
      return PermissionScreen(
        onComplete: () {
          setState(() => _permissionsGranted = true);
          _loadMusic();
        },
      );
    }

    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Current screen
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            // Mini Player (floating above bottom nav)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: const MiniPlayer(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
