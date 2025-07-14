import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  
  const ShimmerLoading({
    super.key, 
    required this.child, 
    required this.isLoading,
    this.baseColor = const Color(0xFFEBEBF4),
    this.highlightColor = const Color(0xFFF4F4F4),
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerIdentityCard extends StatelessWidget {
  const ShimmerIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerBox(
                width: 40,
                height: 40,
                borderRadius: 8,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(
                      width: 150,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    const ShimmerBox(
                      width: 100,
                      height: 12,
                    ),
                  ],
                ),
              ),
              const ShimmerBox(
                width: 60,
                height: 24,
                borderRadius: 30,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerBox(
            width: double.infinity,
            height: 14,
          ),
          const SizedBox(height: 8),
          const ShimmerBox(
            width: 120,
            height: 12,
          ),
        ],
      ),
    );
  }
}

class ShimmerCredentialCard extends StatelessWidget {
  const ShimmerCredentialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            width: 40,
            height: 40,
            borderRadius: 8,
          ),
          const SizedBox(height: 12),
          const ShimmerBox(
            width: 100,
            height: 16,
          ),
          const SizedBox(height: 4),
          const ShimmerBox(
            width: 80,
            height: 12,
          ),
          const SizedBox(height: 8),
          const ShimmerBox(
            width: 140,
            height: 11,
          ),
        ],
      ),
    );
  }
}

class ShimmerStats extends StatelessWidget {
  const ShimmerStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const ShimmerBox(
                  width: 30,
                  height: 30,
                  borderRadius: 8,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(
                      width: 40,
                      height: 12,
                    ),
                    const SizedBox(height: 4),
                    const ShimmerBox(
                      width: 20,
                      height: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const ShimmerBox(
                  width: 30,
                  height: 30,
                  borderRadius: 8,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(
                      width: 40,
                      height: 12,
                    ),
                    const SizedBox(height: 4),
                    const ShimmerBox(
                      width: 20,
                      height: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const ShimmerBox(
                  width: 30,
                  height: 30,
                  borderRadius: 8,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(
                      width: 40,
                      height: 12,
                    ),
                    const SizedBox(height: 4),
                    const ShimmerBox(
                      width: 20,
                      height: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
