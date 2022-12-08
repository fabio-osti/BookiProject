import 'package:booki_administrator/helpers/dart/nulls.dart';
import 'package:booki_administrator/helpers/dart/translation_tables.dart';
import 'package:booki_administrator/models/book.dart';
import 'package:booki_administrator/repositories/books_repository.dart';
import 'package:booki_administrator/utilities/dialogs/generic_dialog.dart';
import 'package:booki_administrator/views/booki/book_form.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:booki_administrator/models/payload.dart';

typedef TableReader = Function({Book? filter, bool isNewFilter});

class BooksTable extends StatefulWidget {
  const BooksTable({Key? key}) : super(key: key);

  @override
  State<BooksTable> createState() => _BooksTableState();
}

class _BooksTableState extends State<BooksTable> {
  static const splashSize = 16.0;

  @override
  void initState() {
    reader = ({Book? filter, bool isNewFilter = false}) {
      BooksRepository.read(itemsPerPage, curPage, filter, isNewFilter)
          .then((value) => setState(() => curPayload = value))
          .catchError((e) => null);
    };
    reader(isNewFilter: true);
    super.initState();
  }

  late TableReader reader;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        headMaxWidth =
            tryCast<RenderBox>(tableKey.currentContext?.findRenderObject())
                    ?.size
                    .width ??
                double.infinity;
      });
    });
    tryCast<RenderBox>(tableKey.currentContext?.findRenderObject())?.size.width;
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/typewriter_background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: getTableContainer(
        MediaQuery.of(context).size.width,
        Column(
          children: [
            tableHead,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  key: tableKey,
                  headingTextStyle: Theme.of(context).textTheme.titleLarge,
                  columns: const [
                    DataColumn(label: Text("ID")),
                    DataColumn(label: Text("Titulo")),
                    DataColumn(label: Text("Autor")),
                    DataColumn(label: Text("Editora")),
                    DataColumn(label: Text("Publicação")),
                    DataColumn(label: Text("Linguagem")),
                    DataColumn(label: Text("Ações"))
                  ],
                  rows: tableBody,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  final tableKey = GlobalKey();

  var headMaxWidth = double.infinity;
  changePage(int add) {
    setState(() {
      curPage += add;
    });
    reader();
  }
  Container get tableHead => Container(
        constraints: BoxConstraints(maxWidth: headMaxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                buildForm(context, Operation.create, null, reader);
              },
              icon: const Icon(Icons.library_add_outlined),
              splashRadius: splashSize,
            ),
            IconButton(
              onPressed: () {
                buildForm(context, Operation.read, null, reader);
              },
              icon: const Icon(Icons.search_outlined),
              splashRadius: splashSize,
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Container(
                  constraints: const BoxConstraints(maxWidth: 64),
                  child: FormBuilderDropdown<int>(
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0)),
                    name: "per_page",
                    initialValue: 8,
                    onChanged: (v) {
                      itemsPerPage = v!;
                      reader();
                    },
                    items: [4, 8, 16, 32]
                        .map((v) => DropdownMenuItem(
                            value: v, child: Text(v.toString())))
                        .toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left_outlined),
                  onPressed:
                      curPage == 1 ? null : () => changePage(-1),
                  splashRadius: _BooksTableState.splashSize,
                ),
                Text(curPage.toString()),
                IconButton(
                  icon: const Icon(Icons.chevron_right_outlined),
                  onPressed: curPage == maxPage
                      ? null
                      : () => changePage(1),
                  splashRadius: _BooksTableState.splashSize,
                )
              ],
            ),
          ],
        ),
      );

  Payload? curPayload;
  List<DataRow> get tableBody =>
      curPayload?.content
          .map(
            (e) => DataRow(
              cells: [
                DataCell(Text(e.id.toString())),
                DataCell(Text(e.title!)),
                DataCell(Text(e.author!)),
                DataCell(Text(e.publisher!)),
                DataCell(Text(e.published!)),
                DataCell(Text(twoLettersLangs[e.language!]!)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () =>
                            buildForm(context, Operation.update, e, reader),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          deleteDialogFactory(e);
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
          .toList() ??
      [
        const DataRow(cells: [
          DataCell(Text("..."), placeholder: true),
          DataCell(Text("..."), placeholder: true),
          DataCell(Text("..."), placeholder: true),
          DataCell(Text("..."), placeholder: true),
          DataCell(Text("..."), placeholder: true),
          DataCell(Text("..."), placeholder: true),
          DataCell(Text("..."), placeholder: true),
        ]),
      ];

  Future<bool> deleteDialogFactory(Book e) {
    return showGenericDialog<bool>(
      context: context,
      title: const Text("Deletar"),
      content: Text(
          "Você tem certeza que deseja deletar o livro de ID: ${e.id.toString()}?"),
      optionsBuilder: () => {
        "Cancelar": false,
        "Confirmar": true,
      },
    ).then(
      (value) {
        if (value ?? false) {
          BooksRepository.write(Operation.delete, e, null, null)
              .then(reader());
        }
        var ref = FirebaseStorage.instance.ref();
        ref.child("epubs/${e.id.toString()}.epub").delete().catchError((_) {});
        ref.child("covers/${e.id.toString()}.jpg").delete().catchError((_) {});
        return value ?? false;
      },
    );
  }

  var curPage = 1;
  var itemsPerPage = 8;
  int get maxPage => ((curPayload?.entriesCount ?? 1) / itemsPerPage).ceil();

  Widget getTableContainer(double screenWidth, Widget child) {
    return screenWidth < (headMaxWidth + 148)
        ? Container(
            constraints: BoxConstraints(minWidth: screenWidth),
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(164, 0, 0, 0),
            ),
            child: child,
          )
        : Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(maxWidth: headMaxWidth + 148),
            decoration: const BoxDecoration(
              color: Color.fromARGB(164, 0, 0, 0),
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            alignment: Alignment.center,
            child: child,
          );
  }
}
