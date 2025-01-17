import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/pro_text.dart';


Future<bool> openConfirmationForDeletion(BuildContext context, String? deleteMessage) async {
    // Show a confirmation dialog
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const ProText('Confirm Delete'),
          content: deleteMessage == null || deleteMessage.isEmpty? const ProText(defaultDeleteConfirmationText): ProText(deleteMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the delete
              },
              child: const ProText('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the delete
              },
              child: const ProText('Delete'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }