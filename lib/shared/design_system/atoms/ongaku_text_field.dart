import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

/// Labeled input (`.field` + `.input`). [mono] for URLs and tokens.
class OngakuTextField extends StatelessWidget {
  const OngakuTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.mono = false,
    this.error = false,
    this.autofocus = false,
    this.onSubmitted,
    this.onChanged,
    this.maxLength,
    this.large = false,
    this.focusNode,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool mono;
  final bool error;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final int? maxLength;

  /// Big inline title editor (playlist rename).
  final bool large;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = mono
        ? OngakuTypography.mono(context, size: 15, color: c.fg)
        : TextStyle(
            fontSize: large ? 22 : 15,
            fontWeight: large ? FontWeight.w700 : FontWeight.w400,
            color: c.fg,
          );
    OutlineInputBorder border(Color color, [double w = 1]) =>
        OutlineInputBorder(
          borderRadius: OngakuRadii.mdAll,
          borderSide: BorderSide(color: color, width: w),
        );
    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      maxLength: maxLength,
      style: style,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: c.muted),
        isDense: true,
        counterText: '',
        filled: true,
        fillColor: c.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: large ? 16 : 13,
        ),
        enabledBorder: border(error ? c.err : c.border),
        focusedBorder: border(error ? c.err : c.fg),
        border: border(c.border),
      ),
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label!,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.muted,
          ),
        ),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
