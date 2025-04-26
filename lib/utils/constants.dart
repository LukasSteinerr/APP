import 'package:flutter/material.dart';

// App Theme Colors
class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color accent = Color(0xFFFF9800);
  static const Color background = Color(0xFF121212);
  static const Color card = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFF323232);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color error = Color(0xFFCF6679);
}

// App Text Styles
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.text,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );
}

// App Paddings
class AppPaddings {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;
}

// App Border Radius
class AppBorderRadius {
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 16.0;
  static const double extraLarge = 24.0;
}

// App Icons
class AppIcons {
  static const IconData live = Icons.live_tv;
  static const IconData movies = Icons.movie;
  static const IconData tvShows = Icons.tv;
  static const IconData settings = Icons.settings;
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData play = Icons.play_arrow;
  static const IconData pause = Icons.pause;
  static const IconData fullscreen = Icons.fullscreen;
  static const IconData back = Icons.arrow_back;
  static const IconData search = Icons.search;
  static const IconData favorite = Icons.favorite;
  static const IconData favoriteOutline = Icons.favorite_border;
}

// App Routes
class AppRoutes {
  static const String home = '/';
  static const String addConnection = '/add-connection';
  static const String editConnection = '/edit-connection';
  static const String liveTV = '/live-tv';
  static const String liveTVPlayer = '/live-tv-player';
  static const String movies = '/movies';
  static const String movieDetails = '/movie-details';
  static const String moviePlayer = '/movie-player';
  static const String tvShows = '/tv-shows';
  static const String seriesDetails = '/series-details';
  static const String episodePlayer = '/episode-player';
  static const String settings = '/settings';
}

// App Strings
class AppStrings {
  static const String appName = 'Xtream IPTV Pro';
  static const String liveTV = 'Live TV';
  static const String movies = 'Movies';
  static const String tvShows = 'TV Shows';
  static const String settings = 'Settings';
  static const String addConnection = 'Add Connection';
  static const String editConnection = 'Edit Connection';
  static const String connectionName = 'Connection Name';
  static const String serverUrl = 'Server URL';
  static const String username = 'Username';
  static const String password = 'Password';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String noConnections = 'No Connections';
  static const String addConnectionMessage = 'Add an Xtream connection to get started';
  static const String errorLoadingContent = 'Error loading content';
  static const String retry = 'Retry';
  static const String search = 'Search';
  static const String noResults = 'No Results';
  static const String allCategories = 'All Categories';
  static const String loading = 'Loading...';
  static const String connectionError = 'Connection Error';
  static const String connectionErrorMessage = 'Failed to connect to server. Please check your connection details and try again.';
}
