import 'package:booki_administrator/utilities/dialogs/logout_dialog.dart';
import 'package:booki_administrator/views/booki/books_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookiAdministratorRoot extends StatefulWidget {
  const BookiAdministratorRoot({Key? key}) : super(key: key);

  @override
  State<BookiAdministratorRoot> createState() => _BookiAdministratorRootState();
}

class _BookiAdministratorRootState extends State<BookiAdministratorRoot> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const BooksTable(),
      appBar: AppBar(
        title: SvgPicture.asset(
          "assets/images/logo_admin.svg",
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
}

enum _MenuOptions { logout }
