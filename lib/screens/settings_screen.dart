import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../utils/constants.dart';
import 'database_test_screen.dart';
import 'objectbox_debug_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = Provider.of<ContentProvider>(context);
    final connection = contentProvider.currentConnection;

    if (connection == null) {
      return const Center(
        child: Text('No active connection', style: AppTextStyles.headline2),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppPaddings.medium),
          children: [
            const SizedBox(height: AppPaddings.medium),
            // Connection Info Section
            _buildSectionHeader(context, 'Connection Info'),
            _buildInfoCard(
              context,
              title: 'Connection Name',
              value: connection.name,
              icon: Icons.link,
            ),
            _buildInfoCard(
              context,
              title: 'Server URL',
              value: connection.serverUrl,
              icon: Icons.dns,
            ),
            _buildInfoCard(
              context,
              title: 'Username',
              value: connection.username,
              icon: Icons.person,
            ),
            _buildInfoCard(
              context,
              title: 'Added Date',
              value: _formatDate(connection.addedDate),
              icon: Icons.calendar_today,
            ),

            const SizedBox(height: AppPaddings.large),

            // App Settings Section
            _buildSectionHeader(context, 'App Settings'),
            _buildSettingItem(
              context,
              title: 'Database Test',
              icon: Icons.storage,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatabaseTestScreen(),
                  ),
                );
              },
            ),
            _buildSettingItem(
              context,
              title: 'ObjectBox Database Debug',
              icon: Icons.data_array,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ObjectBoxDebugScreen(),
                  ),
                );
              },
            ),
            _buildSettingItem(
              context,
              title: 'Clear Cache',
              icon: Icons.cleaning_services,
              onTap: () {
                _showClearCacheDialog(context);
              },
            ),

            const SizedBox(height: AppPaddings.large),

            // App Info Section
            _buildSectionHeader(context, 'App Info'),
            _buildInfoCard(
              context,
              title: 'App Version',
              value: '1.0.0',
              icon: Icons.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppPaddings.small,
        bottom: AppPaddings.small,
      ),
      child: Text(
        title,
        style: AppTextStyles.headline3.copyWith(color: AppColors.accent),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppPaddings.small),
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.medium),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: AppPaddings.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.body1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppPaddings.small),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppPaddings.medium),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(width: AppPaddings.medium),
              Expanded(child: Text(title, style: AppTextStyles.body1)),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cache'),
            content: const Text(
              'Are you sure you want to clear the app cache? This will clear all preloaded data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final contentProvider = Provider.of<ContentProvider>(
                    context,
                    listen: false,
                  );

                  // Clear ObjectBox data but keep the connection
                  final connection = contentProvider.currentConnection;
                  await contentProvider.clearConnection();

                  if (connection != null) {
                    contentProvider.setConnection(connection);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cache cleared successfully'),
                      ),
                    );
                  }
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}
