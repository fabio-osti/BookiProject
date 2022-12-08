import 'package:booki_administrator/models/book.dart';

class Payload {
  int entriesCount;
  List<Book> content;

  Payload({required this.entriesCount, required this.content});

  Payload.fromJson(Map json)
      : assert(json["entriesCount"] is int),
        assert(json["content"] is List),
        entriesCount = json["entriesCount"],
        content = (json["content"] as List).whereType<Map>().map((e) => Book.fromJson(e)).toList();

  Map toJson() {
    return {"entriesCount": entriesCount, "content": content};
  }
}
