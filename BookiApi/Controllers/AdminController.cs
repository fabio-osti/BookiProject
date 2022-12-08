using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BookiApi.Contexts;
using BookiApi.Models;
using BookiApi.Helpers;
using System.Globalization;
using Microsoft.EntityFrameworkCore;

namespace BookiApi.Controllers;

[ApiController]
[Route("~/booki-admin/[action]")]
public partial class AdminController : ControllerBase
{
	private readonly BookContext context;

	public AdminController(BookContext _context)
	{
		context = _context;
	}

	[HttpGet]
	[Route("/booki-admin")]
	public RedirectResult App() {
		return new RedirectResult("~/booki-admin/index.html");
	}

	[HttpPost]
	[Authorize(Policy = "Administrator")]
	public IActionResult Create([FromBody] BookDto book)
	{
		try {
			var added = context.Books.Add(book.ToBook());
			context.SaveChanges();
			return Ok(BookDto.FromBook(added.Entity));
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}

	[HttpPost]
	[Authorize(Policy = "Administrator")]
	public IActionResult Read(
		int amount,
		int page,
		[FromBody] BookDto filter
		)
	{
		if (amount > 256) return Problem("Max amount is 256");
		try {
			if (!filter.IsEmpty()) {
				var query = context.Books.Where(book =>
					(
						filter.Title == null
						|| EF.Functions.ILike(
							context.Unaccent(book.Title).ToLower(),
							"%" + context.Unaccent(filter.Title).ToLower() + "%")
					) && (
						filter.Author == null
						|| EF.Functions.ILike(
							context.Unaccent(book.Author).ToLower(),
							"%" + context.Unaccent(filter.Author).ToLower() + "%")
					) && (
						filter.Publisher == null
						|| EF.Functions.ILike(
							context.Unaccent(book.Publisher).ToLower(),
							"%" + context.Unaccent(filter.Publisher).ToLower() + "%")
					) && (
						filter!.Genres == null ||
						book.Genres.Any(e => filter!.Genres.Contains(e))
					) && (
						filter.Published == null
						|| EF.Functions.ILike(
							context.Unaccent(book.PublishedOn).ToLower(),
							"%" + context.Unaccent(filter.Published).ToLower() + "%")
					) && (
						filter.Language == null
						|| new CultureInfo(filter.Language) == book.Language

					)
				);
				var entriesCount = query.Count();
				var content = query.OrderBy(b => b.BookId).Skip((page - 1) * amount).Take(amount).Select(BookDto.FromBook);
				return Ok(new { entriesCount, content });
			} else {
				var query = context.Books;
				var entriesCount = query.Count();
				var content = query.OrderBy(b => b.BookId).Skip((page - 1) * amount).Take(amount).Select(BookDto.FromBook);
				return Ok(new { entriesCount, content });
			}
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}

	[HttpPost]
	[Authorize(Policy = "Administrator")]
	public IActionResult Update([FromBody] BookDto book)
	{
		try {
			var updated = context.Books.Update(book.ToBook());
			context.SaveChanges();
			return Ok(BookDto.FromBook(updated.Entity));
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}

	[HttpPost]
	[Authorize(Policy = "Administrator")]
	public IActionResult Delete([FromBody] BookDto book)
	{
		try {
			context.Books.Remove(context.Books.Find(book.Id) ?? throw new KeyNotFoundException("Book ID not found"));
			context.SaveChanges();
			return Ok();
		} catch (Exception e) {
			return Problem(e.Message);
		}
	}
}