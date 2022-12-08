using BookiApi.Helpers;
using System.Diagnostics.CodeAnalysis;

namespace BookiApi.Models;

public class BookDto
{
	public int? Id { get; set; }
	public string? Title { get; set; }
	public string? Author { get; set; }
	public List<string>? Genres { get; set; }
	public string? Published { get; set; }
	public string? Publisher { get; set; }
	public string? Synopsis { get; set; }
	public string? Language { get; set; }
	public int? Position { get; set; }
	public bool? Favorite { get; set; }

	public BookDto() { }

	public bool IsEmpty() =>
		Id == null 
		&& Title == null 
		&& Author == null 
		&& Published == null 
		&& Publisher == null 
		&& Synopsis == null 
		&& Language == null 
		&& Genres == null;


	static public BookDto FromUserBook(UserBook book) => new()
	{
		Id = book.Book.BookId,
		Title = book.Book.Title,
		Author = book.Book.Author,
		Genres = book.Book.Genres.ToList(),
		Published = book.Book.PublishedOn,
		Publisher = book.Book.Publisher,
		Synopsis = book.Book.Synopsis,
		Language = book.Book.Language.ToString(),
		Position = book.ReadingPosition,
		Favorite = book.IsFavorite
	};

	static public BookDto FromBookWith(Book book, int position, bool isFavorite) => new()
	{
		Id = book.BookId,
		Title = book.Title,
		Author = book.Author,
		Genres = book.Genres,
		Published = book.PublishedOn,
		Publisher = book.Publisher,
		Synopsis = book.Synopsis,
		Language = book.Language.ToString(),
		Position = position,
		Favorite = isFavorite
	};

	static public BookDto FromBook(Book book) => new()
	{
		Id = book.BookId,
		Title = book.Title,
		Author = book.Author,
		Genres = book.Genres,
		Published = book.PublishedOn,
		Publisher = book.Publisher,
		Synopsis = book.Synopsis,
		Language = book.Language.ToString(),
		Position = null,
		Favorite = null
	};

	public Book ToBook() => new(
		Id ?? 0,
		Title.ThrowIfNull(nameof(Title)),
		Author.ThrowIfNull(nameof(Author)),
		Genres.ThrowIfNull(nameof(Genres)),
		Published.ThrowIfNull(nameof(Published)),
		Publisher.ThrowIfNull(nameof(Publisher)),
		Synopsis.ThrowIfNull(nameof(Synopsis)),
		new(Language.ThrowIfNull(nameof(Language))));

	public UserBook ToUserBook(string uid) => new(
		ToBook(), uid, Favorite ?? false, Position ?? 0
	);
}