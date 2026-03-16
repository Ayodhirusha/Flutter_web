using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using WarehouseAPI.Models;

[Route("api/[controller]")]
[ApiController]
public class StockController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public StockController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    private IDbConnection Connection =>
        new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));

    // POST: api/stock/update - Update stock quantity
    [HttpPost("update")]
    public async Task<IActionResult> UpdateStock([FromBody] StockUpdateRequest request)
    {
        try
        {
            // Validate ProductId
            if (string.IsNullOrEmpty(request.ProductId))
            {
                return BadRequest(new { error = "ProductId is required" });
            }

            // Validate movement type
            var type = (request.Type ?? string.Empty).Trim().ToLowerInvariant();
            if (type != "in" && type != "out" && type != "adjustment")
            {
                return BadRequest(new { error = "Invalid movement type. Use: in, out, adjustment" });
            }

            using var db = Connection;

            // Ensure product exists (otherwise stored procedure will fail inserting StockMovements.ProductName)
            var productName = await db.QueryFirstOrDefaultAsync<string>(
                "SELECT Name FROM Products WHERE Id = @Id",
                new { Id = request.ProductId }
            );

            if (string.IsNullOrEmpty(productName))
            {
                return NotFound(new { error = "Product not found", productId = request.ProductId });
            }

            await db.ExecuteAsync(
                "sp_UpdateStock",
                new
                {
                    ProductId = request.ProductId,
                    Quantity = request.Quantity,
                    Type = type,
                    Reason = request.Reason,
                    Notes = request.Notes,
                    // Timestamp intentionally omitted: some DB versions of sp_UpdateStock
                    // do not include @Timestamp, and passing it causes "too many arguments".
                },
                commandType: CommandType.StoredProcedure
            );

            return Ok(new { message = "Stock updated successfully" });
        }
        catch (SqlException ex)
        {
            return StatusCode(500, new
            {
                error = "Database access error",
                message = ex.Message,
                productId = request.ProductId
            });
        }
    }

    // GET: api/stock/movements - Get stock movements
    [HttpGet("movements")]
    public async Task<IActionResult> GetStockMovements()
    {
        try
        {
            using var db = Connection;

            var result = await db.QueryAsync<StockMovement>(
                "sp_GetStockMovements",
                commandType: CommandType.StoredProcedure
            );

            return Ok(result);
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

public class StockUpdateRequest
{
    public string ProductId { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string Type { get; set; } = string.Empty; // 'in', 'out', 'adjustment'
    public string Reason { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.Now;
}
