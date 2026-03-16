using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using WarehouseAPI.Models;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public ProductsController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    private IDbConnection Connection =>
        new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));

    [HttpGet]
    public async Task<IActionResult> GetProducts()
    {
        try
        {
            using var db = Connection;

            var result = await db.QueryAsync<Product>(
                "sp_GetProducts",
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

    [HttpGet("{id}")]
    public async Task<IActionResult> GetProductById(string id)
    {
        try
        {
            using var db = Connection;

            var result = await db.QueryFirstOrDefaultAsync<Product>(
                "sp_GetProductById",
                new { Id = id },
                commandType: CommandType.StoredProcedure
            );

            if (result == null)
                return NotFound(new { message = "Product not found" });

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

    [HttpPost]
    public async Task<IActionResult> AddProduct(Product product)
    {
        try
        {
            using var db = Connection;

            // Generate ID if empty - THIS IS THE FIX
            if (string.IsNullOrEmpty(product.Id))
            {
                product.Id = Guid.NewGuid().ToString("N");
            }

            await db.ExecuteAsync(
                "sp_AddProduct",
                new
                {
                    Id = product.Id,
                    Name = product.Name,
                    Sku = product.Sku,
                    Category = product.Category,
                    Price = product.Price,
                    StockQuantity = product.StockQuantity,
                    MinStockLevel = product.MinStockLevel,
                    Status = product.Status,
                    ImageUrl = product.ImageUrl,
                    Supplier = product.Supplier,
                    Location = product.Location
                },
                commandType: CommandType.StoredProcedure
            );

            return Ok(new { id = product.Id, message = "Product created successfully" });
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

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(string id, Product product)
    {
        try
        {
            using var db = Connection;
            product.Id = id;

            await db.ExecuteAsync(
                "sp_UpdateProduct",
                new
                {
                    Id = product.Id,
                    Name = product.Name,
                    Sku = product.Sku,
                    Category = product.Category,
                    Price = product.Price,
                    StockQuantity = product.StockQuantity,
                    MinStockLevel = product.MinStockLevel,
                    Status = product.Status,
                    ImageUrl = product.ImageUrl,
                    Supplier = product.Supplier,
                    Location = product.Location
                },
                commandType: CommandType.StoredProcedure
            );

            return Ok(new { id = product.Id, message = "Product updated successfully" });
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

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(string id)
    {
        try
        {
            using var db = Connection;

            await db.ExecuteAsync(
                "sp_DeleteProduct",
                new { Id = id },
                commandType: CommandType.StoredProcedure
            );

            return Ok();
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