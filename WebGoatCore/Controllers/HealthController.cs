using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace WebGoatCore.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class HealthController : ControllerBase
    {
        private readonly ILogger<HealthController> _logger;
        private readonly HealthCheckService _healthCheckService;

        public HealthController(ILogger<HealthController> logger, HealthCheckService healthCheckService)
        {
            _logger = logger;
            _healthCheckService = healthCheckService;
        }

        /// <summary>
        /// Basic health check endpoint for liveness probes
        /// </summary>
        /// <returns>200 OK if the application is running</returns>
        [HttpGet]
        [HttpGet("live")]
        public IActionResult Get()
        {
            _logger.LogDebug("Health check requested");
            return Ok(new { status = "Healthy", timestamp = System.DateTime.UtcNow });
        }

        /// <summary>
        /// Readiness check endpoint for readiness probes
        /// </summary>
        /// <returns>200 OK if the application is ready to serve traffic</returns>
        [HttpGet("ready")]
        public async Task<IActionResult> Ready()
        {
            try
            {
                var healthReport = await _healthCheckService.CheckHealthAsync();
                
                if (healthReport.Status == HealthStatus.Healthy)
                {
                    _logger.LogDebug("Readiness check passed");
                    return Ok(new { 
                        status = "Ready", 
                        timestamp = System.DateTime.UtcNow,
                        checks = healthReport.Entries.Count
                    });
                }
                else
                {
                    _logger.LogWarning("Readiness check failed: {Status}", healthReport.Status);
                    return ServiceUnavailable(new { 
                        status = "NotReady", 
                        timestamp = System.DateTime.UtcNow,
                        details = healthReport.Status.ToString()
                    });
                }
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Health check failed with exception");
                return ServiceUnavailable(new { 
                    status = "NotReady", 
                    timestamp = System.DateTime.UtcNow,
                    error = "Health check failed"
                });
            }
        }

        /// <summary>
        /// Startup check endpoint for startup probes
        /// </summary>
        /// <returns>200 OK if the application has started successfully</returns>
        [HttpGet("startup")]
        public IActionResult Startup()
        {
            try
            {
                // Check if critical services are initialized
                // You can add more specific startup checks here
                _logger.LogDebug("Startup check requested");
                
                return Ok(new { 
                    status = "Started", 
                    timestamp = System.DateTime.UtcNow,
                    uptime = System.Diagnostics.Process.GetCurrentProcess().StartTime
                });
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Startup check failed");
                return ServiceUnavailable(new { 
                    status = "Starting", 
                    timestamp = System.DateTime.UtcNow,
                    error = "Startup check failed"
                });
            }
        }

        /// <summary>
        /// Detailed health check with component status
        /// </summary>
        /// <returns>Detailed health information</returns>
        [HttpGet("detailed")]
        public async Task<IActionResult> Detailed()
        {
            try
            {
                var healthReport = await _healthCheckService.CheckHealthAsync();
                
                var response = new
                {
                    status = healthReport.Status.ToString(),
                    timestamp = System.DateTime.UtcNow,
                    totalDuration = healthReport.TotalDuration,
                    entries = healthReport.Entries
                };

                if (healthReport.Status == HealthStatus.Healthy)
                {
                    return Ok(response);
                }
                else
                {
                    return StatusCode(503, response); // Service Unavailable
                }
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex, "Detailed health check failed");
                return StatusUnavailable(new { 
                    status = "Unhealthy", 
                    timestamp = System.DateTime.UtcNow,
                    error = ex.Message
                });
            }
        }

        private ObjectResult ServiceUnavailable(object value)
        {
            return StatusCode(503, value);
        }

        private ObjectResult StatusUnavailable(object value)
        {
            return StatusCode(503, value);
        }
    }
}
