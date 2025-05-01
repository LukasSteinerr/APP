import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../utils/constants.dart';
import 'live_tv_screen.dart';
import 'movies_screen.dart';
import 'tv_shows_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // We'll create screens on demand to ensure they use preloaded data
  late final List<Widget> _screens;

  final List<String> _titles = [
    AppStrings.liveTV,
    AppStrings.movies,
    AppStrings.tvShows,
    AppStrings.settings,
  ];

  @override
  void initState() {
    super.initState();

    final stopwatch = Stopwatch()..start();
    debugPrint('TIMING: MainScreen.initState started');
    debugPrint('MAIN SCREEN: Initializing screens');

    // Initialize screens - use IndexedStack to preserve state
    _screens = [
      const LiveTVScreen(key: PageStorageKey('live_tv')),
      const MoviesScreen(key: PageStorageKey('movies')),
      const TVShowsScreen(key: PageStorageKey('tv_shows')),
      const SettingsScreen(key: PageStorageKey('settings')),
    ];

    debugPrint('MAIN SCREEN: Initialization complete');
    debugPrint(
      'TIMING: MainScreen.initState completed in ${stopwatch.elapsedMilliseconds}ms',
    );
  }

  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();
    debugPrint('TIMING: MainScreen.build started');
    debugPrint('MAIN SCREEN: Building MainScreen');

    final contentProvider = Provider.of<ContentProvider>(context);
    final connection = contentProvider.currentConnection;

    debugPrint(
      'MAIN SCREEN: hasPreloadedData = ${contentProvider.hasPreloadedData}',
    );

    if (connection == null) {
      debugPrint('MAIN SCREEN: No connection set, navigating back');
      // If no connection is set, go back to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    debugPrint('MAIN SCREEN: Building with connection: ${connection.name}');
    debugPrint(
      'TIMING: MainScreen.build content provider access completed in ${stopwatch.elapsedMilliseconds}ms',
    );

    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${connection.name} - ${_titles[_currentIndex]}'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          debugPrint(
            'MAIN SCREEN: Tab tapped - index: $index, current: $_currentIndex',
          );
          // Only update if the index has changed
          if (_currentIndex != index) {
            debugPrint(
              'MAIN SCREEN: Switching to tab $index (${_titles[index]})',
            );
            setState(() {
              _currentIndex = index;
            });
            debugPrint('MAIN SCREEN: Tab switch complete');
          } else {
            debugPrint('MAIN SCREEN: Tab already selected, no change');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(AppIcons.live),
            label: AppStrings.liveTV,
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.movies),
            label: AppStrings.movies,
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.tvShows),
            label: AppStrings.tvShows,
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.settings),
            label: AppStrings.settings,
          ),
        ],
      ),
    );

    debugPrint(
      'TIMING: MainScreen.build completed in ${stopwatch.elapsedMilliseconds}ms',
    );
    return scaffold;
  }
}
