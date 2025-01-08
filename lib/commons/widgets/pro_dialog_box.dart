import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/pro_text.dart';


Future<bool> openConfirmationForDeletion(BuildContext context, String? deleteMessage) async {
    // Show a confirmation dialog
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: deleteMessage == null || deleteMessage.isEmpty? const Text(defaultDeleteConfirmationText): ProText(deleteMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the delete
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the delete
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }