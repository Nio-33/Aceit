import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aceit/core/theme/app_theme.dart';

/// A standardized text field component used throughout the app.
///
/// This text field has consistent styling, supports validation,
/// placeholder text, and various input types.
class CustomTextField extends StatelessWidget {
  /// Controller for the text field
  final TextEditingController controller;

  /// Label text displayed above the field
  final String labelText;

  /// Hint text displayed inside the field when empty
  final String? hintText;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional suffix icon
  final IconData? suffixIcon;

  /// Optional action when suffix icon is pressed
  final VoidCallback? onSuffixIconPressed;

  /// Text input type (defaults to text)
  final TextInputType keyboardType;

  /// Optional validation function
  final String? Function(String?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Optional helper text below the field
  final String? helperText;

  /// Maximum number of characters allowed
  final int? maxLength;

  /// Action to perform on field submission
  final void Function(String)? onSubmitted;

  /// Input formatters for special formatting requirements
  final List<TextInputFormatter>? inputFormatters;

  /// Creates a custom text field with standardized styling.
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.helperText,
    this.maxLength,
    this.onSubmitted,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty) ...[
          Text(
            labelText,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          enabled: enabled,
          maxLength: maxLength,
          onFieldSubmitted: onSubmitted,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? theme.cardColor
                : theme.disabledColor.withOpacity(0.1),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
