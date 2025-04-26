import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../utils/constants.dart';
import 'live_tv_screen.dart';
import 'movies_screen.dart';
import 'tv_shows_screen.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        title: Text(connection.name),
        backgroundColor: AppColors.primaryDark,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(
              icon: Icon(AppIcons.live),
              text: AppStrings.liveTV,
            ),
            Tab(
              icon: Icon(AppIcons.movies),
              text: AppStrings.movies,
            ),
            Tab(
              icon: Icon(AppIcons.tvShows),
              text: AppStrings.tvShows,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiveTVScreen(),
          MoviesScreen(),
          TVShowsScreen(),
        ],
      ),
    );
  }
}
