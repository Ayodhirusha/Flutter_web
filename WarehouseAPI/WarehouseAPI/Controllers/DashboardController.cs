using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using WarehouseAPI.Models;

[Route("api/[controller]")]
[ApiController]
public class DashboardController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public DashboardController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    private IDbConnection Connection =>
        new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));

    // GET: api/dashboard/stats - Get dashboard statistics
    [HttpGet("stats")]
    public async Task<IActionResult> GetDashboardStats()
    {
        try
        {
            using var db = Connection;

            var stats = await db.QueryFirstOrDefaultAsync<DashboardStats>(
                "sp_GetDashboardStats",
                commandType: CommandType.StoredProcedure
            );

            if (stats == null)
            {
                // Return default stats if no data
                stats = new DashboardStats
                {
                    TotalProducts = 0,
                    LowStockItems = 0,
                    OutOfStockItems = 0,
                    TotalInventoryValue = 0,
                    TotalCategories = 0,
                    TodayMovements = 0
                };
            }

            return Ok(stats);
        }
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                error = "Database access error",
                message = ex.Message
            });
        }
    }
}
