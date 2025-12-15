import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';
import 'package:timeless/utils/app_dimensions.dart';
import 'package:timeless/utils/app_style.dart';

// ==========================================
// COMPOSANTS UI STANDARDISÉS TIMELESS
// ==========================================

// Bouton principal standard
class TimelessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final ButtonSize size;
  final IconData? icon;
  final Color? customColor;

  const TimelessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.size = ButtonSize.medium,
    this.icon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final height = _getHeight();
    final fontSize = _getFontSize();
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: isSecondary ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            side: isSecondary
                ? BorderSide(color: ColorRes.borderColor, width: 1)
                : BorderSide.none,
          ),
          padding: AppDimensions.buttonPaddingInsets,
        ),
        child: isLoading
            ? SizedBox(
                height: AppDimensions.iconSizeMedium,
                width: AppDimensions.iconSizeMedium,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconSizeMedium),
                    SizedBox(width: AppDimensions.sm),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: fontSize,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.buttonHeightSmall;
      case ButtonSize.large:
        return AppDimensions.buttonHeightLarge;
      case ButtonSize.medium:
        return AppDimensions.buttonHeight;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return AppDimensions.fontSizeSM;
      case ButtonSize.large:
        return AppDimensions.fontSizeLG;
      case ButtonSize.medium:
        return AppDimensions.fontSizeMD;
    }
  }

  Color _getBackgroundColor() {
    if (customColor != null) return customColor!;
    if (isSecondary) return ColorRes.white;
    return ColorRes.primaryBlue;
  }

  Color _getTextColor() {
    if (isSecondary) return ColorRes.primaryBlue;
    return ColorRes.white;
  }
}

enum ButtonSize { small, medium, large }

// Champ de texte standard optimisé
class TimelessTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final String? helperText;

  const TimelessTextField({
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium,
          ),
          SizedBox(height: AppDimensions.xs),
        ],
        Container(
          constraints: BoxConstraints(
            minHeight: AppDimensions.inputHeight,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onTap: onTap,
            readOnly: readOnly,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: ColorRes.textTertiary,
              ),
              errorText: errorText,
              errorStyle: AppTextStyles.errorText,
              helperText: helperText,
              helperStyle: AppTextStyles.caption,
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              contentPadding: AppDimensions.inputPaddingInsets,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                borderSide: BorderSide(color: ColorRes.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                borderSide: BorderSide(color: ColorRes.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                borderSide: BorderSide(color: ColorRes.primaryBlue, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
                borderSide: BorderSide(color: ColorRes.errorColor),
              ),
              filled: true,
              fillColor: ColorRes.white,
            ),
          ),
        ),
      ],
    );
  }
}

// Carte standard avec padding optimisé
class TimelessCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;

  const TimelessCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? AppDimensions.cardElevation,
      color: backgroundColor ?? ColorRes.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          padding: padding ?? AppDimensions.cardPaddingInsets,
          child: child,
        ),
      ),
    );
  }
}

// Container de page optimisé pour éviter le scroll
class TimelessPageContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool avoidBottomInset;

  const TimelessPageContainer({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.avoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? ColorRes.backgroundColor,
      resizeToAvoidBottomInset: avoidBottomInset,
      appBar: (title != null || showBackButton || actions != null)
          ? AppBar(
              backgroundColor: ColorRes.white,
              elevation: 0,
              centerTitle: true,
              leading: showBackButton
                  ? IconButton(
                      icon: Icon(Icons.arrow_back, color: ColorRes.textPrimary),
                      onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                    )
                  : null,
              title: title != null
                  ? Text(
                      title!,
                      style: AppTextStyles.h4.copyWith(color: ColorRes.textPrimary),
                    )
                  : null,
              actions: actions,
            )
          : null,
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: AppDimensions.maxContentWidth,
          ),
          margin: EdgeInsets.symmetric(horizontal: AppDimensions.pageHorizontalPadding),
          child: child,
        ),
      ),
    );
  }
}

// Formulaire compact optimisé
class TimelessForm extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final Widget? submitButton;
  final bool shrinkWrap;

  const TimelessForm({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.submitButton,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: AppDimensions.maxFormWidth,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.h3),
            SizedBox(height: AppDimensions.sm),
          ],
          if (subtitle != null) ...[
            Text(subtitle!, style: AppTextStyles.bodyMedium.copyWith(
              color: ColorRes.textSecondary,
            )),
            SizedBox(height: AppDimensions.lg),
          ],
          ...children.map((child) => Padding(
            padding: AppDimensions.formFieldMargin,
            child: child,
          )).toList(),
          if (submitButton != null) ...[
            SizedBox(height: AppDimensions.lg),
            submitButton!,
          ],
        ],
      ),
    );
  }
}

// Section avec espacement standardisé
class TimelessSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets? padding;

  const TimelessSection({
    super.key,
    this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppDimensions.sectionMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.h4),
            SizedBox(height: AppDimensions.lg),
          ],
          child,
        ],
      ),
    );
  }
}

// Badge et chips standardisés
class TimelessChip extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const TimelessChip({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? (isSelected ? ColorRes.primaryBlue : ColorRes.grey100);
    final txtColor = textColor ?? (isSelected ? ColorRes.white : ColorRes.textSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.lg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.lg),
          border: isSelected ? null : Border.all(color: ColorRes.borderColor),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(color: txtColor),
        ),
      ),
    );
  }
}