import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required Text title,
  required Text content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title,
        content: content,
        actionsAlignment: MainAxisAlignment.center,
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return ElevatedButton(
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(
                const Size(0, 48),
              ),
            ),
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}
