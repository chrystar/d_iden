import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final BorderSide? border;
  
  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 2.0,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(16);
    
    Widget card = Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: cardBorderRadius,
        side: border ?? BorderSide.none,
      ),
      color: backgroundColor ?? AppColors.surface,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: card,
      );
    }
    
    return card;
  }
}

class GradientAppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final List<Color> gradientColors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  
  const GradientAppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 2.0,
    this.gradientColors = const [AppColors.primary, AppColors.secondary],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.borderRadius,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(16);
    
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: cardBorderRadius,
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: gradientColors,
        ),
      ),
      child: child,
    );
    
    Widget card = Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: cardBorderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: content,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: card,
      );
    }
    
    return card;
  }
}
