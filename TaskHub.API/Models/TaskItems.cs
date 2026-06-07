using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

public class TaskItem
{
    public int Id { get; set; }

    [Required(ErrorMessage = "El título es obligatorio")]
    [MinLength(1, ErrorMessage = "El título no puede estar vacío")]
    public string Titulo { get; set; } = string.Empty;

    // Notas largas, opcionales.
    public string? Descripcion { get; set; }

    public bool Completada { get; set; }

    // True una vez que la tarea otorgó XP/conteo. Evita farmear recompensas
    // descompletando y volviendo a completar: cada tarea cuenta una sola vez.
    public bool Contada { get; set; }

    public Prioridad Prioridad { get; set; } = Prioridad.Ninguna;

    // Fecha y hora de vencimiento (UTC). Null = sin fecha.
    public DateTime? FechaVencimiento { get; set; }

    // Posición para ordenar manualmente dentro de una lista.
    public int Orden { get; set; }

    public DateTime CreadaEn { get; set; } = DateTime.UtcNow;

    public DateTime ActualizadaEn { get; set; } = DateTime.UtcNow;

    // Lista/proyecto al que pertenece (opcional = bandeja de entrada).
    public int? ProyectoId { get; set; }

    [JsonIgnore]
    public Proyecto? Proyecto { get; set; }

    // Dueño de la tarea.
    public int UserId { get; set; }

    [JsonIgnore]
    public User? User { get; set; }

    public List<SubTarea> SubTareas { get; set; } = new();
}
