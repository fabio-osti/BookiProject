import 'package:booki_administrator/helpers/dart/nulls.dart';
import 'package:booki_administrator/helpers/dart/translation_tables.dart';
import 'package:booki_administrator/models/book.dart';
import 'package:booki_administrator/repositories/books_repository.dart';
import 'package:booki_administrator/utilities/dialogs/error_dialog.dart';
import 'package:booki_administrator/views/booki/books_table.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

Future<void> buildForm(BuildContext context, Operation op, Book? initialValues,
    TableReader reader) {
  return showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(getOperationString(op)),
        contentPadding: const EdgeInsets.all(16),
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 400),
            child: BookForm(
              formType: op,
              initialValues: initialValues,
              reader: reader,
            ),
          )
        ],
      );
    },
  );
}

class BookForm extends StatefulWidget {
  const BookForm({
    Key? key,
    this.formType = Operation.create,
    this.initialValues,
    required this.reader,
  }) : super(key: key);
  final TableReader reader;
  final Operation formType;
  final Book? initialValues;

  @override
  State<BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {

  final _formKey = GlobalKey<FormBuilderState>();

  submit() {
    if (widget.formType == Operation.read) {
      widget.reader(filter: fieldsToBook(), isNewFilter: true);
    } else {
      var epubBytes = epubFile?.files.first.bytes;
      var coverBytes = coverFile?.files.first.bytes;
      if ((epubBytes == null || coverBytes == null) &&
          widget.formType == Operation.create) {
        showErrorDialog(context, "You must upload the book and cover files.");
        return;
      }
      BooksRepository.write(
              widget.formType, fieldsToBook(), epubBytes, coverBytes)
          .then((value) => widget.reader())
          .catchError((e) => showErrorDialog(context, e.toString()));
    }
    Navigator.of(context).pop();
  }

  Book fieldsToBook() {
    final fields = _formKey.currentState!.fields;
    return Book(
      id: int.tryParse(tryCast<String>(fields['id']?.value) ?? ""),
      title: tryCast<String>(fields['title']?.value),
      author: tryCast<String>(fields['author']?.value),
      language: tryCast<String>(fields['language']?.value),
      genres: tryCast<String>(fields['genres']?.value),
      publisher: tryCast<String>(fields['publisher']?.value),
      published: fields['monthPublished']?.value == null ||
              fields['yearPublished']?.value == null
          ? null
          : "${tryCast<String>(fields['monthPublished']?.value)} ${tryCast<String>(fields['yearPublished']?.value)}",
      synopsis: tryCast<String>(fields['synopsis']?.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      initialValue: widget.initialValues?.toFormJson() ?? {},
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            widget.formType == Operation.create
                ? Container()
                : FormBuilderTextField(
                    name: "id",
                    decoration: const InputDecoration(labelText: 'ID'),
                    readOnly: widget.formType == Operation.update,
                    enabled: widget.formType != Operation.update,
                  ),
            FormBuilderTextField(
              name: "title",
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            FormBuilderTextField(
              name: "author",
              decoration: const InputDecoration(labelText: 'Autor'),
            ),
            FormBuilderTextField(
              name: "genres",
              decoration: const InputDecoration(
                  labelText: 'Generos', hintText: "Separe os gêneros com ';'"),
            ),
            FormBuilderTextField(
              name: "synopsis",
              decoration: const InputDecoration(labelText: 'Sinopse'),
              minLines: 1,
              maxLines: 6,
            ),
            FormBuilderTextField(
              name: "publisher",
              decoration: const InputDecoration(labelText: 'Editora'),
            ),
            Row(
              children: [
                Flexible(
                  child: FormBuilderDropdown(
                      name: "monthPublished",
                      decoration:
                          const InputDecoration(labelText: "Mês de publicação"),
                      items: threeLettersMonths.entries
                          .map((e) => DropdownMenuItem<String>(
                                value: e.key,
                                child: Text(e.value),
                              ))
                          .toList()),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: FormBuilderTextField(
                    name: "yearPublished",
                    decoration:
                        const InputDecoration(labelText: "Ano de publicação"),
                  ),
                ),
              ],
            ),
            FormBuilderDropdown(
                name: "language",
                decoration: const InputDecoration(labelText: 'Linguagem'),
                items: twoLettersLangs.entries
                    .map((e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList()),
            const SizedBox(height: 16),
            widget.formType != Operation.read ? uploadButtons : Container(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: submit,
              // onPressed: () => Navigator.of(context).pop(),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(
                  const Size(124, 48),
                ),
              ),
              child: Text(getOperationString(widget.formType)),
            )
          ],
        ),
      ),
    );
  }

  FilePickerResult? epubFile;
  FilePickerResult? coverFile;
  Row get uploadButtons {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: coverFile == null ? null : Colors.greenAccent,
            ),
            child: Column(children: const [
              Icon(Icons.upload_outlined),
              Text("Upload the JPG cover")
            ]),
            onPressed: () => FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ["jpg"],
            ).then(
              (value) => setState(() {
                coverFile = value;
              }),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: epubFile == null ? null : Colors.greenAccent,
            ),
            child: Column(children: const [
              Icon(Icons.upload_outlined),
              Text("Upload the EPUB book")
            ]),
            onPressed: () => FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ["epub"],
            ).then((value) => setState(() {
                  epubFile = value;
                })),
          ),
        )
      ],
    );
  }
}
