using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaskHub.API.Data;
using TaskHub.API.Dtos;
using TaskHub.API.Models;

namespace TaskHub.API.Controllers;

[ApiController]
[Route("proyectos")]
[Authorize]
public class ProyectosController : ApiControllerBase
{
    private readonly AppDbContext _context;

    public ProyectosController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IEnumerable<Proyecto>> Get() =>
        await _context.Proyectos
            .Where(p => p.UserId == UserId)
            .OrderBy(p => p.CreadaEn)
            .ToListAsync();

    [HttpPost]
    public async Task<IActionResult> Create(ProyectoCreateDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var proyecto = new Proyecto
        {
            Nombre = dto.Nombre.Trim(),
            Color = dto.Color,
            UserId = UserId
        };

        _context.Proyectos.Add(proyecto);
        await _context.SaveChangesAsync();
        return Ok(proyecto);
    }

    [HttpPatch("{id}")]
    public async Task<IActionResult> Update(int id, ProyectoUpdateDto dto)
    {
        var proyecto = await _context.Proyectos
            .FirstOrDefaultAsync(p => p.Id == id && p.UserId == UserId);
        if (proyecto is null) return NotFound();

        if (dto.Nombre is not null) proyecto.Nombre = dto.Nombre.Trim();
        if (dto.Color is not null) proyecto.Color = dto.Color;

        await _context.SaveChangesAsync();
        return Ok(proyecto);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var proyecto = await _context.Proyectos
            .FirstOrDefaultAsync(p => p.Id == id && p.UserId == UserId);
        if (proyecto is null) return NotFound();

        // Las tareas del proyecto NO se borran: quedan sin lista (ver AppDbContext).
        _context.Proyectos.Remove(proyecto);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
