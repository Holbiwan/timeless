import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernLoader extends StatefulWidget {
  final String? message;
  final double size;
  final bool showMessage;

  const ModernLoader({
    Key? key,
    this.message,
    this.size = 50.0,
    this.showMessage = true,
  }) : super(key: key);

  @override
  State<ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<ModernLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loader animé
            ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFF000647), // Bleu foncé
                        Color(0xFFFF8C00), // Orange
                        Color(0xFF000647), // Bleu foncé
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular((widget.size - 8) / 2),
                    ),
                    child: const Icon(
                      Icons.hourglass_empty,
                      color: Color(0xFF000647),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            if (widget.showMessage) ...[
              const SizedBox(height: 16),
              Text(
                widget.message ?? 'Loading...',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Skeleton loader pour les listes
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
                1.0,
              ],
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade200,
                Colors.white,
                Colors.grey.shade200,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget pour les cartes de job en loading
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(
                width: 40,
                height: 40,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(
                      width: double.infinity,
                      height: 16,
                    ),
                    const SizedBox(height: 4),
                    SkeletonLoader(
                      width: Get.width * 0.4,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonLoader(
            width: double.infinity,
            height: 12,
          ),
          const SizedBox(height: 4),
          SkeletonLoader(
            width: Get.width * 0.6,
            height: 12,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SkeletonLoader(
                width: 60,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              const SizedBox(width: 8),
              const SkeletonLoader(
                width: 80,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              const Spacer(),
              const SkeletonLoader(
                width: 70,
                height: 32,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}