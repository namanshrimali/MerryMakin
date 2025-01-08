import 'package:flutter/material.dart';
import '../widgets/pro_text.dart';

showSnackBar(BuildContext context, String content) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: ProText(content)));
  }
}
