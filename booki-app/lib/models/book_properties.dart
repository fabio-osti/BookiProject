class BookProperties {
  final int id;
  final String title;
  final String author;
  final String language;
  final String publisher;
  final String published;
  final String synopsis;
  int position;
  bool favorite;

  BookProperties({
    required this.id,
    required this.title,
    required this.author,
    required this.language,
    required this.publisher,
    required this.published,
    required this.synopsis,
    this.position = 0,
    this.favorite = false,
  });

  BookProperties.fromJson(Map json)
      : assert(json['id'] is int),
        assert(json['title'] is String),
        assert(json['author'] is String),
        assert(json['language'] is String),
        assert(json['publisher'] is String),
        assert(json['published'] is String),
        assert(json['synopsis'] is String),
        assert(json['position'] is int?),
        assert(json['favorite'] is bool?),
        id = json['id']!,
        title = json['title']!,
        author = json['author']!,
        language = json['language']!,
        publisher = json['publisher']!,
        published = json['published']!,
        synopsis = json['synopsis']!,
        position = json['position'] ?? 0,
        favorite = json['favorite'] ?? false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'id': id,
      'title': title,
      'author': author,
      'language': language,
      'publisher': publisher,
      'published': published,
      'synopsis': synopsis,
      'position': position,
      'favorite': favorite,
    };
    return data;
  }
}
