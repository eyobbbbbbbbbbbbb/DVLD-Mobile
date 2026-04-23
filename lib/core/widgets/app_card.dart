import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final double borderRadius;
  final double elevation;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.gradient,
    this.borderRadius = 18,
    this.elevation = 4,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? AppColors.cardBg) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.07),
                      blurRadius: elevation * 3,
                      offset: Offset(0, elevation),
                    ),
                  ]
                : null,
          ),
          padding: padding ?? const EdgeInsets.all(18),
          child: child,
        ),
      ),
    );
  }
}
