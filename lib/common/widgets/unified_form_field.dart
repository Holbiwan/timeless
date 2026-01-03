import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeless/utils/color_res.dart';

class UnifiedFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool isRequired;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData? prefixIcon; // NEW: Added prefixIcon
  final TextInputType keyboardType;
  final int? maxLength;
  final Function(String)? onChanged;
  final String? errorText;
  final bool enabled;
  final int? maxLines;

  const UnifiedFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.isRequired = false,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon, // NEW: Added prefixIcon
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<UnifiedFormField> createState() => _UnifiedFormFieldState();
}

class _UnifiedFormFieldState extends State<UnifiedFormField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.02,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _borderColorAnimation = ColorTween(
        begin: const Color(0xFF000647),
        end: const Color(0xFFFF8C00),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    } catch (e) {
      print('Error initializing animations in UnifiedFormField: $e');
      // Fallback: create dummy animations
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _scaleAnimation = AlwaysStoppedAnimation<double>(1.0);
      _borderColorAnimation = AlwaysStoppedAnimation<Color?>(const Color(0xFF000647));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool focused) {
    if (!mounted) return;
    
    setState(() {
      _isFocused = focused;
    });
    
    try {
      if (focused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    } catch (e) {
      print('Error in animation focus change: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label avec étoile si requis
              if (widget.labelText != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        widget.labelText!,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: ColorRes.textPrimary,
                        ),
                      ),
                      if (widget.isRequired)
                        const Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 15,
                            color: ColorRes.starColor,
                          ),
                        ),
                    ],
                  ),
                ),

              // Container avec design unifié et largeur optimisée
              Container(
                width: double.infinity,
                height: 42,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 0),
                      color: ColorRes.containerColor.withOpacity(0.15),
                      spreadRadius: -8,
                      blurRadius: 20,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Focus(
                  onFocusChange: _onFocusChange,
                  child: TextFormField(
                    controller: widget.controller,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    maxLength: widget.maxLength,
                    maxLines: widget.maxLines,
                    enabled: widget.enabled,
                    onChanged: widget.onChanged,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      hintText: widget.hintText,
                      suffixIcon: widget.suffixIcon,
                      // NEW: Added prefixIcon
                      prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: ColorRes.black.withOpacity(0.4), size: 20) : null,
                      filled: true,
                      fillColor: Colors.transparent,
                      counterText: '', // Cache le compteur de caractères
                      hintStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: ColorRes.black.withOpacity(0.4),
                      ),
                      // Bordures uniformes
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF000647),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF000647),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF000647),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: const Color(0xFF000647).withOpacity(0.3),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorRes.starColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorRes.starColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),

              // Message d'erreur
              if (widget.errorText != null && widget.errorText!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: ColorRes.invalidColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: ColorRes.starColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.errorText!,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 9,
                            color: ColorRes.starColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}