using System.ComponentModel.DataAnnotations;

namespace TaskHub.API.Dtos;

public record RegisterDto
{
    [Required, EmailAddress]
    public string Email { get; init; } = string.Empty;

    [Required, MinLength(2)]
    public string Nombre { get; init; } = string.Empty;

    [Required, MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
    public string Password { get; init; } = string.Empty;
}

public record LoginDto
{
    [Required, EmailAddress]
    public string Email { get; init; } = string.Empty;

    [Required]
    public string Password { get; init; } = string.Empty;
}

public record AuthResponseDto
{
    public string Token { get; init; } = string.Empty;        // access token (corto)
    public string RefreshToken { get; init; } = string.Empty; // refresh token (rotativo)
    public string Email { get; init; } = string.Empty;
    public string Nombre { get; init; } = string.Empty;
}

public record RefreshDto
{
    [Required]
    public string RefreshToken { get; init; } = string.Empty;
}

public record ForgotPasswordDto
{
    [Required, EmailAddress]
    public string Email { get; init; } = string.Empty;
}

public record ResetPasswordDto
{
    [Required]
    public string Token { get; init; } = string.Empty;

    [Required, MinLength(6, ErrorMessage = "La contraseña debe tener al menos 6 caracteres")]
    public string Nueva { get; init; } = string.Empty;
}

public record PerfilUpdateDto
{
    public string? Nombre { get; init; }
    public string? Telefono { get; init; }
}

public record ChangePasswordDto
{
    [Required]
    public string Actual { get; init; } = string.Empty;

    [Required, MinLength(6, ErrorMessage = "La nueva contraseña debe tener al menos 6 caracteres")]
    public string Nueva { get; init; } = string.Empty;
}
