using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

/// <summary>
/// Actividad diaria de un usuario: cuántas tareas completó en un día concreto.
/// Se usa para el mapa de calor (heatmap) y las barras semanales.
/// </summary>
public class RegistroDiario
{
    public int Id { get; set; }

    public int UserId { get; set; }

    // Fecha del día (UTC, granularidad día).
    public DateTime Fecha { get; set; }

    // Tareas completadas ese día.
    public int Completadas { get; set; }

    [JsonIgnore]
    public User? User { get; set; }
}
