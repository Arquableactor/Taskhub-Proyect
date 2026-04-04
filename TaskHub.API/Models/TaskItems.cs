using System.ComponentModel.DataAnnotations;

namespace TaskHub.API.Models;

public class TaskItem
{
    public int Id { get; set; }

    [Required(ErrorMessage = "El texto es obligatorio")]
    [MinLength(1, ErrorMessage = "El texto no puede estar vacío")]
    public string Texto { get; set; } = string.Empty;

    public bool Completada { get; set; }
}