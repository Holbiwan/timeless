import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/color_res.dart';

class RefreshButton extends StatelessWidget {
  final VoidCallback? onRefresh;
  final String? message;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final EdgeInsets? margin;

  const RefreshButton({
    super.key,
    this.onRefresh,
    this.message,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onRefresh?.call();
        Get.snackbar(
          '🔄 Refreshing',
          message ?? 'Updating data...',
          backgroundColor: backgroundColor ?? ColorRes.brightYellow,
          colorText: iconColor ?? Colors.black,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.refresh, color: Colors.black),
        );
      },
      child: Container(
        height: size ?? 40,
        width: size ?? 40,
        margin: margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorRes.brightYellow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.refresh,
          color: iconColor ?? Colors.black,
          size: (size ?? 40) * 0.6,
        ),
      ),
    );
  }
}

class RefreshIconButton extends StatelessWidget {
  final VoidCallback? onRefresh;
  final String? message;
  final Color? color;
  final String? tooltip;

  const RefreshIconButton({
    super.key,
    this.onRefresh,
    this.message,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.refresh, color: color ?? Colors.white),
      onPressed: () {
        onRefresh?.call();
        Get.snackbar(
          '🔄 Refreshing',
          message ?? 'Updating data...',
          backgroundColor: ColorRes.brightYellow,
          colorText: Colors.black,
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.refresh, color: Colors.black),
        );
      },
      tooltip: tooltip ?? 'Refresh',
    );
  }
}

// Helper class for standardizing refresh functionality
class RefreshHelper {
  // Show a standardized refresh message
  static void showRefreshMessage({
    String title = '🔄 Refreshing',
    String? message,
    Color? backgroundColor,
    Color? textColor,
  }) {
    Get.snackbar(
      title,
      message ?? 'Updating data...',
      backgroundColor: backgroundColor ?? ColorRes.brightYellow,
      colorText: textColor ?? Colors.black,
      duration: const Duration(seconds: 1),
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.refresh, color: Colors.black),
    );
  }

  // Create a refresh button with standardized styling
  static Widget createRefreshButton({
    required VoidCallback onRefresh,
    String? message,
    Color? backgroundColor,
    Color? iconColor,
    double? size,
    EdgeInsets? margin,
  }) {
    return RefreshButton(
      onRefresh: onRefresh,
      message: message,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      size: size,
      margin: margin,
    );
  }
}
