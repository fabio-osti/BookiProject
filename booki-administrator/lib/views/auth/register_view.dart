import 'package:booki_administrator/services/auth/auth_exceptions.dart';
import 'package:booki_administrator/services/auth/firebase_auth_manager.dart';
import 'package:booki_administrator/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  submit() {

    FirebaseAuthManager.createUser(_email.text, _password.text)
        .then(
      (value) => Navigator.of(context).pop(),
    )
        .onError<AuthException>(
      (e, _) {
        switch (e.problem) {
          case AuthProblem.weakPassword:
            showErrorDialog(
              context,
              "Senha insegura.",
            );
            break;
          case AuthProblem.emailInUse:
            showErrorDialog(
              context,
              "Email já cadastrado.",
            );
            break;
          case AuthProblem.invalidEmail:
            showErrorDialog(
              context,
              "Email inválido.",
            );
            break;
          default:
          showErrorDialog(
              context,
              "O cadastro falhou. Tente novamente.",
            );
        }
      },
    );
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
                      "assets/images/logo_admin.svg",
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
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          enableSuggestions: false,
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email",
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            hintText: "Senha",
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            submit();
                          },
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: submit,
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                              const Size(124, 48),
                            ),
                          ),
                          child: const Text("Cadastrar"),
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
                ],
              ),
            ),
          ),
        ),
      );
  }
}
