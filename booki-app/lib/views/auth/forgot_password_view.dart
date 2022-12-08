import 'package:bookiapp/services/auth/firebase_auth_manager.dart';
import 'package:bookiapp/utilities/dialogs/error_dialog.dart';
import 'package:bookiapp/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _email;

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  submit() {
    final email = _email.text;
    FirebaseAuthManager.sendPasswordReset(email)
        .onError((e, _) => showErrorDialog(
              context,
              "Não foi possível processar a sua requisição. Cadastro possivelmente não existente.",
            ));
    showPasswordResetSentDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/books_pen_wallpaper.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset(
                      "assets/images/logo.svg",
                      alignment: AlignmentDirectional.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(128, 0, 0, 0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofocus: true,
                      controller: _email,
                      decoration: const InputDecoration(
                        hintText: "Email",
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) {
                        submit();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: submit,
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                        const Size(124, 48),
                      ),
                    ),
                    child: const Text(
                      "Recuperar",
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                        const Size(124, 48),
                      ),
                    ),
                    child: const Text("Voltar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
