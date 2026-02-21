import 'package:flutter/material.dart';

class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required List<AppDialogAction> actions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions
            .map(
              (a) => a.isButton
                  ? ElevatedButton(
                      onPressed: () => Navigator.pop(context, a.value),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: a.color ?? const Color(0xFF1E88E5),
                        elevation: 0,
                      ),
                      child: Text(
                        a.label,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  : TextButton(
                      onPressed: () => Navigator.pop(context, a.value),
                      child: Text(a.label, style: TextStyle(color: a.color)),
                    ),
            )
            .toList(),
      ),
    );
  }
}

class AppDialogAction {
  final String label;
  final dynamic value;
  final bool isButton;
  final Color? color;

  const AppDialogAction({
    required this.label,
    required this.value,
    this.isButton = false,
    this.color,
  });
}
