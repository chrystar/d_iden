import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isOutlined;
  final bool isFullWidth;
  final IconData? icon;
  final bool isLoading;
  final double? height;
  final double? fontSize;
  
  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.style,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.icon,
    this.isLoading = false,
    this.height,
    this.fontSize,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 54.0;
    final textSize = fontSize ?? 16.0;
    
    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style ?? OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildButtonContent(textSize),
        ),
      );
    }
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style ?? ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildButtonContent(textSize),
      ),
    );
  }
  
  Widget _buildButtonContent(double fontSize) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2.5,
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class GradientAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color> gradientColors;
  final bool isFullWidth;
  final IconData? icon;
  final bool isLoading;
  final double? height;
  final double? fontSize;
  
  const GradientAppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradientColors = const [AppColors.primary, AppColors.secondary],
    this.isFullWidth = true,
    this.icon,
    this.isLoading = false,
    this.height,
    this.fontSize,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 54.0;
    final textSize = fontSize ?? 16.0;
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _buildButtonContent(textSize),
          ),
        ),
      ),
    );
  }
  
  Widget _buildButtonContent(double fontSize) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2.5,
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );
  }
}
