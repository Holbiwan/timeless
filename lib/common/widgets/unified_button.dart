import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/services/animation_service.dart';

enum UnifiedButtonType {
  primary,    // Fond blanc, bordure bleue
  secondary,  // Fond orange, texte bleu
  outlined,   // Transparent, bordure bleue
  darkPrimary,// Fond bleu foncé, texte blanc
  tertiary,   // NEW: Subtle action button
  black,      // NEW: Black background, white text
}

class UnifiedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final UnifiedButtonType type;
  final Widget? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const UnifiedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = UnifiedButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 42,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: width != null ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: AnimatedBounceButton(
        onTap: onPressed ?? () {},
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    // Brand colors (for consistency, though could be passed as params if needed more flexibility)
    final Color _primaryBlue = const Color(0xFF000647);
    final Color _accentOrange = const Color(0xFFE67E22);

    switch (type) {
      case UnifiedButtonType.primary:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: _primaryBlue, width: 2),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _buildButtonChild(Colors.black),
          ),
        );

      case UnifiedButtonType.secondary:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentOrange,
              foregroundColor: _primaryBlue,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: _accentOrange.withOpacity(0.4),
            ),
            child: _buildButtonChild(_primaryBlue),
          ),
        );

      case UnifiedButtonType.outlined:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(color: _primaryBlue, width: 2),
              foregroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _buildButtonChild(_primaryBlue),
          ),
        );

      case UnifiedButtonType.darkPrimary:
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: _primaryBlue.withOpacity(0.4),
            ),
            child: _buildButtonChild(Colors.white),
          ),
        );
      
      case UnifiedButtonType.tertiary: // NEW: Tertiary button style
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              backgroundColor: _primaryBlue.withOpacity(0.05),
              foregroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _buildButtonChild(_primaryBlue),
          ),
        );
      
      case UnifiedButtonType.black: // NEW: Black button style
        return SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.black.withOpacity(0.4),
            ),
            child: _buildButtonChild(Colors.white),
          ),
        );
    }
  }

  Widget _buildButtonChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
      ),
    );
  }
}
