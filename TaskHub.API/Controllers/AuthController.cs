using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using TaskHub.API.Data;
using TaskHub.API.Dtos;
using TaskHub.API.Models;
using TaskHub.API.Services;

namespace TaskHub.API.Controllers;

[ApiController]
[Route("auth")]
public class AuthController : ApiControllerBase
{
    private readonly AppDbContext _context;
    private readonly TokenService _tokens;
    private readonly IEmailSender _email;

    public AuthController(AppDbContext context, TokenService tokens, IEmailSender email)
    {
        _context = context;
        _tokens = tokens;
        _email = email;
    }

    [EnableRateLimiting("auth")]
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var email = dto.Email.Trim().ToLowerInvariant();

        if (await _context.Users.AnyAsync(u => u.Email == email))
            return Conflict(new { mensaje = "Ya existe una cuenta con ese correo" });

        var user = new User
        {
            Email = email,
            Nombre = dto.Nombre.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password)
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return Ok(await EmitirTokens(user));
    }

    [EnableRateLimiting("auth")]
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var email = dto.Email.Trim().ToLowerInvariant();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

        // Mismo mensaje para "no existe" y "contraseña mal": no revelamos cuál falló.
        if (user is null || !BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash))
            return Unauthorized(new { mensaje = "Correo o contraseña incorrectos" });

        return Ok(await EmitirTokens(user));
    }

    /// <summary>Canjea un refresh token por un par nuevo (rota el anterior).</summary>
    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh(RefreshDto dto)
    {
        var hash = TokenService.Hash(dto.RefreshToken);
        var actual = await _context.RefreshTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.TokenHash == hash);

        if (actual is null || !actual.Activo || actual.User is null)
            return Unauthorized(new { mensaje = "Sesión expirada. Inicia sesión de nuevo." });

        // Rotación: revocamos el viejo y emitimos uno nuevo.
        actual.RevocadaEn = DateTime.UtcNow;
        return Ok(await EmitirTokens(actual.User));
    }

    /// <summary>Cierra la sesión revocando el refresh token entregado.</summary>
    [HttpPost("logout")]
    public async Task<IActionResult> Logout(RefreshDto dto)
    {
        var hash = TokenService.Hash(dto.RefreshToken);
        var token = await _context.RefreshTokens.FirstOrDefaultAsync(t => t.TokenHash == hash);
        if (token is { RevocadaEn: null })
        {
            token.RevocadaEn = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
        return NoContent();
    }

    [Authorize]
    [HttpPost("password")]
    public async Task<IActionResult> CambiarPassword(ChangePasswordDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var user = await _context.Users.FindAsync(UserId);
        if (user is null) return Unauthorized();

        if (!BCrypt.Net.BCrypt.Verify(dto.Actual, user.PasswordHash))
            return BadRequest(new { mensaje = "La contraseña actual es incorrecta" });

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Nueva);
        await RevocarSesiones(user.Id); // revoca TODAS las sesiones (incluida esta)
        await _context.SaveChangesAsync();

        // Emitimos un par nuevo para que ESTA sesión continúe sin cortarse.
        return Ok(await EmitirTokens(user));
    }

    /// <summary>Solicita un enlace de restablecimiento (siempre responde 200).</summary>
    [EnableRateLimiting("auth")]
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordDto dto)
    {
        var email = dto.Email.Trim().ToLowerInvariant();
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);

        // No revelamos si el correo existe. Solo creamos el token si hay usuario.
        if (user is not null)
        {
            var raw = TokenService.GenerarTokenAleatorio();
            _context.PasswordResetTokens.Add(new PasswordResetToken
            {
                UserId = user.Id,
                TokenHash = TokenService.Hash(raw),
                ExpiraEn = DateTime.UtcNow.AddHours(1)
            });
            await _context.SaveChangesAsync();

            await _email.EnviarAsync(user.Email, "Restablece tu contraseña",
                $"Usa este código para restablecer tu contraseña (válido 1 hora):\n\n{raw}");
        }

        return Ok(new { mensaje = "Si el correo existe, te enviamos instrucciones." });
    }

    /// <summary>Restablece la contraseña con el token del correo.</summary>
    [EnableRateLimiting("auth")]
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword(ResetPasswordDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var hash = TokenService.Hash(dto.Token);
        var reset = await _context.PasswordResetTokens
            .Include(t => t.User)
            .FirstOrDefaultAsync(t => t.TokenHash == hash);

        if (reset is null || !reset.Valido || reset.User is null)
            return BadRequest(new { mensaje = "El código es inválido o expiró." });

        reset.User.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Nueva);
        reset.UsadoEn = DateTime.UtcNow;
        await RevocarSesiones(reset.UserId); // por seguridad, cerrar sesiones abiertas
        await _context.SaveChangesAsync();

        return Ok(new { mensaje = "Contraseña restablecida. Ya puedes iniciar sesión." });
    }

    /* ===== Helpers ===== */

    // Crea access + refresh tokens, guarda el refresh (hash) y arma la respuesta.
    private async Task<AuthResponseDto> EmitirTokens(User user)
    {
        var rawRefresh = TokenService.GenerarTokenAleatorio();
        _context.RefreshTokens.Add(new RefreshToken
        {
            UserId = user.Id,
            TokenHash = TokenService.Hash(rawRefresh),
            ExpiraEn = DateTime.UtcNow.AddDays(_tokens.RefreshTokenDias)
        });
        await _context.SaveChangesAsync();

        return new AuthResponseDto
        {
            Token = _tokens.CrearAccessToken(user),
            RefreshToken = rawRefresh,
            Email = user.Email,
            Nombre = user.Nombre
        };
    }

    // Revoca todos los refresh tokens activos de un usuario.
    private async Task RevocarSesiones(int userId)
    {
        var activos = await _context.RefreshTokens
            .Where(t => t.UserId == userId && t.RevocadaEn == null)
            .ToListAsync();
        foreach (var t in activos)
            t.RevocadaEn = DateTime.UtcNow;
    }
}
