import 'package:flutter/material.dart';

import '../app/theme.dart';

/// A styled text input field following the DESIGN.md Modern Haven system.
///
/// Design spec:
/// - Label above the field (not floating)
/// - Error message below the field
/// - Focus ring: [DesignTokens.secondary] amber (#D97706)
/// - Border radius: [AppRadius.sm] (8px)
/// - Optional password visibility toggle
///
/// Usage:
/// ```dart
/// CustomTextField(
///   label: 'Email',
///   hint: 'admin@apartment.com',
///   controller: _emailController,
///   validator: AppValidators.validateEmail,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.initialValue,
    this.helperText,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final String? initialValue;
  final String? helperText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.label,
          style: textTheme.labelLarge?.copyWith(
            color: DesignTokens.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Input field
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword && _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: textTheme.bodyLarge?.copyWith(color: DesignTokens.onSurface),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: DesignTokens.neutralVariant)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: DesignTokens.neutralVariant,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    tooltip: _obscureText ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
