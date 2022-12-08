class Book {
  List<String>? _genres;
  String? get genres => _genres?.join(";");
  set genres(String? value) => _genres = value?.split(";");

  final int? id;
  final String? title;
  final String? author;
  final String? language;
  final String? publisher;
  final String? published;
  final String? synopsis;

  Book({
    this.id,
    this.title,
    this.author,
    this.language,
    String? genres,
    this.publisher,
    this.published,
    this.synopsis,
  }) :
    _genres = genres?.split(";");
  

  Book.fromJson(Map json)
      : assert(json['id'] is int),
        assert(json['title'] is String),
        assert(json['author'] is String),
        assert(json['language'] is String),
        assert(json['genres'] is List),
        assert(json['publisher'] is String),
        assert(json['published'] is String),
        assert(json['synopsis'] is String),
        id = json['id']!,
        title = json['title']!,
        author = json['author']!,
        language = json['language']!,
        publisher = json['publisher']!,
        published = json['published']!,
        synopsis = json['synopsis']!,
        _genres = (json['genres'] as List).whereType<String>().toList();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'author': author,
      'language': language,
      'publisher': publisher,
      'genres': _genres,
      'published': published,
      'synopsis': synopsis,
    };
  }

  Map<String, dynamic> toFormJson() {
    var publishedComposite = published?.split(" ");
    return <String, dynamic>{
      'id': id.toString(),
      'title': title,
      'author': author,
      'language': language,
      'publisher': publisher,
      'genres': genres,
      'monthPublished': publishedComposite?[0],
      'yearPublished': publishedComposite?[1],
      'synopsis': synopsis,
    };
  }
}
