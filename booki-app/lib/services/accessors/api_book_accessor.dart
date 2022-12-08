part of book_accessor;

class ApiBookAccessor implements BookAccessor {
  static User? user;
  static String _baseUrl = "";
  static Future? _baseUrlInit;
  static Future<http.Response> _easyGet(String route) async {
    _baseUrlInit = _baseUrlInit ??
        FirebaseStorage.instance.ref().child("api-address.txt").getData().then(
          (value) {
            if (value == null) return;
            _baseUrl = "${utf8.decode(value)}/booki-app/";
            if (kDebugMode) {
              print(_baseUrl);
            }
          },
        );
    await _baseUrlInit;
    return await http.get(Uri.parse(_baseUrl + route), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${await user!.getIdToken()}"
    });
  }

  static Future<String> whoAmINow() async {
    final response = await _easyGet("AuthPing");
    final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return "Id: '${jsonResponse["value"]} at '${jsonResponse["now"]}'";
  }

  static Future populateBookSets() async {
    final response = await _easyGet("PopulateBookSets");
    final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    BookAccessor.home.addAll((jsonResponse["home"] as List<dynamic>)
        .whereType<Map>()
        .map<BookAccessor>(ApiBookAccessor.fromJson));

    BookAccessor.favorites.addAll((jsonResponse["favorites"] as List<dynamic>)
        .whereType<Map>()
        .map<BookAccessor>(ApiBookAccessor.fromJson));

    BookAccessor.reading.addAll((jsonResponse["reading"] as List<dynamic>)
        .whereType<Map>()
        .map<BookAccessor>(ApiBookAccessor.fromJson));
  }

  static Future search(String search) async {
    final response = await _easyGet("SearchBook?search=$search");

    final jsonResponse =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;

    BookAccessor.search.clear();
    BookAccessor.search.addAll(jsonResponse
        .whereType<Map>()
        .map<BookAccessor>(ApiBookAccessor.fromJson));
  }

  ApiBookAccessor(this.props);
  factory ApiBookAccessor.fromJson(Map e) =>
      ApiBookAccessor(BookProperties.fromJson(e));

  final BookProperties props;

  @override
  String get author => props.author;

  @override
  Future<Image> get cover async {
    final storageRef = FirebaseStorage.instance.ref();
    final pathReference = storageRef.child("covers/${props.id.toString()}.jpg");

    return Image.memory(
        throwIfNull(await pathReference.getData(20971520), "Download error"));
  }

  @override
  Future<EpubBook> get document async {
    final storageRef = FirebaseStorage.instance.ref();
    final pathReference = storageRef.child("epubs/${props.id.toString()}.epub");

    return EpubDocument.openData(
        throwIfNull(await pathReference.getData(20971520), "Download error"));
  }

  @override
  bool get favorite => props.favorite;

  @override
  set favorite(bool favorite) {
    if (favorite) {
      BookAccessor.favorites.add(this);
    } else {
      BookAccessor.favorites.remove(this);
    }

    props.favorite = favorite;
    user!.getIdToken().then((value) => _easyGet(
        "UpdateBookFavorite?bookId=${props.id}&newIsFavorite=$favorite"));
  }

  @override
  int get position => props.position;

  @override
  set position(int position) {
    if (props.position != position) {
      if (props.position == 0) {
        BookAccessor.reading.add(this);
      }
      props.position = position;
      user!.getIdToken().then((value) => _easyGet(
          "UpdateBookPosition?bookId=${props.id}&newPosition=$position"));
    }
  }

  @override
  String get language => props.language;

  @override
  String get published => props.published;

  @override
  String get publisher => props.publisher;

  @override
  String get synopsis => props.synopsis;

  @override
  String get title => props.title;

  @override
  int get _id => props.id;

  @override
  operator ==(Object other) => other is BookAccessor && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
