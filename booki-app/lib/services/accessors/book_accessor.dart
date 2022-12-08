library book_accessor;
import 'dart:convert';

import 'package:bookiapp/helpers/cache.dart';
import 'package:bookiapp/helpers/nulls.dart';
import 'package:bookiapp/helpers/strings.dart';
import 'package:bookiapp/models/book_properties.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:listenable_collections/listenable_set.dart';
import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart' show EpubBook, EpubDocument;
import 'package:http/http.dart' as http;
part 'mock_book_accessor.dart';
part 'api_book_accessor.dart';

abstract class BookAccessor {
  int get _id;
  String get title;
  Future<Image> get cover;
  Future<EpubBook> get document;
  String get author;
  String get language;
  String get publisher;
  String get published;
  String get synopsis;
  set favorite(bool value);
  bool get favorite;
  set position(int value);
  int get position;

  static final home = ListenableSet<BookAccessor>();
  static final favorites = ListenableSet<BookAccessor>();
  static final reading = ListenableSet<BookAccessor>();
  static final search = ListenableSet<BookAccessor>();
}