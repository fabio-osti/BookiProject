using BookiApi.Contexts;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services
	.AddDbContext<BookContext>(options =>
		options.UseNpgsql(builder.Configuration.GetConnectionString("AppDb")));
var projectId = builder.Configuration["FirebaseProjectID"];
builder.Services
	.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
	.AddJwtBearer(options =>
	{
		options.Authority = "https://securetoken.google.com/" + projectId;
		options.TokenValidationParameters = new TokenValidationParameters
		{
			ValidateIssuer = true,
			ValidIssuer = "https://securetoken.google.com/" + projectId,
			ValidateAudience = true,
			ValidAudience = projectId,
			ValidateLifetime = true
		};
	});
builder.Services.AddAuthorization(e => e.AddPolicy("Administrator", policy => policy.RequireClaim("admin")));
builder.Services.AddControllers();
builder.Services.AddCors(o =>
	o.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment()) {
	app.UseSwagger();
	app.UseSwaggerUI();
}

//app.UseHttpsRedirection();
app.UseRouting();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.UseCors();
app.UseEndpoints(e =>
{
	e.MapFallbackToFile("/booki-app/index.html");
});
app.MapControllers();

using (var scope = app.Services.CreateScope()) {
	var services = scope.ServiceProvider;

	var context = services.GetRequiredService<BookContext>();
	if (context.Database.GetPendingMigrations().Any()) {
		context.Database.Migrate();
		if (context.Books.Count() == 0) {
			context.Seed();
		}
	}
}

app.Run();
