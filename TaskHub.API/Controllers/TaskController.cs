using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TaskHub.API.Data;
using TaskHub.API.Dtos;
using TaskHub.API.Models;
using TaskHub.API.Services;

namespace TaskHub.API.Controllers;

[ApiController]
[Route("tasks")]
[Authorize] // Todas las rutas requieren token válido.
public class TasksController : ApiControllerBase
{
    private readonly AppDbContext _context;
    private readonly GamificacionService _gamificacion;

    public TasksController(AppDbContext context, GamificacionService gamificacion)
    {
        _context = context;
        _gamificacion = gamificacion;
    }

    // Solo las tareas del usuario autenticado, con sus subtareas.
    private IQueryable<TaskItem> MisTareas() =>
        _context.Tasks
            .Include(t => t.SubTareas)
            .Where(t => t.UserId == UserId);

    /// <summary>
    /// Lista las tareas. Filtros opcionales:
    /// ?vista=hoy|atrasadas|proximas|sinfecha
    /// ?proyectoId=5  ?completada=true
    /// </summary>
    [HttpGet]
    public async Task<IEnumerable<TaskItem>> Get(
        [FromQuery] string? vista,
        [FromQuery] int? proyectoId,
        [FromQuery] bool? completada)
    {
        var query = MisTareas();

        if (completada.HasValue)
            query = query.Where(t => t.Completada == completada.Value);

        if (proyectoId.HasValue)
            query = query.Where(t => t.ProyectoId == proyectoId.Value);

        var hoy = DateTime.UtcNow.Date;
        var manana = hoy.AddDays(1);

        query = vista?.ToLowerInvariant() switch
        {
            "hoy" => query.Where(t => !t.Completada && t.FechaVencimiento.HasValue
                                      && t.FechaVencimiento.Value < manana),
            "atrasadas" => query.Where(t => !t.Completada && t.FechaVencimiento.HasValue
                                            && t.FechaVencimiento.Value < hoy),
            "proximas" => query.Where(t => !t.Completada && t.FechaVencimiento.HasValue
                                           && t.FechaVencimiento.Value >= manana),
            "sinfecha" => query.Where(t => !t.FechaVencimiento.HasValue),
            _ => query
        };

        return await query
            .OrderBy(t => t.Completada)
            .ThenBy(t => t.Orden)
            .ThenByDescending(t => t.Prioridad)
            .ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var task = await MisTareas().FirstOrDefaultAsync(t => t.Id == id);
        return task is null ? NotFound() : Ok(task);
    }

    [HttpPost]
    public async Task<IActionResult> Create(TaskCreateDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        // Si manda proyecto, debe ser uno suyo.
        if (dto.ProyectoId.HasValue && !await EsMiProyecto(dto.ProyectoId.Value))
            return BadRequest(new { mensaje = "El proyecto no existe o no es tuyo" });

        var ahora = DateTime.UtcNow;
        var task = new TaskItem
        {
            Titulo = dto.Titulo.Trim(),
            Descripcion = dto.Descripcion,
            Prioridad = dto.Prioridad,
            FechaVencimiento = dto.FechaVencimiento,
            ProyectoId = dto.ProyectoId,
            UserId = UserId,
            CreadaEn = ahora,
            ActualizadaEn = ahora
        };

        _context.Tasks.Add(task);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = task.Id }, task);
    }

    /// <summary>PATCH real: solo se tocan los campos enviados.</summary>
    [HttpPatch("{id}")]
    public async Task<IActionResult> Update(int id, TaskUpdateDto dto)
    {
        var task = await MisTareas().FirstOrDefaultAsync(t => t.Id == id);
        if (task is null) return NotFound();

        // Solo otorgamos en la PRIMERA vez que se completa la tarea (Contada).
        // Así descompletar y recompletar no vuelve a sumar XP/conteo.
        var seCompletaAhora = dto.Completada == true && !task.Completada && !task.Contada;

        if (dto.Titulo is not null) task.Titulo = dto.Titulo.Trim();
        if (dto.Descripcion is not null) task.Descripcion = dto.Descripcion;
        if (dto.Completada.HasValue) task.Completada = dto.Completada.Value;
        if (dto.Prioridad.HasValue) task.Prioridad = dto.Prioridad.Value;
        if (dto.FechaVencimiento.HasValue) task.FechaVencimiento = dto.FechaVencimiento.Value;
        if (dto.Orden.HasValue) task.Orden = dto.Orden.Value;

        if (dto.ProyectoId.HasValue)
        {
            // -1 es la convención para "quitar de toda lista".
            if (dto.ProyectoId.Value == -1)
            {
                task.ProyectoId = null;
            }
            else
            {
                if (!await EsMiProyecto(dto.ProyectoId.Value))
                    return BadRequest(new { mensaje = "El proyecto no existe o no es tuyo" });
                task.ProyectoId = dto.ProyectoId.Value;
            }
        }

        task.ActualizadaEn = DateTime.UtcNow;

        // Solo otorgamos recompensas la primera vez que se completa.
        if (seCompletaAhora)
        {
            task.Contada = true;
            var currentUser = await _context.Users.FindAsync(UserId);
            if (currentUser is not null)
                await _gamificacion.RegistrarCompletada(currentUser, task.Prioridad);
        }

        await _context.SaveChangesAsync();
        return Ok(task);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var task = await MisTareas().FirstOrDefaultAsync(t => t.Id == id);
        if (task is null) return NotFound();

        _context.Tasks.Remove(task);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    /// <summary>Reordena varias tareas de una sola vez (para drag & drop).</summary>
    [HttpPut("reorden")]
    public async Task<IActionResult> Reordenar(List<ReordenItemDto> items)
    {
        var ids = items.Select(i => i.Id).ToList();
        var tareas = await MisTareas().Where(t => ids.Contains(t.Id)).ToListAsync();

        foreach (var t in tareas)
            t.Orden = items.First(i => i.Id == t.Id).Orden;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    /* ===== SUBTAREAS ===== */

    [HttpPost("{taskId}/subtareas")]
    public async Task<IActionResult> AgregarSubtarea(int taskId, SubTareaCreateDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var task = await MisTareas().FirstOrDefaultAsync(t => t.Id == taskId);
        if (task is null) return NotFound();

        var sub = new SubTarea { Titulo = dto.Titulo.Trim(), TaskItemId = taskId };
        _context.SubTareas.Add(sub);
        await _context.SaveChangesAsync();
        return Ok(sub);
    }

    [HttpPatch("{taskId}/subtareas/{subId}")]
    public async Task<IActionResult> ActualizarSubtarea(int taskId, int subId, SubTareaUpdateDto dto)
    {
        var sub = await _context.SubTareas
            .FirstOrDefaultAsync(s => s.Id == subId && s.TaskItemId == taskId
                                      && s.TaskItem!.UserId == UserId);
        if (sub is null) return NotFound();

        if (dto.Titulo is not null) sub.Titulo = dto.Titulo.Trim();
        if (dto.Completada.HasValue) sub.Completada = dto.Completada.Value;

        await _context.SaveChangesAsync();
        return Ok(sub);
    }

    [HttpDelete("{taskId}/subtareas/{subId}")]
    public async Task<IActionResult> EliminarSubtarea(int taskId, int subId)
    {
        var sub = await _context.SubTareas
            .FirstOrDefaultAsync(s => s.Id == subId && s.TaskItemId == taskId
                                      && s.TaskItem!.UserId == UserId);
        if (sub is null) return NotFound();

        _context.SubTareas.Remove(sub);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private Task<bool> EsMiProyecto(int proyectoId) =>
        _context.Proyectos.AnyAsync(p => p.Id == proyectoId && p.UserId == UserId);
}
