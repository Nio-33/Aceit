import 'package:flutter/material.dart';
import 'package:aceit/core/theme/app_theme.dart';

/// A standardized primary button component used throughout the app.
/// 
/// This button has the app's primary color, rounded corners, and consistent padding.
/// It supports various states including loading, disabled, and customization options.
class PrimaryButton extends StatelessWidget {
  /// Text to display on the button
  final String text;
  
  /// Action to perform when button is pressed
  final VoidCallback onPressed;
  
  /// Whether the button should show a loading indicator
  final bool isLoading;
  
  /// Whether the button is in a disabled state
  final bool isDisabled;
  
  /// Icon to display before text (optional)
  final IconData? icon;
  
  /// Button width (defaults to max width)
  final double? width;
  
  /// Button height (defaults to standard height)
  final double? height;
  
  /// Custom background color (uses theme primary color by default)
  final Color? backgroundColor;
  
  /// Custom text color (uses white by default)
  final Color? textColor;
  
  /// Creates a primary button with standardized styling.
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 3,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 