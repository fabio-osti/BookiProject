import 'package:bookiapp/helpers/cache.dart';
import 'package:bookiapp/json/booki_root_json.dart';
import 'package:bookiapp/services/accessors/book_accessor.dart';
import 'package:bookiapp/utilities/dialogs/logout_dialog.dart';
import 'package:bookiapp/views/booki/books_showroom.dart';
import 'package:bookiapp/views/booki/search_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookiRoot extends StatefulWidget {
  const BookiRoot({Key? key}) : super(key: key);

  @override
  State<BookiRoot> createState() => _BookiRootState();
}

class _BookiRootState extends State<BookiRoot> {
  int activeTab = 0;
  bool cacheInitialized = false;
  bool booksInitialized = false;
  final user = FirebaseAuth.instance.currentUser;
  _AppState curState = _AppState.loading;

  @override
  void initState() {
    if (kDebugMode) {
      // ignore: avoid_print
      user!.getIdToken().then((value) => print(value));
    }

    Cache.init().then((value) => cacheInitialized = true);

    ApiBookAccessor.user = user;
    ApiBookAccessor.populateBookSets().then((_) {
      setState(() {
        booksInitialized = true;
      });
    }).catchError((e) {
      setState(() {
        curState = _AppState.error;
      });
      MockBookAccessor.populateBookSets().then((_) {
        setState(() {
          curState = _AppState.ready;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (booksInitialized && cacheInitialized && curState != _AppState.error) {
      curState = _AppState.ready;
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: _getNavBar(),
      body: _getBody(),
      floatingActionButton: kDebugMode
          ? FloatingActionButton(
              onPressed: () async {
                var scaffold = ScaffoldMessenger.of(context);
                var snackBar =
                    SnackBar(content: Text(await ApiBookAccessor.whoAmINow()));
                scaffold.showSnackBar(snackBar);
              },
              child: const Icon(Icons.question_mark),
            )
          : null,
      appBar: AppBar(
        title: SvgPicture.asset(
          "assets/images/logo.svg",
          fit: BoxFit.cover,
          height: 42,
        ),
        actions: [_getMenu(context)],
      ),
    );
  }

  PopupMenuButton<_MenuOptions> _getMenu(BuildContext context) {
    return PopupMenuButton(
      onSelected: ((value) {
        switch (value) {
          case _MenuOptions.logout:
            showLogOutDialog(context);
            break;
          default:
            break;
        }
      }),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _MenuOptions.logout,
          child: Text("Log out"),
        )
      ],
      child: const SizedBox(
        width: 48,
        child: Icon(Icons.more_vert),
      ),
    );
  }

  Widget _getBody() {
    switch (curState) {
      case _AppState.loading:
        return const Center(child: CircularProgressIndicator());
      case _AppState.ready:
        return IndexedStack(index: activeTab, children: const [
          BooksShowroom(
            category: Categories.home,
          ),
          BooksShowroom(
            category: Categories.fav,
          ),
          BooksShowroom(
            category: Categories.reading,
          ),
          SearchPage()
        ]);
      case _AppState.error:
        return const Center(child: Text("Error connecting to server. Falling back to local memory access."));
    }
  }

  Widget _getNavBar() {
    return BottomNavigationBar(
      items: items
          .map((e) => BottomNavigationBarItem(
                icon: Icon(e['icon']),
                label: e['text'],
              ))
          .toList(),
      currentIndex: activeTab,
      onTap: (index) {
        setState(() {
          activeTab = index;
        });
      },
      type: BottomNavigationBarType.fixed,
    );
  }
}

enum _MenuOptions { logout }

enum _AppState { loading, ready, error }
