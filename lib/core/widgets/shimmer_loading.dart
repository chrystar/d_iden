import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;
  final ShimmerDirection direction;
  final bool enabled;
  final Widget? placeholder;
  
  const ShimmerLoading({
    super.key, 
    required this.child, 
    required this.isLoading,
    this.baseColor = const Color(0xFFEBEBF4),
    this.highlightColor = const Color(0xFFF4F4F4),
    this.period = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
    this.enabled = true,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }
    
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      direction: direction,
      enabled: enabled,
      child: placeholder ?? child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 4.0,
    this.color,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow,
      ),
    );
  }
}

class ShimmerIdentityCard extends StatelessWidget {
  const ShimmerIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const ShimmerBox(
                  width: 45,
                  height: 45,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(
                      width: 160,
                      height: 18,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 10),
                    ShimmerBox(
                      width: 120,
                      height: 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const ShimmerBox(
                  width: 70,
                  height: 28,
                  borderRadius: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ShimmerBox(
            width: double.infinity,
            height: 16,
            borderRadius: 4,
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              ShimmerBox(
                width: 140,
                height: 14,
                borderRadius: 4,
              ),
              Spacer(),
              ShimmerBox(
                width: 50,
                height: 14,
                borderRadius: 4,
              ),
            ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const ShimmerBox(
              width: 40,
              height: 40,
              borderRadius: 8,
            ),
          ),
          const SizedBox(height: 12),
          const ShimmerBox(
            width: 100,
            height: 16,
          ),
          const SizedBox(height: 6),
          const ShimmerBox(
            width: 80,
            height: 12,
          ),
          const SizedBox(height: 12),
          const ShimmerBox(
            width: 140,
            height: 11,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              ShimmerBox(
                width: 60,
                height: 24,
                borderRadius: 12,
              ),
            ],
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
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < 2 ? 12.0 : 0.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    children: const [
                      ShimmerBox(
                        width: 40,
                        height: 12,
                      ),
                      SizedBox(height: 4),
                      ShimmerBox(
                        width: 20,
                        height: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
