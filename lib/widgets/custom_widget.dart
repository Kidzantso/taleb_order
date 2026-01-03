import 'package:flutter/material.dart';

Widget customTextField(
  TextEditingController controller,
  String label, {
  bool obscure = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8E9F2), // soft background
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFFF0022),
            width: 2,
          ), // red focus
        ),
      ),
    ),
  );
}
