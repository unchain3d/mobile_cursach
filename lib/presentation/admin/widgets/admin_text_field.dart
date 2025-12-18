import 'package:flutter/material.dart';

Widget buildAdminTextField(
    String label,
    TextEditingController c, {
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
    }) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    ),
  );
}