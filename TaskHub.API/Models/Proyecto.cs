using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

/// <summary>
/// Una lista o proyecto que agrupa tareas (ej: Trabajo, Personal).
/// </summary>
public class Proyecto
{
    public int Id { get; set; }

    [Required(ErrorMessage = "El nombre es obligatorio")]
    [MinLength(1)]
    public string Nombre { get; set; } = string.Empty;

    // Color en formato hex (#RRGGBB) para mostrar en la UI.
    public string Color { get; set; } = "#4F46E5";

    public DateTime CreadaEn { get; set; } = DateTime.UtcNow;

    // Dueño del proyecto.
    public int UserId { get; set; }

    [JsonIgnore]
    public User? User { get; set; }

    [JsonIgnore]
    public List<TaskItem> Tareas { get; set; } = new();
}
