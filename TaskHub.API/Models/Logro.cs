using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

/// <summary>
/// Un logro desbloqueado por un usuario. La definición (nombre, descripción,
/// emoji y la regla para desbloquearlo) vive en el catálogo del GamificacionService;
/// aquí solo guardamos qué clave desbloqueó cada usuario y cuándo.
/// </summary>
public class Logro
{
    public int Id { get; set; }

    public int UserId { get; set; }

    // Identificador del logro dentro del catálogo (ej: "primer_paso").
    public string Clave { get; set; } = string.Empty;

    public DateTime DesbloqueadoEn { get; set; } = DateTime.UtcNow;

    [JsonIgnore]
    public User? User { get; set; }
}
