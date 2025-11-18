// lib/screen/notification_screen/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/service/notification_service.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';

class NotificationScreenU extends StatelessWidget {
  const NotificationScreenU({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the notification service
    final notificationService = Get.put(NotificationService());
    
    return Scaffold(
      backgroundColor: ColorRes.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              width: Get.width,
              child: Stack(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      height: 40,
                      width: 40,
                      margin: const EdgeInsets.only(left: 20),
                      decoration: BoxDecoration(
                        color: ColorRes.logoColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Title
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Notifications",
                      style: appTextStyle(
                        color: ColorRes.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Clear all button
                  Positioned(
                    right: 20,
                    child: GestureDetector(
                      onTap: () async {
                        await notificationService.clearAllNotifications();
                        Get.snackbar(
                          'Cleared',
                          'All notifications removed',
                          backgroundColor: ColorRes.appleGreen,
                          colorText: Colors.white,
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: ColorRes.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.clear_all,
                          size: 18,
                          color: ColorRes.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Notifications list
            Expanded(
              child: Obx(() {
                final notifications = notificationService.notifications;
                
                if (notifications.isEmpty) {
                  return _EmptyState();
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await notificationService.loadNotifications();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final notification = notifications[i];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () async {
                          if (notification['id'] != null) {
                            await notificationService.markAsRead(notification['id']);
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });
  
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'] ?? false;
    final type = notification['type'] ?? 'default';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[800] : Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.withOpacity(0.3) : ColorRes.brightYellow.withOpacity(0.5),
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: _getIconColor(type).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconData(type),
            color: _getIconColor(type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'] ?? 'Notification',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appTextStyle(
                  fontSize: 16,
                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                  color: isRead ? Colors.white70 : Colors.white,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ColorRes.brightYellow,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification['body'] ?? 'No details available',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isRead ? Colors.white60 : Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                notification['timeAgo'] ?? 'Unknown',
                style: appTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getIconColor(type),
                ),
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
  
  IconData _getIconData(String type) {
    switch (type) {
      case 'application_sent':
        return Icons.send_rounded;
      case 'match':
        return Icons.favorite_rounded;
      case 'interview':
        return Icons.video_call_rounded;
      case 'message':
        return Icons.message_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
  
  Color _getIconColor(String type) {
    switch (type) {
      case 'application_sent':
        return ColorRes.appleGreen;
      case 'match':
        return ColorRes.red;
      case 'interview':
        return Colors.purple;
      case 'message':
        return Colors.blue;
      default:
        return ColorRes.brightYellow;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none_rounded,
              size: 52, color: ColorRes.grey),
          const SizedBox(height: 8),
          Text(
            'No notifications yet',
            style: appTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorRes.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'We\'ll keep you posted here.',
            style: appTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorRes.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}