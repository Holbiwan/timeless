// lib/screen/notification_screen/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

/// Petit modèle simple et non-nullable pour éviter tout crash.
class _NotifItem {
  final String title;
  final String body;
  final String time;

  const _NotifItem({
    required this.title,
    required this.body,
    required this.time,
  });
}

class NotificationScreenU extends StatelessWidget {
  const NotificationScreenU({super.key});

  // Données factices pour la démo (aucun null ici)
  List<_NotifItem> get _demoNotifications => const [
        _NotifItem(
          title: 'Application sent',
          body: 'Your application for “UI Designer” has been sent.',
          time: '2m ago',
        ),
        _NotifItem(
          title: 'New match',
          body: 'Timeless found 3 new jobs matching your profile.',
          time: '10m ago',
        ),
        _NotifItem(
          title: 'Interview',
          body: 'Recruiter proposed an interview for next week.',
          time: 'Yesterday',
        ),
        _NotifItem(
          title: 'Profile tip',
          body: 'Add your portfolio to get more matches.',
          time: '2 days ago',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _demoNotifications; // jamais vide/null pour la démo

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
                  // Back
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
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Liste (Expanded évite les overflow)
            Expanded(
              child: items.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final n = items[i];
                        return _NotifTile(item: n);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.item});
  final _NotifItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
            color: ColorRes.brightYellow.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            color: ColorRes.brightYellow,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: appTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: appTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.time,
                style: appTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorRes.brightYellow,
                ),
              ),
            ],
          ),
        ),
        onTap: () {},
      ),
    );
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
