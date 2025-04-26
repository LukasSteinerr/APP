import 'package:flutter/material.dart';
import '../models/xtream_connection.dart';
import '../utils/constants.dart';

class ConnectionCard extends StatelessWidget {
  final XtreamConnection connection;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const ConnectionCard({
    super.key,
    required this.connection,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppPaddings.medium,
        vertical: AppPaddings.small,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
      ),
      color: AppColors.card,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(AppPaddings.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      connection.name,
                      style: AppTextStyles.headline3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(AppIcons.edit, color: AppColors.primary),
                        onPressed: onEdit,
                        tooltip: AppStrings.editConnection,
                      ),
                      IconButton(
                        icon: const Icon(AppIcons.delete, color: AppColors.error),
                        onPressed: onDelete,
                        tooltip: AppStrings.delete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppPaddings.small),
              Text(
                connection.serverUrl,
                style: AppTextStyles.body2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppPaddings.small),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Username: ${connection.username}',
                    style: AppTextStyles.body2,
                  ),
                  Text(
                    'Added: ${_formatDate(connection.addedDate)}',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
