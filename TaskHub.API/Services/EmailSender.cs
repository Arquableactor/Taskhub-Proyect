namespace TaskHub.API.Services;

public interface IEmailSender
{
    Task EnviarAsync(string para, string asunto, string cuerpo);
}

/// <summary>
/// Implementación de DESARROLLO: no envía correos reales, solo los registra en
/// el log. En producción, reemplazar por un proveedor (SendGrid, SMTP, etc.).
/// </summary>
public class LogEmailSender : IEmailSender
{
    private readonly ILogger<LogEmailSender> _logger;
    public LogEmailSender(ILogger<LogEmailSender> logger) => _logger = logger;

    public Task EnviarAsync(string para, string asunto, string cuerpo)
    {
        _logger.LogWarning(
            "\n===== EMAIL (dev, no enviado) =====\nPara: {Para}\nAsunto: {Asunto}\n{Cuerpo}\n===================================",
            para, asunto, cuerpo);
        return Task.CompletedTask;
    }
}
