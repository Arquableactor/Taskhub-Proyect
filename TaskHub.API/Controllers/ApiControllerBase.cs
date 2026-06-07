using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace TaskHub.API.Controllers;

/// <summary>
/// Base con la lógica común: obtener el id del usuario autenticado desde el token.
/// </summary>
public abstract class ApiControllerBase : ControllerBase
{
    protected int UserId
    {
        get
        {
            // El id viaja en el claim "sub" del JWT (ver TokenService).
            var sub = User.FindFirstValue(JwtRegisteredClaimNames.Sub)
                      ?? User.FindFirstValue(ClaimTypes.NameIdentifier);

            return int.Parse(sub!);
        }
    }
}
