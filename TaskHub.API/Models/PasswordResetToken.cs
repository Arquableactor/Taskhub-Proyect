using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

/// <summary>
/// Token de un solo uso para restablecer la contraseña. Guardamos solo el hash.
/// </summary>
public class PasswordResetToken
{
    public int Id { get; set; }

    public int UserId { get; set; }

    [JsonIgnore]
    public User? User { get; set; }

    public string TokenHash { get; set; } = string.Empty;

    public DateTime CreadaEn { get; set; } = DateTime.UtcNow;
    public DateTime ExpiraEn { get; set; }
    public DateTime? UsadoEn { get; set; }

    public bool Valido => UsadoEn is null && DateTime.UtcNow < ExpiraEn;
}
