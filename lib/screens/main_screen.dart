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
  
  final List<Widget> _screens = const [
    LiveTVScreen(),
    MoviesScreen(),
    TVShowsScreen(),
    SettingsScreen(),
  ];
  
  final List<String> _titles = [
    AppStrings.liveTV,
    AppStrings.movies,
    AppStrings.tvShows,
    AppStrings.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final connection = contentProvider.currentConnection;
    
    if (connection == null) {
      // If no connection is set, go back to home screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${connection.name} - ${_titles[_currentIndex]}'),
        backgroundColor: AppColors.primaryDark,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
  }
}
