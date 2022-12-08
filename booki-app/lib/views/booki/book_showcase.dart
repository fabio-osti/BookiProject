import 'package:bookiapp/utilities/loading/loading_screen.dart';
import 'package:bookiapp/services/accessors/book_accessor.dart';
import 'package:bookiapp/views/booki/epub_reader.dart';
import 'package:flutter/material.dart';

class BookShowcase extends StatefulWidget {
  final BookAccessor book;

  const BookShowcase({
    required this.book,
    Key? key,
    List<VoidCallback>? listeners,
  }) : super(key: key);

  @override
  State<BookShowcase> createState() => _BookShowcaseState();
}

class _BookShowcaseState extends State<BookShowcase> {
  Image? cover;

  @override
  initState() {
    widget.book.cover.then((value) => setState((() => cover = value)));
    super.initState();
  }

  StatefulBuilder _builder(BuildContext context) => StatefulBuilder(
        builder: (statefulContext, setState) => Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              children: [
                Row(
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.book.title,
                              style: Theme.of(context).textTheme.headline3),
                          Text(widget.book.author,
                              style: Theme.of(context).textTheme.headline5),
                          Text(
                              "${widget.book.publisher} (${widget.book.published})"),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(
                          () => widget.book.favorite = !widget.book.favorite),
                      icon: Icon(
                        Icons.favorite,
                        color: widget.book.favorite ? Colors.red : Colors.grey,
                      ),
                      iconSize: 64,
                    ),
                  ],
                ),
                const Divider(),
                Text(widget.book.synopsis),
                Center(
                  child: TextButton(
                    onPressed: () => read(statefulContext),
                    child: Text(
                      "LER",
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(foreground: null, color: Colors.deepOrange),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<dynamic> read(BuildContext statefulContext) {
    LoadingScreen().show(context: context, text: "Baixando o livro");
    return Navigator.push(
      statefulContext,
      MaterialPageRoute(
        builder: (context) => EpubReader(
          book: widget.book,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: cover ?? const CircularProgressIndicator(),
      onPressed: () {
        showModalBottomSheet<void>(context: context, builder: _builder);
      },
    );
  }
}
