import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = isDisabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        textColor = AppColors.white;
        borderColor = Colors.transparent;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        borderColor = AppColors.primary;
        break;
      case AppButtonVariant.ghost:
        bgColor = AppColors.accentLight;
        textColor = AppColors.primary;
        borderColor = Colors.transparent;
        break;
      case AppButtonVariant.danger:
        bgColor = isDisabled ? AppColors.error.withOpacity(0.5) : AppColors.error;
        textColor = AppColors.white;
        borderColor = Colors.transparent;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1.5),
              gradient: variant == AppButtonVariant.primary && !isDisabled
                  ? AppColors.primaryGradient
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: textColor,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: textColor, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
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
