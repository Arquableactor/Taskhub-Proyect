using Microsoft.EntityFrameworkCore;
using TaskHub.API.Models;

namespace TaskHub.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options) { }

    public DbSet<TaskItem> Tasks => Set<TaskItem>();
}