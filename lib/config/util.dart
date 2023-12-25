import 'package:flutter/material.dart';

class Util {
  static showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static showDialogAlert(BuildContext context, String title, String content,
      void Function() onPositiveButtonClicked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: onPositiveButtonClicked,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
            child: const Text(
              'Hapus',
            ),
          ),
        ],
      ),
    );
  }
}