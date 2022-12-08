import 'package:bookiapp/services/accessors/book_accessor.dart';
import 'package:bookiapp/views/booki/book_showcase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:listenable_collections/listenable_set.dart';

enum Categories { home, fav, reading, search }


class BooksShowroom extends StatefulWidget {
  final Categories category;
  const BooksShowroom({Key? key, this.category = Categories.home})
      : super(key: key);

  @override
  State<BooksShowroom> createState() => _BooksShowroomState();
}

class _BooksShowroomState extends State<BooksShowroom> {
  _update() {
    setState(() {
      if (kDebugMode) {
        print("Updating ${widget.category}");
      }
      bookSet = getBooks();
    });
  }

  late ListenableSet<BookAccessor> bookSet;
  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    bookSet = getBooks();
    bookSet.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    bookSet.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GridView(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 333,
          mainAxisSpacing: 32,
          childAspectRatio: 0.66
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        children: bookSet.map((e) => BookShowcase(book: e)).toList(),
      ),
    );
  }

  ListenableSet<BookAccessor> getBooks() {
    switch (widget.category) {
      case Categories.home:
        return BookAccessor.home;
      case Categories.fav:
        return BookAccessor.favorites;
      case Categories.reading:
        return BookAccessor.reading;
      case Categories.search:
        return BookAccessor.search;
    }
  }
}
