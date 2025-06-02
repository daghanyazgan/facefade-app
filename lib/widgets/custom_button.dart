import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final bool outlined;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.icon,
    this.outlined = false,
    this.shadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final Color buttonColor = backgroundColor ?? AppColors.primary;
    final Color buttonTextColor = textColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : (gradient == null ? (isDisabled ? AppColors.disabled : buttonColor) : null),
          gradient: gradient != null && !isDisabled && !outlined ? gradient : null,
          borderRadius: BorderRadius.circular(borderRadius),
          border: outlined ? Border.all(
            color: isDisabled ? AppColors.disabled : buttonColor,
            width: 2,
          ) : null,
          boxShadow: !outlined && !isDisabled ? (shadows ?? [
            BoxShadow(
              color: (gradient != null ? AppColors.primary : buttonColor).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading) ...[
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: outlined ? buttonColor : buttonTextColor,
                      size: 20,
                    ),
                  ] else ...[
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: outlined ? 
                          (isDisabled ? AppColors.disabled : buttonColor) : 
                          (isDisabled ? AppColors.textSecondary : buttonTextColor),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: outlined ? 
                            (isDisabled ? AppColors.disabled : buttonColor) : 
                            (isDisabled ? AppColors.textSecondary : buttonTextColor),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Özel buton varyantları
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      outlined: true,
      backgroundColor: AppColors.primary,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SuccessButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }
}

// Floating Action Button tarzında buton
class FloatingCustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const FloatingCustomButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = backgroundColor ?? AppColors.primary;
    final Color buttonIconColor = iconColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            color: buttonIconColor,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
} 