import 'package:bookiapp/services/accessors/book_accessor.dart';
import 'package:bookiapp/views/booki/books_showroom.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _search;
  bool error = false;

  @override
  void initState() {
    _search = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          _getSearchBox(),
          Flexible(
            child: error
                ? const Center(child: Text("Error connecting to server. Falling back to memory search."))
                : const BooksShowroom(category: Categories.search),
          )
        ],
      ),
    );
  }

  Container _getSearchBox() {
    return Container(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1024, maxHeight: 100),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              flex: 3,
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(hintText: "Pesquisar"),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    ApiBookAccessor.search(_search.text)
                      .catchError((e) {
                        setState(() {
                          error = true;
                        });
                        MockBookAccessor.search(_search.text);
                      });
                  },
                  style:
                      ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                  child: const Icon(Icons.search),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
