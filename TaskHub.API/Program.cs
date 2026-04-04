using Microsoft.EntityFrameworkCore;
using TaskHub.API.Data;

var builder = WebApplication.CreateBuilder(args);

/* ========================= */
/* SERVICES */
/* ========================= */

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite("Data Source=taskhub.db"));

builder.Services.AddControllers();

/* CORS (IMPORTANTE PARA FRONTEND) */
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy.AllowAnyOrigin()
                        .AllowAnyMethod()
                        .AllowAnyHeader());
});

var app = builder.Build();

/* ========================= */
/* MIDDLEWARE */
/* ========================= */

app.UseCors("AllowAll");

app.MapControllers();

app.Run();