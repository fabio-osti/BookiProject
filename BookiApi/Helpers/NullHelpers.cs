namespace BookiApi.Helpers;

static public class NullHelpers
{	static public TObj ThrowIfNull<TObj>(this TObj? obj, string? name = null) =>
		obj ?? throw new NullReferenceException(name);
}