import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeless/utils/color_res.dart';

class UniversalBackFab extends StatelessWidget {
  final VoidCallback? onTap;
  final String? tooltip;
  final bool mini;

  const UniversalBackFab({
    super.key,
    this.onTap,
    this.tooltip,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap ?? () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Get.offAllNamed('/dashboard');
        }
      },
      backgroundColor: ColorRes.white,
      foregroundColor: ColorRes.black,
      elevation: 4,
      mini: mini,
      tooltip: tooltip ?? 'Retour',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(mini ? 28 : 32),
        side: const BorderSide(
          color: Color(0xFF000647),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.arrow_back,
        color: ColorRes.black,
      ),
    );
  }
}

class SimpleBackFab extends StatelessWidget {
  final VoidCallback? onTap;
  final bool mini;

  const SimpleBackFab({
    super.key,
    this.onTap,
    this.mini = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Material(
        color: ColorRes.white,
        borderRadius: BorderRadius.circular(mini ? 28 : 32),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            color: ColorRes.white,
            borderRadius: BorderRadius.circular(mini ? 28 : 32),
            border: Border.all(
              color: const Color(0xFF000647),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000647).withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap ?? () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Get.offAllNamed('/dashboard');
              }
            },
            borderRadius: BorderRadius.circular(mini ? 28 : 32),
            child: SizedBox(
              width: mini ? 40 : 56,
              height: mini ? 40 : 56,
              child: const Icon(
                Icons.arrow_back,
                color: ColorRes.black,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BackButtonOverlay extends StatelessWidget {
  final VoidCallback? onTap;
  final Alignment alignment;
  final EdgeInsets margin;

  const BackButtonOverlay({
    super.key,
    this.onTap,
    this.alignment = Alignment.topLeft,
    this.margin = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: margin,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap ?? () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.offAllNamed('/dashboard');
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: ColorRes.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF000647),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000647).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: ColorRes.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}