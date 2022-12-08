using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.Json.Serialization;

namespace BookiApi.Models;

public class UserBook
{

	public string Uid { get; set; }
	public int BookId { get; set; }
	public Book Book { get; set; }

#pragma warning disable CS8618
	private UserBook() { }
#pragma warning restore CS8618

	public UserBook(Book book, string uid, bool isFavorite = false, int readingPosition = 0)
	{
		Book = book;
		BookId = book.BookId;
		Uid = uid;
		IsFavorite = isFavorite;
		ReadingPosition = readingPosition;
	}

	public bool IsFavorite { get; set; }
	public int ReadingPosition { get; set; }

}