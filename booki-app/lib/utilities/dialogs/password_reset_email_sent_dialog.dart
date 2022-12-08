import 'package:bookiapp/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: const Text("Redefinição de senha"),
    content: const Text(
        "Nós lhe enviamos um link para que você redefina a sua senha. "
        "Por favor, verifique o seu email para mais informações."),
    optionsBuilder: () => {
      "Ok": null,
    },
  );
}
