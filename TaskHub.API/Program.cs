using System.IdentityModel.Tokens.Jwt;
using System.Text;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using TaskHub.API.Data;
using TaskHub.API.Services;

var builder = WebApplication.CreateBuilder(args);

/* ========================= */
/* SERVICES                   */
/* ========================= */

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("Default")
                      ?? "Data Source=taskhub.db"));

builder.Services.AddScoped<TokenService>();
builder.Services.AddScoped<GamificacionService>();
builder.Services.AddScoped<IEmailSender, LogEmailSender>();

/* ---- Rate limiting: frena fuerza bruta en /auth (por IP) ---- */
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
    options.AddPolicy("auth", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? "anon",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                PermitLimit = 10,
                QueueLimit = 0
            }));
});

builder.Services.AddControllers()
    .AddJsonOptions(o =>
    {
        // Evita ciclos infinitos al serializar relaciones (tarea -> subtareas).
        o.JsonSerializerOptions.ReferenceHandler =
            System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        // Los enums (Prioridad) viajan como texto: "Alta" en vez de 3.
        o.JsonSerializerOptions.Converters.Add(
            new System.Text.Json.Serialization.JsonStringEnumConverter());
    });

/* ---- Autenticación JWT ---- */
// Leemos los claims tal cual vienen (no remapear "sub" a otra cosa).
JwtSecurityTokenHandler.DefaultMapInboundClaims = false;

var jwt = builder.Configuration.GetSection("Jwt");

// La app NO arranca sin una clave JWT fuerte (mín. 32 chars).
// Dev: user-secrets. Prod: variable de entorno Jwt__Key.
var jwtKey = jwt["Key"];
if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
    throw new InvalidOperationException(
        "Falta una clave JWT segura. Configura 'Jwt:Key' (mín. 32 caracteres) " +
        "en user-secrets (dev) o en la variable de entorno Jwt__Key (prod).");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ClockSkew = TimeSpan.FromSeconds(30), // menos margen que el default de 5 min
            ValidIssuer = jwt["Issuer"],
            ValidAudience = jwt["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

builder.Services.AddAuthorization();

/* ---- Swagger con soporte para login JWT ---- */
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "TaskHub API", Version = "v1" });

    var scheme = new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Pega aquí tu token (sin escribir 'Bearer').",
        Reference = new OpenApiReference
        {
            Type = ReferenceType.SecurityScheme,
            Id = "Bearer"
        }
    };
    c.AddSecurityDefinition("Bearer", scheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement { { scheme, Array.Empty<string>() } });
});

/* ---- CORS configurable ---- */
// En appsettings: "Cors:Origenes". Vacío = permitir todo (solo desarrollo).
var origenes = builder.Configuration.GetSection("Cors:Origenes").Get<string[]>();
builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
    {
        if (origenes is { Length: > 0 })
            policy.WithOrigins(origenes).AllowAnyMethod().AllowAnyHeader();
        else
            policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

var app = builder.Build();

/* ========================= */
/* MIGRACIONES AUTOMÁTICAS    */
/* ========================= */
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();
}

/* ========================= */
/* MIDDLEWARE                 */
/* ========================= */
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// En producción forzamos HTTPS (en dev se trabaja por http).
if (!app.Environment.IsDevelopment())
    app.UseHttpsRedirection();

app.UseCors("Frontend");
app.UseRateLimiter();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
