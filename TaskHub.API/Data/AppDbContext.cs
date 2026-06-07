using Microsoft.EntityFrameworkCore;
using TaskHub.API.Models;

namespace TaskHub.API.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options) { }

    public DbSet<TaskItem> Tasks => Set<TaskItem>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Proyecto> Proyectos => Set<Proyecto>();
    public DbSet<SubTarea> SubTareas => Set<SubTarea>();
    public DbSet<Logro> Logros => Set<Logro>();
    public DbSet<RegistroDiario> RegistrosDiarios => Set<RegistroDiario>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // El email es único: no puede haber dos cuentas con el mismo correo.
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        // Al borrar un usuario se borran sus tareas y proyectos.
        modelBuilder.Entity<TaskItem>()
            .HasOne(t => t.User)
            .WithMany(u => u.Tareas)
            .HasForeignKey(t => t.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Proyecto>()
            .HasOne(p => p.User)
            .WithMany(u => u.Proyectos)
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // Si se borra un proyecto, sus tareas no se borran: quedan sin lista.
        modelBuilder.Entity<TaskItem>()
            .HasOne(t => t.Proyecto)
            .WithMany(p => p.Tareas)
            .HasForeignKey(t => t.ProyectoId)
            .OnDelete(DeleteBehavior.SetNull);

        // Al borrar una tarea se borran sus subtareas.
        modelBuilder.Entity<SubTarea>()
            .HasOne(s => s.TaskItem)
            .WithMany(t => t.SubTareas)
            .HasForeignKey(s => s.TaskItemId)
            .OnDelete(DeleteBehavior.Cascade);

        // Al borrar un usuario se borran sus logros.
        modelBuilder.Entity<Logro>()
            .HasOne(l => l.User)
            .WithMany(u => u.Logros)
            .HasForeignKey(l => l.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // Cada logro solo puede estar una vez por usuario.
        modelBuilder.Entity<Logro>()
            .HasIndex(l => new { l.UserId, l.Clave })
            .IsUnique();

        // Al borrar un usuario se borran sus registros diarios.
        modelBuilder.Entity<RegistroDiario>()
            .HasOne(r => r.User)
            .WithMany(u => u.RegistrosDiarios)
            .HasForeignKey(r => r.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // Un único registro por usuario y día.
        modelBuilder.Entity<RegistroDiario>()
            .HasIndex(r => new { r.UserId, r.Fecha })
            .IsUnique();

        // Tokens de refresco: cascada al borrar usuario, búsqueda por hash.
        modelBuilder.Entity<RefreshToken>()
            .HasOne(t => t.User)
            .WithMany()
            .HasForeignKey(t => t.UserId)
            .OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<RefreshToken>().HasIndex(t => t.TokenHash);

        // Tokens de reset: cascada al borrar usuario, búsqueda por hash.
        modelBuilder.Entity<PasswordResetToken>()
            .HasOne(t => t.User)
            .WithMany()
            .HasForeignKey(t => t.UserId)
            .OnDelete(DeleteBehavior.Cascade);
        modelBuilder.Entity<PasswordResetToken>().HasIndex(t => t.TokenHash);
    }
}
