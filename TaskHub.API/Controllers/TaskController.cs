    using Microsoft.AspNetCore.Mvc;
    using Microsoft.EntityFrameworkCore;
    using TaskHub.API.Data;
    using TaskHub.API.Models;

    namespace TaskHub.API.Controllers;

    [ApiController]
    [Route("tasks")]
    public class TasksController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TasksController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IEnumerable<TaskItem>> Get()
        {
            return await _context.Tasks.ToListAsync();
        }

        [HttpPost]
        public async Task<IActionResult> Create(TaskItem task)
        {
           if (!ModelState.IsValid)
              return BadRequest(ModelState);

             _context.Tasks.Add(task);
              await _context.SaveChangesAsync();

             return CreatedAtAction(nameof(Get), new { id = task.Id }, task);
        }

        [HttpPatch("{id}")]
        public async Task<IActionResult> Update(int id, TaskItem updated)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var task = await _context.Tasks.FindAsync(id);

            if (task == null)
                return NotFound();

            task.Texto = updated.Texto;
            task.Completada = updated.Completada;

            await _context.SaveChangesAsync();

            return Ok(task);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var task = await _context.Tasks.FindAsync(id);

            if (task == null) return NotFound();

            _context.Tasks.Remove(task);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }