import 'package:booki_administrator/services/auth/firebase_auth_manager.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/books_pen_wallpaper.png"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(128, 0, 0, 0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                  child: const Text(
                    "Um email de verificação foi enviado. Se você ainda não o recebeu, pressione o botão abaixo!",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuthManager.sendEmailVerification();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      const Size(124, 48),
                    ),
                  ),
                  child: const Text(
                    "Enviar email",
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                      const Size(124, 48),
                    ),
                  ),
                  child: const Text(
                    "Voltar",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
