import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/xtream_connection.dart';
import '../providers/connections_provider.dart';
import '../providers/content_provider.dart';
import '../utils/constants.dart';
import '../widgets/connection_card.dart';
import '../widgets/error_display.dart';
import '../widgets/loading_indicator.dart';
import 'add_connection_screen.dart';
import 'main_screen.dart';
import 'database_test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: AppColors.primaryDark,
        actions: [
          // Add a menu button to access the database test screen
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'database_test') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatabaseTestScreen(),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'database_test',
                    child: Text('Database Test'),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<ConnectionsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: AppStrings.loading);
          }

          if (provider.error != null) {
            return ErrorDisplay(
              errorMessage: provider.error!,
              onRetry: () => provider.loadConnections(),
            );
          }

          if (provider.connections.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildConnectionsList(context, provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddConnection(context),
        backgroundColor: AppColors.accent,
        child: const Icon(AppIcons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.large),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.live, size: 80, color: AppColors.primary),
            const SizedBox(height: AppPaddings.large),
            Text(
              AppStrings.noConnections,
              style: AppTextStyles.headline1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppPaddings.medium),
            Text(
              AppStrings.addConnectionMessage,
              style: AppTextStyles.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppPaddings.extraLarge),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddConnection(context),
              icon: const Icon(AppIcons.add),
              label: const Text(AppStrings.addConnection),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPaddings.large,
                  vertical: AppPaddings.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionsList(
    BuildContext context,
    ConnectionsProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppPaddings.medium),
      itemCount: provider.connections.length,
      itemBuilder: (context, index) {
        final connection = provider.connections[index];
        return ConnectionCard(
          connection: connection,
          onTap: () => _openConnection(context, connection),
          onEdit: () => _navigateToEditConnection(context, connection),
          onDelete:
              () => _showDeleteConfirmation(context, provider, connection),
        );
      },
    );
  }

  void _navigateToAddConnection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddConnectionScreen()),
    );
  }

  void _navigateToEditConnection(
    BuildContext context,
    XtreamConnection connection,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddConnectionScreen(connection: connection),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ConnectionsProvider provider,
    XtreamConnection connection,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Delete Connection'),
            content: Text(
              'Are you sure you want to delete "${connection.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteConnection(connection.id);
                  Navigator.pop(context);
                },
                child: Text(
                  AppStrings.delete,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _openConnection(BuildContext context, XtreamConnection connection) {
    final stopwatch = Stopwatch()..start();
    debugPrint(
      'TIMING: _openConnection started for connection: ${connection.name}',
    );

    // Set the connection in the ContentProvider
    final contentProvider = Provider.of<ContentProvider>(
      context,
      listen: false,
    );
    contentProvider.setConnection(connection);

    debugPrint(
      'TIMING: ContentProvider.setConnection completed in ${stopwatch.elapsedMilliseconds}ms',
    );

    // Navigate to the MainScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );

    debugPrint(
      'TIMING: _openConnection navigation initiated in ${stopwatch.elapsedMilliseconds}ms',
    );
  }
}
