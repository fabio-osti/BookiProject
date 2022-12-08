part of book_accessor;

const booksJson = [
  {
    "id": 1000,
    "title": "The Possessed (The Devils)",
    "author": "Dostoyevsky",
    "language": "en",
    "publisher": "Gutenberg Project",
    "published": "May 2005",
    "genres": ["Romance","Psicológico"],
    "synopsis":
        "A fictional town descends into chaos as it becomes the focal point of an attempted revolution, orchestrated by master conspirator Pyotr Verkhovensky. The mysterious aristocratic figure of Nikolai Stavrogin—Verkhovensky's counterpart in the moral sphere—dominates the book, exercising an extraordinary influence over the hearts and minds of almost all the other characters.",
  },
  {
    "id": 1001,
    "title": "O Hobbit",
    "author": "J.R.R Tolkien",
    "language": "pt",
    "publisher": "WMF",
    "published": "Jan 2013",
    "genres":["Aventura","Fantasia"],
    "synopsis":
        "Como a maioria dos hobbits, Bilbo Bolseiro leva uma vida tranquila até o dia em que recebe uma missão do mago Gandalf. Acompanhado por um grupo de anões, ele parte numa jornada até a Montanha Solitária para libertar o Reino de Erebor do dragão Smaug.",
  },
  {
    "id": 1002,
    "title": "As Crônicas de Nárnia",
    "author": "C.S Lewis",
    "language": "pt",
    "publisher": "WMF",
    "published": "Jan 2008",
    "genres":["Aventura","Fantasia","Alegórico"],
    "synopsis":
        "Os irmãos Lúcia, Susana, Edmundo e Pedro vivem na Inglaterra, em plena Segunda Guerra Mundial. Em uma de suas brincadeiras, descobrem um guarda-roupa mágico que leva ao mundo mágico de Nárnia. Habitado por seres estranhos, como centauros e gigantes, este lugar já foi pacífico, mas hoje vive sob a maldição da Feiticeira Branca, que o deixou como se sempre estivesse em um pesado inverno. Sob a orientação do leão Aslam, as crianças decidem ajudar na luta contra este domínio maligno.",
  },
  {
    "id": 1003,
    "title": "Ilíada e Odisseia",
    "author": "Homero",
    "language": "pt",
    "publisher": "Nova Fronteira",
    "published": "May 2015",
    "genres":["Clássico","Aventura"],
    "synopsis":
        "Ilíada narra a fúria do herói Aquiles e suas consequências trágicas durante a Guerra de Troia; Odisseia narra o retorno de Ulisses, o Odisseu, rei de Ítaca, após essa guerra. Essas narrativas são consideradas um simbolismo da aventura humana. "
  },
  {
    "id":1004,
    "title": "As Ideias Tem Consequências",
    "author": "Richard M. Weaver",
    "language": "pt",
    "publisher":"É Realizações",
    "published":"Jan 2016",
    "genres":["Filosofia","Conservador"],
    "synopsis":
      "Richard M. Weaver diagnostica impiedosamente as doenças de nossa época, oferecendo uma solução realista. Ele afirma que o mundo é inteligível e que o homem é livre. As catástrofes de nossa época não são produto da necessidade, mas de decisões pouco sábias. Uma cura, ele sugere, é possível. Ela encontra-se no uso correto da razão, na renovada aceitação de uma realidade absoluta e no reconhecimento de que as ideias, como as ações, têm consequências."
  },
  {
    "id":1005,
    "title": "Paradise Lost",
    "author": "John Milton",
    "language":"en",
    "publisher":"Project Gutenberg",
    "published":"Oct 1991",
    "genres":["Épico","Bíblico","Poesia"],
    "synopsis":
      "Paradise Lost is an epic poem (12 books, totalling more than 10,500 lines) written in blank verse, telling the biblical tale of the Fall of Mankind – the moment when Adam and Eve were tempted by Satan to eat the forbidden fruit from the Tree of Knowledge, and God banished them from the Garden of Eden forever."
  },
  
];

class MockBookAccessor implements BookAccessor {
  final BookProperties book;

  @override
  MockBookAccessor({required this.book});

  @override
  String get author => book.author;

  @override
  Future<Image> get cover => Future.value(Image.asset('assets/books/${book.id}.jpg'));

  @override
  Future<EpubBook> get document =>
      EpubDocument.openAsset('assets/books/${book.id}.epub');

  @override
  bool get favorite => book.favorite;

  @override
  set favorite(bool value) {
    book.favorite = value;
    Cache.get.setBool("fav(${book.id})", value);
    if (value) {
      BookAccessor.favorites.add(MockBookAccessor(book: book));
    } else {
      BookAccessor.favorites.remove(MockBookAccessor(book: book));
    }
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String get language => book.language;

  @override
  int get position => book.position;

  @override
  set position(int value) {
    if (value != book.position) {
      if (kDebugMode) {
        print("Overriding old position: ${book.position}");
      }

      Cache.get.setInt("pos(${book.id})", value);
      if (book.position == 0) {
        BookAccessor.reading.add(MockBookAccessor(book: book));
      }
      book.position = value;
    }
  }

  @override
  String get published => book.published;
  @override
  String get publisher => book.publisher;
  @override
  String get synopsis => book.synopsis;
  @override
  String get title => book.title;

  @override
  int get _id => book.id;

  @override
  bool operator ==(Object other) => other is BookAccessor && _id == other._id;

  static Future populateBookSets() async {
    await Cache.init();
    for (int i = 0; i < booksJson.length; i++) {
      final book = BookProperties.fromJson(booksJson[i]);
      BookAccessor.home.add(MockBookAccessor(book: book));

      final pos = Cache.get.getInt("pos($i)") ?? 0;
      book.position = pos;
      if (pos != 0) {
        BookAccessor.reading.add(MockBookAccessor(book: book));
      }

      final fav = Cache.get.getBool("fav($i)") ?? false;
      book.favorite = fav;
      if (fav) {
        BookAccessor.favorites.add(MockBookAccessor(book: book));
      }
    }
  }

  static Future search(String search) async {
    if (kDebugMode) {
      print("Searching:\n\t$search.");
    }

    BookAccessor.search.clear();
    final normalizedSearch = removeAccents(search).toUpperCase();
    BookAccessor.search.addAll(booksJson
        .where((e) =>
            removeAccents((e["author"] as String))
                .toUpperCase()
                .contains(normalizedSearch) ||
            removeAccents((e["title"] as String))
                .toUpperCase()
                .contains(normalizedSearch))
        .map((e) => MockBookAccessor(book: BookProperties.fromJson(e))));
  }
}
