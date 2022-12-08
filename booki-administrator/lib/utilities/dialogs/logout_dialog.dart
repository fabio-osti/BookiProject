import 'package:booki_administrator/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: const Text("Sair"),
    content: const Text("Você tem certeza que deseja sair?"),
    optionsBuilder: () => {
      "Cancelar": false,
      "Sair": true,
    },
  ).then(
    (value) {
      if (value ?? false) {
        Navigator.of(context).pop();
      }
      return value ?? false;
    },
  );
}
