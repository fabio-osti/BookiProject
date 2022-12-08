import 'package:bookiapp/services/auth/firebase_auth_manager.dart';
import 'package:bookiapp/views/auth/login_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static const whiteText = TextStyle(color: Colors.white);
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    bool initialized = false;

  @override
  void initState() {
    FirebaseAuthManager.initialize().then((_) {
      setState(() {
        initialized = true;
      });
    });
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Booki',
        debugShowCheckedModeBanner: false,
        theme: getTheme(),
        home: initialized
          ? const LoginView()
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/books_pen_wallpaper.png"),
                ),
              ),
            ),
    );
  }

  ThemeData getTheme() {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromRGBO(225, 79, 0, 1),
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color.fromRGBO(225, 79, 0, 1),
        secondary: const Color.fromRGBO(225, 79, 0, 1),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: const TextTheme(
        headline1: MyApp.whiteText,
        headline2: MyApp.whiteText,
        headline3: MyApp.whiteText,
        headline4: MyApp.whiteText,
        subtitle1: MyApp.whiteText,
        subtitle2: MyApp.whiteText,
        bodyText1: MyApp.whiteText,
        bodyText2: MyApp.whiteText,
      ),
    );
  }
}
