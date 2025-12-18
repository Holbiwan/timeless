import 'package:flutter/material.dart';
import 'package:timeless/utils/app_style.dart';
import 'package:timeless/utils/color_res.dart';

class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconBackgroundColor;
  final Color? iconColor;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconBackgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? const Color(0xFF000647),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.white,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: appTextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ColorRes.black,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}