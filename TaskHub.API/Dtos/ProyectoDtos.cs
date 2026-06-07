using System.ComponentModel.DataAnnotations;

namespace TaskHub.API.Dtos;

public record ProyectoCreateDto
{
    [Required, MinLength(1)]
    public string Nombre { get; init; } = string.Empty;

    public string Color { get; init; } = "#4F46E5";
}

public record ProyectoUpdateDto
{
    public string? Nombre { get; init; }
    public string? Color { get; init; }
}
