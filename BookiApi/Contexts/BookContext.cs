using BookiApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;

namespace BookiApi.Contexts;

public class BookContext : DbContext
{
	[DbFunction("unaccent")]
	public string Unaccent(string text) => throw new NotSupportedException();

	private readonly static ValueComparer<List<string>> comparer = new(
		(c1, c2) => c1 == null || c2 == null ? c2 == c1 : c1.SequenceEqual(c2),
		c => c.Aggregate(0, (a, v) => HashCode.Combine(a, v.GetHashCode())),
		c => c.ToList());

#pragma warning disable CS8618
	public BookContext(DbContextOptions<BookContext> options) : base(options) { }
#pragma warning restore CS8618

	public DbSet<Book> Books { get; set; }

	public DbSet<UserBook> UserBooks { get; set; }

	public void Seed() 
	{
		Books.AddRange(
			new Book(1000, "The Possessed (The Devils)", "Dostoyevsky", new List<string>() { "Romance", "Psicológico" }, "May 2005", "Gutenberg Project", "A fictional town descends into chaos as it becomes the focal point of an attempted revolution, orchestrated by master conspirator Pyotr Verkhovensky. The mysterious aristocratic figure of Nikolai Stavrogin—Verkhovensky\'s counterpart in the moral sphere—dominates the book, exercising an extraordinary influence over the hearts and minds of almost all the other characters.", new("en")),
			new Book(1001, "O Hobbit", "J.R.R Tolkien", new List<string>() { "Aventura", "Fantasia" }, "Jan 2013", "WMF", "Como a maioria dos hobbits, Bilbo Bolseiro leva uma vida tranquila até o dia em que recebe uma missão do mago Gandalf. Acompanhado por um grupo de anões, ele parte numa jornada até a Montanha Solitária para libertar o Reino de Erebor do dragão Smaug.", new("pt")),
			new Book(1002, "As Crônicas de Nárnia", "C.S Lewis", new List<string>() { "Aventura", "Fantasia", "Alegórico" }, "Jan 2008", "WMF", "Os irmãos Lúcia, Susana, Edmundo e Pedro vivem na Inglaterra, em plena Segunda Guerra Mundial. Em uma de suas brincadeiras, descobrem um guarda-roupa mágico que leva ao mundo mágico de Nárnia. Habitado por seres estranhos, como centauros e gigantes, este lugar já foi pacífico, mas hoje vive sob a maldição da Feiticeira Branca, que o deixou como se sempre estivesse em um pesado inverno. Sob a orientação do leão Aslam, as crianças decidem ajudar na luta contra este domínio maligno.", new("pt")),
			new Book(1004, "As Ideias Tem Consequências", "Richard M. Weaver", new List<string>() { "Filosofia", "Conservador" }, "Jan 2016", "É Realizações", "Richard M. Weaver diagnostica impiedosamente as doenças de nossa época, oferecendo uma solução realista. Ele afirma que o mundo é inteligível e que o homem é livre. As catástrofes de nossa época não são produto da necessidade, mas de decisões pouco sábias. Uma cura, ele sugere, é possível. Ela encontra-se no uso correto da razão, na renovada aceitação de uma realidade absoluta e no reconhecimento de que as ideias, como as ações, têm consequências.", new("pt")),
			new Book(1003, "Ilíada e Odisseia", "Homero", new List<string>() { "Clássico", "Aventura" }, "May 2015", "Nova Fronteira", "Ilíada narra a fúria do herói Aquiles e suas consequências trágicas durante a Guerra de Troia; Odisseia narra o retorno de Ulisses, o Odisseu, rei de Ítaca, após essa guerra. Essas narrativas são consideradas um simbolismo da aventura humana. ", new("pt")),
			new Book(1005, "Paradise Lost", "John Milton", new List<string>() { "Épico", "Bíblico", "Poesia" }, "Oct 1991", "Project Gutenberg", "Paradise Lost is an epic poem (12 books, totalling more than 10,500 lines) written in blank verse, telling the biblical tale of the Fall of Mankind – the moment when  Adam and Eve were tempted by Satan to eat the forbidden fruit from the Tree of Knowledge, and God banished them from the Garden of Eden forever.", new("en"))
		);
		SaveChanges();
	}

	protected override void OnModelCreating(ModelBuilder modelBuilder)
	{
		modelBuilder.HasPostgresExtension("unaccent");

		base.OnModelCreating(modelBuilder);
		var entityTypeBuilder = modelBuilder.Entity<Book>();

		modelBuilder.Entity<Book>()
			.HasGeneratedTsVectorColumn(
				p => p.SearchVector!,
				"english",
				p => new { p.Title, p.Author, p.Synopsis })
			.HasIndex(p => p.SearchVector)
			.HasMethod("GIN");

		entityTypeBuilder.HasKey(e => e.BookId);
		entityTypeBuilder
			.Property(e => e.Language)
			.HasConversion(e => e!.ToString(), e => (new(e)));

		modelBuilder.Entity<UserBook>().HasKey(e => new { e.Uid, e.BookId });
		modelBuilder.Entity<UserBook>()
			.HasOne(e => e.Book)
			.WithMany(e => e.UserBooks)
			.HasForeignKey(e => e.BookId)
			.IsRequired();
	}
}
