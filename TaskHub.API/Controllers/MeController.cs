using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaskHub.API.Data;
using TaskHub.API.Dtos;
using TaskHub.API.Services;

namespace TaskHub.API.Controllers;

[ApiController]
[Route("me")]
[Authorize]
public class MeController : ApiControllerBase
{
    private readonly AppDbContext _context;
    private readonly GamificacionService _gamificacion;

    public MeController(AppDbContext context, GamificacionService gamificacion)
    {
        _context = context;
        _gamificacion = gamificacion;
    }

    /// <summary>Datos de perfil del usuario autenticado.</summary>
    [HttpGet("perfil")]
    public async Task<IActionResult> Perfil()
    {
        var user = await _context.Users.FindAsync(UserId);
        if (user is null) return Unauthorized();

        return Ok(new
        {
            nombre = user.Nombre,
            email = user.Email,
            telefono = user.Telefono,
            creadaEn = user.CreadaEn
        });
    }

    /// <summary>Actualiza nombre y/o teléfono (solo los campos enviados).</summary>
    [HttpPatch("perfil")]
    public async Task<IActionResult> ActualizarPerfil(PerfilUpdateDto dto)
    {
        var user = await _context.Users.FindAsync(UserId);
        if (user is null) return Unauthorized();

        if (dto.Nombre is not null)
        {
            var nombre = dto.Nombre.Trim();
            if (nombre.Length < 2)
                return BadRequest(new { mensaje = "El nombre debe tener al menos 2 caracteres" });
            user.Nombre = nombre;
        }
        if (dto.Telefono is not null)
            user.Telefono = dto.Telefono.Trim();

        await _context.SaveChangesAsync();
        return Ok(new { nombre = user.Nombre, email = user.Email, telefono = user.Telefono });
    }

    /// <summary>Progreso de gamificación del usuario autenticado.</summary>
    [HttpGet("progreso")]
    public async Task<IActionResult> Progreso()
    {
        var user = await _context.Users.FindAsync(UserId);
        if (user is null) return Unauthorized();

        var hoy = DateTime.UtcNow.Date;

        var completadasTotal = await _context.RegistrosDiarios
            .Where(r => r.UserId == UserId)
            .SumAsync(r => (int?)r.Completadas) ?? 0;

        var completadasHoy = await _context.RegistrosDiarios
            .Where(r => r.UserId == UserId && r.Fecha == hoy)
            .Select(r => (int?)r.Completadas)
            .FirstOrDefaultAsync() ?? 0;

        return Ok(new
        {
            nivel = user.Nivel,
            xp = user.Xp,
            xpSiguiente = GamificacionService.XpNecesario(user.Nivel),
            rachaActual = user.RachaActual,
            mejorRacha = user.MejorRacha,
            metaDiaria = user.MetaDiaria,
            completadasHoy,
            completadasTotal
        });
    }

    /// <summary>
    /// Actividad diaria de los últimos `dias` días (por defecto 84 = 12 semanas),
    /// rellenando con 0 los días sin registro, de más antiguo a más reciente.
    /// </summary>
    [HttpGet("actividad")]
    public async Task<IActionResult> Actividad([FromQuery] int dias = 84)
    {
        if (dias < 1) dias = 1;

        var hoy = DateTime.UtcNow.Date;
        var desde = hoy.AddDays(-(dias - 1));

        var registros = await _context.RegistrosDiarios
            .Where(r => r.UserId == UserId && r.Fecha >= desde && r.Fecha <= hoy)
            .ToDictionaryAsync(r => r.Fecha, r => r.Completadas);

        var resultado = new List<object>(dias);
        for (var i = 0; i < dias; i++)
        {
            var fecha = desde.AddDays(i);
            resultado.Add(new
            {
                fecha = fecha.ToString("yyyy-MM-dd"),
                completadas = registros.TryGetValue(fecha, out var c) ? c : 0
            });
        }

        return Ok(resultado);
    }

    /// <summary>
    /// Catálogo completo de logros con el estado de desbloqueo del usuario.
    /// </summary>
    [HttpGet("logros")]
    public async Task<IActionResult> Logros()
    {
        var desbloqueados = await _context.Logros
            .Where(l => l.UserId == UserId)
            .ToDictionaryAsync(l => l.Clave, l => l.DesbloqueadoEn);

        var resultado = GamificacionService.Catalogo.Select(def => new
        {
            clave = def.Clave,
            nombre = def.Nombre,
            descripcion = def.Descripcion,
            emoji = def.Emoji,
            desbloqueado = desbloqueados.ContainsKey(def.Clave),
            desbloqueadoEn = desbloqueados.TryGetValue(def.Clave, out var fecha)
                ? (DateTime?)fecha
                : null
        });

        return Ok(resultado);
    }
}
