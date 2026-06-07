using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

/// <summary>
/// Un ítem de checklist dentro de una tarea.
/// </summary>
public class SubTarea
{
    public int Id { get; set; }

    [Required]
    [MinLength(1)]
    public string Titulo { get; set; } = string.Empty;

    public bool Completada { get; set; }

    public int TaskItemId { get; set; }

    [JsonIgnore]
    public TaskItem? TaskItem { get; set; }
}
