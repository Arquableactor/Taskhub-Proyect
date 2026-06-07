using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

public class User
{
    public int Id { get; set; }

    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string Nombre { get; set; } = string.Empty;

    // Teléfono opcional (perfil).
    public string? Telefono { get; set; }

    // Nunca se expone en JSON: solo guardamos el hash de la contraseña.
    [JsonIgnore]
    public string PasswordHash { get; set; } = string.Empty;

    public DateTime CreadaEn { get; set; } = DateTime.UtcNow;

    /* ===== Gamificación ===== */

    // Nivel actual del usuario (empieza en 1).
    public int Nivel { get; set; } = 1;

    // XP acumulado dentro del nivel actual.
    public int Xp { get; set; } = 0;

    // Racha de días consecutivos completando al menos una tarea.
    public int RachaActual { get; set; } = 0;

    // Mejor racha histórica alcanzada.
    public int MejorRacha { get; set; } = 0;

    // Fecha (UTC, granularidad día) del último día con una tarea completada.
    public DateTime? UltimoDiaActivo { get; set; }

    // Meta de tareas a completar por día.
    public int MetaDiaria { get; set; } = 5;

    [JsonIgnore]
    public List<TaskItem> Tareas { get; set; } = new();

    [JsonIgnore]
    public List<Proyecto> Proyectos { get; set; } = new();

    [JsonIgnore]
    public List<Logro> Logros { get; set; } = new();

    [JsonIgnore]
    public List<RegistroDiario> RegistrosDiarios { get; set; } = new();
}
