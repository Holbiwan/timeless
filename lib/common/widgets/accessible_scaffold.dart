import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/services/accessibility_service.dart';

// Widget Scaffold qui s'adapte automatiquement aux paramètres d'accessibilité
class AccessibleScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const AccessibleScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;

    return Obx(() => Scaffold(
          backgroundColor:
              backgroundColor ?? accessibilityService.backgroundColor,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          endDrawer: endDrawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ));
  }
}

// Widget Text qui s'adapte automatiquement aux paramètres d'accessibilité
class AccessibleText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  const AccessibleText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;

    return Obx(() => Semantics(
          label: semanticsLabel ?? accessibilityService.getSemanticLabel(text),
          child: Text(
            text,
            style: accessibilityService.getAccessibleTextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          ),
        ));
  }
}

// Widget Button qui s'adapte automatiquement aux paramètres d'accessibilité
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final IconData? icon;
  final String? semanticsLabel;

  const AccessibleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.icon,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;

    return Obx(() => Semantics(
          label: semanticsLabel ?? accessibilityService.getSemanticLabel(text),
          button: true,
          child: icon != null
              ? ElevatedButton.icon(
                  onPressed: onPressed != null
                      ? () {
                          accessibilityService.triggerHapticFeedback();
                          onPressed!();
                        }
                      : null,
                  icon: Icon(icon),
                  label: Text(text),
                  style: accessibilityService.getAccessibleButtonStyle(
                    backgroundColor: backgroundColor,
                  ),
                )
              : ElevatedButton(
                  onPressed: onPressed != null
                      ? () {
                          accessibilityService.triggerHapticFeedback();
                          onPressed!();
                        }
                      : null,
                  style: accessibilityService.getAccessibleButtonStyle(
                    backgroundColor: backgroundColor,
                  ),
                  child: Text(text),
                ),
        ));
  }
}

// Widget Container qui s'adapte automatiquement aux paramètres d'accessibilité
class AccessibleContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const AccessibleContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final accessibilityService = AccessibilityService.instance;

    return Obx(() {
      final widget = Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor ?? accessibilityService.cardBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          border: Border.all(
            color: accessibilityService.borderColor,
            width: 1,
          ),
        ),
        child: child,
      );

      if (onTap != null) {
        return accessibilityService.buildAccessibleWidget(
          semanticLabel: semanticsLabel ?? 'Tappable container',
          onTap: onTap,
          child: widget,
        );
      }

      return widget;
    });
  }
}
