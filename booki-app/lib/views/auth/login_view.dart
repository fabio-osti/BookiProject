import 'package:bookiapp/services/auth/auth_exceptions.dart';
import 'package:bookiapp/services/auth/firebase_auth_manager.dart';
import 'package:bookiapp/utilities/dialogs/error_dialog.dart';
import 'package:bookiapp/utilities/loading/loading_screen.dart';
import 'package:bookiapp/views/auth/forgot_password_view.dart';
import 'package:bookiapp/views/auth/register_view.dart';
import 'package:bookiapp/views/auth/verify_email_view.dart';
import 'package:bookiapp/views/booki/booki_root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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

  void submit() {
    LoadingScreen().show(context: context, text: "Seu login está sendo realizado.");
    FirebaseAuthManager.logIn(_email.text, _password.text)
        .then((_) {
          LoadingScreen().hide();
          return Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const BookiRoot()));
        })
        .onError<AuthException>((e, _) {
      switch (e.problem) {
        case AuthProblem.emailUnverified:
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const VerifyEmailView(),
          ));
          break;
        case AuthProblem.userUnauthorized:
          showErrorDialog(
            context,
            "Conta não administradora, solicite acesso ao responsável apropriado!",
          );
          break;
        case AuthProblem.userNotFound:
          showErrorDialog(
            context,
            "Email não cadastrado.",
          );
          break;
        case AuthProblem.wrongPassword:
          showErrorDialog(
            context,
            "Senha incorreta.",
          );
          break;
        default:
          showErrorDialog(
            context,
            "Erro de Autenticação.",
          );
      }
    });
    _email.clear();
    _password.clear();
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
                SvgPicture.asset("assets/images/logo.svg"),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ForgotPasswordView(),
                          ));
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text("Esqueci a minha senha"),
                      ),
                    ],
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
                  child: const Text("Login"),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegisterView(),
                    ));
                  },
                  style: ButtonStyle(
                      minimumSize:
                          MaterialStateProperty.all(const Size(124, 48))),
                  child: const Text("Cadastre-se"),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
