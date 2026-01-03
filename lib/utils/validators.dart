import 'package:flutter/material.dart';

/// Validates that a text field is not empty.
/// Shows a SnackBar if validation fails.
bool validateField(BuildContext context, String value, String fieldName) {
  if (value.trim().isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$fieldName is required")));
    return false;
  }
  return true;
}

/// Validates email format (must contain @ and .).
bool validateEmail(BuildContext context, String email) {
  if (email.trim().isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Email is required")));
    return false;
  }

  // Simple regex for email format
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailRegex.hasMatch(email.trim())) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Invalid email format")));
    return false;
  }
  return true;
}
