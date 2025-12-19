// Universal app bar and scaffold
// Shared layout widgets to keep navigation and headers consistent

import 'package:flutter/material.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/common/widgets/back_button.dart';

// Custom AppBar used across the app
class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;
  final Widget? leading;
  final double elevation;

  const UniversalAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.centerTitle = true,
    this.leading,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? ColorRes.backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      // Custom back button or custom leading widget
      leading: leading ??
          (showBackButton
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: universalBackButton(onTap: onBackPressed),
                )
              : null),
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: ColorRes.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      actions: actions,
      // Disable default back button behavior
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Scaffold wrapper that includes the UniversalAppBar by default
class TimelessScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool centerTitle;
  final Widget? leading;
  final double elevation;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;

  const TimelessScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.centerTitle = true,
    this.leading,
    this.elevation = 0,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? ColorRes.backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: UniversalAppBar(
        title: title,
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
        actions: actions,
        backgroundColor: backgroundColor ?? ColorRes.backgroundColor,
        centerTitle: centerTitle,
        leading: leading,
        elevation: elevation,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
