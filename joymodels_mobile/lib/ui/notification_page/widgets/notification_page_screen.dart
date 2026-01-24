import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/notification/response_types/notification_response_api_model.dart';
import 'package:joymodels_mobile/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_mobile/ui/core/ui/error_display.dart';
import 'package:joymodels_mobile/ui/core/ui/pagination_controls.dart';
import 'package:joymodels_mobile/ui/core/ui/user_avatar.dart';
import 'package:joymodels_mobile/ui/notification_page/view_model/notification_page_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPageScreen extends StatefulWidget {
  const NotificationPageScreen({super.key});

  @override
  State<NotificationPageScreen> createState() => _NotificationPageScreenState();
}

class _NotificationPageScreenState extends State<NotificationPageScreen> {
  late final NotificationPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<NotificationPageViewModel>();
    _viewModel.onSessionExpired = _handleSessionExpired;
    _viewModel.onForbidden = _handleForbidden;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
    });
  }

  void _handleSessionExpired() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePageScreen()),
      (route) => false,
    );
  }

  void _handleForbidden() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationPageViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (viewModel.notificationItems.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  viewModel.markAllAsRead();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(viewModel, theme),
    );
  }

  Widget _buildBody(NotificationPageViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading && viewModel.notificationItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return ErrorDisplay(
        message: viewModel.errorMessage!,
        onRetry: () => viewModel.init(),
      );
    }

    if (viewModel.notificationItems.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.notificationItems.length,
            itemBuilder: (context, index) {
              return _buildNotificationTile(
                viewModel.notificationItems[index],
                viewModel,
                theme,
              );
            },
          ),
        ),
        PaginationControls(
          currentPage: viewModel.currentPage,
          totalPages: viewModel.totalPages,
          hasPreviousPage: viewModel.hasPreviousPage,
          hasNextPage: viewModel.hasNextPage,
          onPreviousPage: viewModel.onPreviousPage,
          onNextPage: viewModel.onNextPage,
          isLoading: viewModel.isLoading,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When someone interacts with your content,\nyou\'ll see it here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    NotificationResponseApiModel notification,
    NotificationPageViewModel viewModel,
    ThemeData theme,
  ) {
    final icon = _getNotificationIcon(notification.notificationType);
    final iconColor = _getNotificationColor(notification.notificationType);

    return Dismissible(
      key: Key(notification.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        viewModel.deleteNotification(notification.uuid);
      },
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            viewModel.markAsRead(notification.uuid);
          }
        },
        child: Container(
          color: notification.isRead
              ? null
              : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: ListTile(
            leading: Stack(
              children: [
                UserAvatar(
                  imageUrl:
                      '${ApiConstants.baseUrl}/users/get/${notification.actor.uuid}/avatar',
                  radius: 24,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                ),
              ],
            ),
            title: Text(
              notification.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: notification.isRead
                    ? FontWeight.normal
                    : FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(notification.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            trailing: !notification.isRead
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String notificationType) {
    switch (notificationType) {
      case 'OrderCompleted':
        return Icons.shopping_bag;
      case 'OrderFailed':
        return Icons.error_outline;
      case 'NewFollower':
        return Icons.person_add;
      case 'NewModelReview':
        return Icons.star;
      case 'ModelSold':
        return Icons.attach_money;
      case 'ModelLiked':
        return Icons.favorite;
      case 'NewComment':
        return Icons.comment;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String notificationType) {
    switch (notificationType) {
      case 'OrderCompleted':
        return Colors.green;
      case 'OrderFailed':
        return Colors.red;
      case 'NewFollower':
        return Colors.blue;
      case 'NewModelReview':
        return Colors.amber;
      case 'ModelSold':
        return Colors.green;
      case 'ModelLiked':
        return Colors.red;
      case 'NewComment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
