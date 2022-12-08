using BookiApi.Contexts;
using BookiApi.Models;
using BookiApi.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Globalization;
using System.Linq;
using System.Text.Json.Nodes;
using Microsoft.EntityFrameworkCore;

namespace BookiApi.Controllers;

[ApiController]
[Route("booki-app/[action]")]
public partial class BookController : ControllerBase
{
	private readonly BookContext context;

	public BookController(BookContext _context)
	{
		context = _context;
	}

	[HttpGet]
	public IActionResult Ping() => Ok(DateTime.Now);


	[HttpGet]
	[Authorize]
	public IActionResult AuthPing() =>
		Ok(new { DateTime.Now, User.Claims.First(x => x.Type == "user_id").Value });

	/// <summary>
	///		Gets relevant books to the user to be shown on Home, Reading and Favorite tabs
	/// </summary>
	/// <returns>
	///		An object with home, reading and favorite Books arrays
	/// </returns>
	[HttpGet]
	[Authorize]
	public IActionResult PopulateBookSets()
	{
		try {
			var userId = User.Claims.First(x => x.Type == "user_id").Value;
			var thisUserBooks = context.UserBooks.Where((x) => x.Uid == userId);
			var userBookIds = thisUserBooks.Select(e => e.BookId);

			var favorites = thisUserBooks
				.Where((x) => x.IsFavorite)
				.Include(e => e.Book)
				.Select(BookDto.FromUserBook);
			var reading = thisUserBooks
				.Where((x) => x.ReadingPosition > 0 && !x.IsFavorite)
				.Include(e => e.Book)
				.OrderByDescending(e => e.ReadingPosition)
				.Select(BookDto.FromUserBook);
			var home = context.Books
				.Where(b => !userBookIds.Contains(b.BookId))
				.Take(24)
				.Select(BookDto.FromBook);

			return Ok(new { home, favorites, reading });
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}

	/// <summary>
	///		Search for a specific book
	/// </summary> 
	/// <param name="search">
	///		A string contained in the desired book's metadata
	/// </param>
	/// <returns>
	///		An array of matches
	/// </returns>
	[HttpGet]
	[Authorize]
	public ActionResult SearchBook(string search)
	{
		try {
			var userId = User.Claims.First(x => x.Type == "user_id").Value;

			return Ok((IQueryable<BookDto>?)context.Books
				.Where(x => x.SearchVector!.Matches(search))
				.Include(b => b.UserBooks.Where(ub => ub.Uid == userId))
				.Select(b => b.UserBooks.Count() != 0
					? BookDto.FromBookWith(b, b.UserBooks[0].ReadingPosition, b.UserBooks[0].IsFavorite)
					: BookDto.FromBook(b)));
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}

	/// <summary>
	///		Update the saved position of a specific book
	/// </summary>
	/// <param name="bookId">
	///		The id of the book to be updated
	/// </param>
	/// <param name="newPosition">
	///     Updated position
	/// </param>
	/// <returns>
	///		Success or failure
	/// </returns>
	[HttpGet]
	[Authorize]
	public IActionResult UpdateBookPosition(int bookId, int newPosition)
	{
		try {
			var userId = User.Claims.First(x => x.Type == "user_id").Value;
			var userBook = context.UserBooks.Find(userId, bookId);

			if (userBook is null) {
				context.UserBooks.Add(new(context.Books.Find(bookId).ThrowIfNull(), userId, false, newPosition));
			} else {
				context.UserBooks.Find(userId, bookId)!.ReadingPosition = newPosition;
			}

			context.SaveChanges();
			return Ok();
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}

	/// <summary>
	///     Update if a specific book is favorite
	/// </summary> 
	/// <param name="bookId">
	///		The id of the book to be updated
	/// </param>
	/// <param name="newIsFavorite">
	///     Updated IsFavorite status
	/// </param>
	/// <returns>
	///		Success or failure
	/// </returns>
	[HttpGet]
	[Authorize]
	public IActionResult UpdateBookFavorite(int bookId, bool newIsFavorite)
	{
		try {
			var userId = User.Claims.First(x => x.Type == "user_id").Value;
			var userBook = context.UserBooks.Find(userId, bookId);

			if (userBook is null) {
				context.UserBooks.Add(new(context.Books.Find(bookId).ThrowIfNull(), userId, true));
			} else {
				context.UserBooks.Find(userId, bookId)!.IsFavorite = newIsFavorite;
			}

			context.SaveChanges();
			return Ok();
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}
}