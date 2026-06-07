using System.ComponentModel.DataAnnotations;
using TaskHub.API.Models;

namespace TaskHub.API.Dtos;

/// <summary>Datos para crear una tarea nueva.</summary>
public record TaskCreateDto
{
    [Required(ErrorMessage = "El título es obligatorio")]
    [MinLength(1)]
    public string Titulo { get; init; } = string.Empty;

    public string? Descripcion { get; init; }
    public Prioridad Prioridad { get; init; } = Prioridad.Ninguna;
    public DateTime? FechaVencimiento { get; init; }
    public int? ProyectoId { get; init; }
}

/// <summary>
/// Actualización PARCIAL: solo se aplican los campos enviados (no null).
/// Esto es un PATCH real, no un reemplazo completo.
/// </summary>
public record TaskUpdateDto
{
    public string? Titulo { get; init; }
    public string? Descripcion { get; init; }
    public bool? Completada { get; init; }
    public Prioridad? Prioridad { get; init; }
    public DateTime? FechaVencimiento { get; init; }
    public int? Orden { get; init; }

    // Para mover a otra lista. Usa -1 para sacar de toda lista (bandeja de entrada).
    public int? ProyectoId { get; init; }
}

/// <summary>Un par id/orden para reordenar varias tareas de una vez.</summary>
public record ReordenItemDto
{
    public int Id { get; init; }
    public int Orden { get; init; }
}

public record SubTareaCreateDto
{
    [Required, MinLength(1)]
    public string Titulo { get; init; } = string.Empty;
}

public record SubTareaUpdateDto
{
    public string? Titulo { get; init; }
    public bool? Completada { get; init; }
}
