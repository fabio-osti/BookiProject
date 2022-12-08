import 'package:bookiapp/helpers/cache.dart';
import 'package:bookiapp/utilities/loading/loading_screen.dart';
import 'package:bookiapp/services/accessors/book_accessor.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EpubReader extends StatefulWidget {
  final BookAccessor book;
  const EpubReader({Key? key, required this.book}) : super(key: key);

  @override
  State<EpubReader> createState() => _EpubReaderState();
}

class _EpubReaderState extends State<EpubReader> {
  bool isControllerReady = false;
  bool saving = false;
  late EpubController _epubController;
  late int index;

  @override
  void initState() {
    var fontSize = Cache.get.getDouble("fontSize") ?? 16;
    var letterSpacing = Cache.get.getDouble("letterSpacing") ?? 0;
    var wordSpacing = Cache.get.getDouble("wordSpacing") ?? 0;
    var height = Cache.get.getDouble("height") ?? 1.25;

    style = TextStyle(
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
    );

    index = widget.book.position;
    _epubController =
        EpubController(document: widget.book.document, index: index);

    if (kDebugMode) {
      print("Opening on $index");
    }

    if (_epubController.loadingState.value == EpubViewLoadingState.loading) {
      _epubController.loadingState.addListener(LoadingScreen().hide);
    }
    _beginSaving();
    setState(() {
      isControllerReady = true;
    });
    super.initState();
  }

  void _beginSaving() async {
    saving = true;
    while (saving) {
      var pos = _epubController.generateParagraphIndex();
      if (pos != null) {
        if (kDebugMode) {
          print("Current position: $pos");
        }

        widget.book.position = pos;
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  void dispose() {
    saving = false;
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isControllerReady
        ? Scaffold(
            appBar: AppBar(
              title: Text(widget.book.title),
              actions: [
                IconButton(
                  onPressed: showSettings,
                  icon: const Icon(Icons.settings),
                )
              ],
            ),
            drawer: Drawer(
              child: EpubViewTableOfContents(
                controller: _epubController,
              ),
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: EpubView(
                  builders: EpubViewBuilders<DefaultBuilderOptions>(
                    options: DefaultBuilderOptions(textStyle: style),
                    chapterDividerBuilder: (_) => const Divider(),
                  ),
                  controller: _epubController,
                ),
              ),
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  TextStyle style = const TextStyle(height: 1.25, fontSize: 16);

  void showSettings() {
    showDialog(
        context: context,
        builder: (context) {
          final controls = [
            TextEditingController(text: style.fontSize?.toString() ?? "16"),
            TextEditingController(text: style.letterSpacing?.toString() ?? "0"),
            TextEditingController(text: style.wordSpacing?.toString() ?? "0"),
            TextEditingController(text: style.height?.toString() ?? "1.25"),
          ];
          final fields = controls
              .map(
                (controller) => SizedBox(
                  width: 32,
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration.collapsed(hintText: ""),
                  ),
                ),
              )
              .toList();

          return SimpleDialog(
            contentPadding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  const Text("Tamanho da fonte: "),
                  const Spacer(),
                  fields[0],
                ],
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text("Espaçamento das letras: "),
                  const Spacer(),
                  fields[1],
                ],
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text("Espaçamento das palavras: "),
                  const Spacer(),
                  fields[2],
                ],
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text("Altura: "),
                  const Spacer(),
                  fields[3],
                ],
              ),
              const SizedBox(height: 4),
              const Divider(),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final fontSize = double.tryParse(controls[0].text) ?? 16;
                  final letterSpacing = double.tryParse(controls[1].text) ?? 0;
                  final wordSpacing = double.tryParse(controls[2].text) ?? 0;
                  final height = double.tryParse(controls[3].text) ?? 1.25;
                  Cache.get.setDouble("fontSize", fontSize);
                  Cache.get.setDouble("letterSpacing", letterSpacing);
                  Cache.get.setDouble("wordSpacing", wordSpacing);
                  Cache.get.setDouble("height", height);
                  setState(() {
                    style = TextStyle(
                      fontSize: fontSize,
                      letterSpacing: letterSpacing,
                      wordSpacing: wordSpacing,
                      height: height,
                    );
                  });
                  Navigator.of(context).pop();
                  for (var control in controls) {
                    control.dispose();
                  }
                },
                child: const Text("Salvar"),
              )
            ],
          );
        });
  }
}
