using Microsoft.EntityFrameworkCore;
using TaskHub.API.Data;
using TaskHub.API.Models;

namespace TaskHub.API.Services;

/// <summary>
/// Lógica de gamificación: XP, niveles, rachas, actividad diaria y logros.
/// </summary>
public class GamificacionService
{
    private readonly AppDbContext _context;

    public GamificacionService(AppDbContext context)
    {
        _context = context;
    }

    /// <summary>Definición de un logro del catálogo.</summary>
    public record LogroDefinicion(
        string Clave,
        string Nombre,
        string Descripcion,
        string Emoji,
        Func<ContextoLogro, bool> Cumple);

    /// <summary>Datos disponibles para evaluar si se desbloquea un logro.</summary>
    public record ContextoLogro(User User, int CompletadasTotal);

    /// <summary>Catálogo estático de logros. Lo consume también GET /me/logros.</summary>
    public static readonly IReadOnlyList<LogroDefinicion> Catalogo = new List<LogroDefinicion>
    {
        new("primer_paso", "Primer paso", "Completa tu primera tarea", "🎯",
            c => c.CompletadasTotal >= 1),
        new("racha_7", "Racha de 7", "Mantén una racha de 7 días", "🔥",
            c => c.User.RachaActual >= 7),
        new("racha_30", "Imparable", "Mantén una racha de 30 días", "⚡",
            c => c.User.RachaActual >= 30),
        new("completadas_100", "Centenario", "Completa 100 tareas en total", "💯",
            c => c.CompletadasTotal >= 100),
        new("nivel_5", "Subiendo", "Alcanza el nivel 5", "🌟",
            c => c.User.Nivel >= 5),
        new("nivel_10", "Veterano", "Alcanza el nivel 10", "🏆",
            c => c.User.Nivel >= 10),
    };

    /// <summary>XP necesario para subir del nivel indicado al siguiente.</summary>
    public static int XpNecesario(int nivel) => 100 + (nivel - 1) * 150;

    /// <summary>XP que otorga completar una tarea según su prioridad.</summary>
    private static int XpPorPrioridad(Prioridad prioridad) => prioridad switch
    {
        Prioridad.Alta => 50,
        Prioridad.Media => 30,
        Prioridad.Baja => 20,
        _ => 10, // Ninguna
    };

    /// <summary>
    /// Registra que el usuario completó una tarea: otorga XP, sube de nivel,
    /// actualiza la racha, suma a la actividad diaria y desbloquea logros.
    /// NO llama a SaveChanges (lo hace quien invoca), pero sí añade entidades al contexto.
    /// Devuelve las claves de los logros recién desbloqueados.
    /// </summary>
    public async Task<List<string>> RegistrarCompletada(User user, Prioridad prioridad)
    {
        // 1) XP + subida de nivel.
        user.Xp += XpPorPrioridad(prioridad);
        while (user.Xp >= XpNecesario(user.Nivel))
        {
            user.Xp -= XpNecesario(user.Nivel);
            user.Nivel++;
        }

        // 2) Racha.
        var hoy = DateTime.UtcNow.Date;
        if (user.UltimoDiaActivo == hoy)
        {
            // Ya tenía actividad hoy: la racha no cambia.
        }
        else if (user.UltimoDiaActivo == hoy.AddDays(-1))
        {
            user.RachaActual++;
        }
        else
        {
            user.RachaActual = 1;
        }
        user.UltimoDiaActivo = hoy;
        user.MejorRacha = Math.Max(user.MejorRacha, user.RachaActual);

        // 3) Actividad diaria.
        var registro = await _context.RegistrosDiarios
            .FirstOrDefaultAsync(r => r.UserId == user.Id && r.Fecha == hoy);
        if (registro is null)
        {
            registro = new RegistroDiario { UserId = user.Id, Fecha = hoy, Completadas = 0 };
            _context.RegistrosDiarios.Add(registro);
        }
        registro.Completadas++;

        // 4) Logros.
        // Total histórico de completadas = suma de los registros diarios
        // (incluyendo el incremento de arriba, que aún no está guardado).
        var completadasTotal = await _context.RegistrosDiarios
            .Where(r => r.UserId == user.Id && r.Id != registro.Id)
            .SumAsync(r => r.Completadas) + registro.Completadas;

        var yaDesbloqueados = await _context.Logros
            .Where(l => l.UserId == user.Id)
            .Select(l => l.Clave)
            .ToListAsync();

        var contexto = new ContextoLogro(user, completadasTotal);
        var nuevos = new List<string>();

        foreach (var def in Catalogo)
        {
            if (yaDesbloqueados.Contains(def.Clave)) continue;
            if (!def.Cumple(contexto)) continue;

            _context.Logros.Add(new Logro
            {
                UserId = user.Id,
                Clave = def.Clave,
                DesbloqueadoEn = DateTime.UtcNow
            });
            nuevos.Add(def.Clave);
        }

        return nuevos;
    }
}
