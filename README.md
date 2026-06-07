# TaskHub

App de lista de tareas (to-do) multiplataforma.

- **Backend:** API REST en ASP.NET Core 8 + EF Core + SQLite.
- **Frontend:** app **Flutter** (Android + iOS) — en construcción.
- **Auth:** JWT (cada usuario ve solo sus tareas).

## Cómo correr el backend

**Primero**, configura la clave JWT (no se versiona, por seguridad). En desarrollo
se guarda con *user-secrets*:

```bash
cd TaskHub.API
dotnet user-secrets init
dotnet user-secrets set "Jwt:Key" "$(openssl rand -base64 48)"
dotnet run
```

> En producción, esa clave va en la variable de entorno `Jwt__Key`. El servidor
> NO arranca sin una clave de al menos 32 caracteres.

Al arrancar aplica las migraciones solo (crea `taskhub.db`). En desarrollo, la
documentación interactiva queda en: http://localhost:5176/swagger

> En Swagger puedes registrarte en `/auth/register`, copiar el `token` y pegarlo
> en el botón **Authorize** para probar las rutas protegidas.

## Modelo de datos

- **Tarea**: título, descripción, completada, prioridad (Ninguna/Baja/Media/Alta),
  fecha de vencimiento, orden, timestamps, proyecto, subtareas.
- **Proyecto** (lista): nombre + color.
- **SubTarea**: checklist dentro de una tarea.
- **User**: dueño de tareas y proyectos.

## Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/auth/register` | Crear cuenta → devuelve token |
| POST | `/auth/login` | Iniciar sesión → devuelve token |
| GET | `/tasks` | Listar tareas. Filtros: `?vista=hoy\|atrasadas\|proximas\|sinfecha`, `?proyectoId=`, `?completada=` |
| GET | `/tasks/{id}` | Una tarea |
| POST | `/tasks` | Crear tarea |
| PATCH | `/tasks/{id}` | Actualización parcial |
| DELETE | `/tasks/{id}` | Borrar tarea |
| PUT | `/tasks/reorden` | Reordenar (drag & drop) |
| POST | `/tasks/{id}/subtareas` | Agregar subtarea |
| PATCH | `/tasks/{taskId}/subtareas/{subId}` | Editar subtarea |
| DELETE | `/tasks/{taskId}/subtareas/{subId}` | Borrar subtarea |
| GET/POST/PATCH/DELETE | `/proyectos` `/proyectos/{id}` | CRUD de listas |

Todas las rutas excepto `/auth/*` requieren header `Authorization: Bearer <token>`.

## Configuración (appsettings.json)

- `Jwt:Key` — **cámbiala** por una clave larga y secreta en producción.
- `Cors:Origenes` — dominios del frontend permitidos (vacío = todos, solo dev).
- `ConnectionStrings:Default` — cadena de conexión SQLite.
