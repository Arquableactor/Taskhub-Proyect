using System.Text.Json.Serialization;

namespace TaskHub.API.Models;

/// <summary>
/// Token de refresco (sesión revocable). Guardamos solo el HASH del token,
/// nunca el valor en claro: si se filtra la BD, no sirven para iniciar sesión.
/// </summary>
public class RefreshToken
{
    public int Id { get; set; }

    public int UserId { get; set; }

    [JsonIgnore]
    public User? User { get; set; }

    // SHA-256 (hex) del token entregado al cliente.
    public string TokenHash { get; set; } = string.Empty;

    public DateTime CreadaEn { get; set; } = DateTime.UtcNow;
    public DateTime ExpiraEn { get; set; }
    public DateTime? RevocadaEn { get; set; }

    public bool Activo => RevocadaEn is null && DateTime.UtcNow < ExpiraEn;
}
