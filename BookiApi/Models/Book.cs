using NpgsqlTypes;
using System.Globalization;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;

namespace BookiApi.Models;

public class Book
{
	public Book(
		int bookId,
		string title,
		string author,
		List<string> genres,
		string publishedOn,
		string publisher,
		string synopsis,
		CultureInfo language
	)
	{
		BookId = bookId;
		Title = title;
		Author = author;
		Genres = genres;
		PublishedOn = publishedOn;
		Publisher = publisher;
		Synopsis = synopsis;
		Language = language;
		UserBooks = new();
	}

	public int BookId { get; set; }
	public string Title { get; set; }
	public string Author { get; set; }
	public List<string> Genres { get; set; }
	public string PublishedOn { get; set; }
	public string Publisher { get; set; }
	public string Synopsis { get; set; }
	public CultureInfo Language { get; set; }

	[JsonIgnore]
	public List<UserBook> UserBooks { get; set; }
	[JsonIgnore]
	public NpgsqlTsVector? SearchVector { get; set; }

}
