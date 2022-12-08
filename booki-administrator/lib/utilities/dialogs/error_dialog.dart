import 'package:booki_administrator/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';


Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: const Text("Um erro ocorreu"),
    content: Text(text),
    optionsBuilder: () => {
      "Ok": null,
    },
  );
}