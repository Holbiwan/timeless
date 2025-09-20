// lib/screen/notification_screen/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/string.dart';

class NotificationScreenU extends StatelessWidget {
  const NotificationScreenU({super.key});

  @override
  Widget build(BuildContext context) {
    // On accepte une liste venant de Get.arguments (optionnel)
    // Ex: Get.to(NotificationScreenU(), arguments: {'items': [{'title':'..','body':'..','image':'..','date':'..'}]});
    final args = Get.arguments as Map<String, dynamic>?;

    final List<dynamic> rawItems =
        (args?['items'] as List<dynamic>?) ?? const [];

    // Normalisation null-safe
    final items = rawItems
        .map<Map<String, String>>((e) {
          final m = (e as Map?)?.cast<String, dynamic>() ?? const {};
          return {
            'title': (m['title'] as String?)?.trim() ?? 'Untitled',
            'body': (m['body'] as String?)?.trim() ?? '',
            'image': (m['image'] as String?)?.trim() ?? '',
            'date': (m['date'] as String?)?.trim() ?? '',
          };
        })
        .toList();

    // Démo/fallback si aucune donnée n’est fournie
    final demo = <Map<String, String>>[
      {
        'title': 'New job match',
        'body': 'A React Developer role matches your skills.',
        'image': '',
        'date': 'Today',
      },
      {
        'title': 'Interview tip',
        'body': 'Bring 1–2 portfolio pieces for the product round.',
        'image': '',
        'date': 'Yesterday',
      },
      {
        'title': 'Saved job updated',
        'body': 'Timeless Labs increased the salary range.',
        'image': '',
        'date': '2 days ago',
      },
    ];

    final data = items.isNotEmpty ? items : demo;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              width: Get.width,
              child: Stack(
                children: [
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
                        color: ColorRes.containerColor,
                        size: 18,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      Strings.notification,
                      style: appTextStyle(
                        color: ColorRes.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = data[i];
                  final title = item['title'] ?? '';
                  final body = item['body'] ?? '';
                  final date = item['date'] ?? '';
                  final image = item['image'] ?? '';

                  return _NotificationTile(
                    title: title,
                    body: body,
                    date: date,
                    imageUrl: image,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.body,
    required this.date,
    required this.imageUrl,
  });

  final String title;
  final String body;
  final String date;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Ouvre le détail avec les mêmes données (toujours null-safe)
          Get.to(
            () => const NotificationScreenU(),
            arguments: {
              'items': [
                {
                  'title': title,
                  'body': body,
                  'date': date,
                  'image': imageUrl,
                }
              ],
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(width: 48, height: 48),
                  ),
                )
              else
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications, size: 22, color: Colors.black54),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isNotEmpty ? title : 'Untitled',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: appTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorRes.black,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: appTextStyle(
                          fontSize: 12,
                          color: ColorRes.black.withOpacity(.7),
                        ),
                      ),
                    ],
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        date,
                        style: appTextStyle(
                          fontSize: 11,
                          color: ColorRes.black.withOpacity(.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
