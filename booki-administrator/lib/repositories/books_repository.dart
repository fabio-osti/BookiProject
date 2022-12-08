import 'dart:convert';
import 'dart:typed_data';

import 'package:booki_administrator/models/book.dart';
import 'package:booki_administrator/models/payload.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BooksRepository {
  static User? user = FirebaseAuth.instance.currentUser;
  static Future? _baseUrlInit;
  static String _baseUrl = "";
  static Future<http.Response> _easyPost(String route, Map body) async {
    _baseUrlInit = _baseUrlInit ??
        FirebaseStorage.instance.ref().child("api-address.txt").getData().then(
          (value) {
            if (value == null) return;
            _baseUrl = "${utf8.decode(value)}/booki-admin/";
            if (kDebugMode) {
              print(_baseUrl);
            }
          },
        );
    await _baseUrlInit;
    return http.post(
        Uri.parse(_baseUrl + route),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
          "Authorization": "Bearer ${await user!.getIdToken()}"
        },
        body: jsonEncode(body),
      );
  }

  static Future<http.Response> write(
      Operation op, Book book, Uint8List? epub, Uint8List? cover) async {
    final response =
        _easyPost(operationString[op] ?? "", book.toJson());
    if (op != Operation.delete) {
      response.then(
        (value) async {
          if (epub == null && cover == null) return;

          final book = Book.fromJson(jsonDecode(utf8.decode(value.bodyBytes)));
          var ref = FirebaseStorage.instance.ref();
          if (epub != null) {
            await ref.child('epubs/${book.id.toString()}.epub').putData(
                epub, SettableMetadata(contentType: "application/epub+zip"));
          }

          if (cover != null) {
            await ref
                .child('covers/${book.id.toString()}.jpg')
                .putData(cover, SettableMetadata(contentType: "image/jpeg"));
          }
        },
      );
    }
    return response;
  }

  static Book? _curFilter;
  static Future<Payload> read(
    int amount,
    int page, [
    Book? filter,
    bool isNewFilter = false,
  ]) async {
    if (isNewFilter) {
      _curFilter = filter;
    }
    return Payload.fromJson(
      jsonDecode(
        utf8.decode((await _easyPost(
          "Read?amount=$amount&page=$page",
          (_curFilter?.toJson() ?? {}),
        ))
            .bodyBytes),
      ),
    );
  }
}

enum Operation { create, read, update, delete }

const operationString = {
  Operation.create: "Create",
  Operation.read: "Read",
  Operation.update: "Update",
  Operation.delete: "Delete"
};

String getOperationString(Operation op) {
  switch (op) {
    case Operation.create:
      return "Create";
    case Operation.read:
      return "Read";
    case Operation.update:
      return "Update";
    case Operation.delete:
      return "Delete";
  }
}
