# Flutter + ASP.NET API Integration Guide

This guide explains how to connect the Flutter Warehouse Admin frontend to your ASP.NET backend with SQL Server.

## Table of Contents
1. [ASP.NET API Endpoints](#aspnet-api-endpoints)
2. [CORS Configuration](#cors-configuration)
3. [SQL Server Database Schema](#sql-server-database-schema)
4. [Testing the API Connection](#testing-the-api-connection)

---

## ASP.NET API Endpoints

Your ASP.NET backend should implement these REST API endpoints to match the Flutter frontend expectations:

### Base URL
```
https://localhost:5001/api
```

Update this in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-api-url/api';
```

### Required API Endpoints

#### 1. Products API

**GET /api/products** - Get all products
```csharp
[HttpGet]
public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
{
    // Call your stored procedure: sp_GetAllProducts
    var products = await _context.Products.FromSqlRaw("EXEC sp_GetAllProducts").ToListAsync();
    return Ok(products);
}
```

**GET /api/products/{id}** - Get product by ID
```csharp
[HttpGet("{id}")]
public async Task<ActionResult<Product>> GetProduct(string id)
{
    // Call your stored procedure: sp_GetProductById
    var product = await _context.Products
        .FromSqlRaw("EXEC sp_GetProductById @Id", new SqlParameter("@Id", id))
        .FirstOrDefaultAsync();
    
    if (product == null) return NotFound();
    return Ok(product);
}
```

**POST /api/products** - Create new product
```csharp
[HttpPost]
public async Task<ActionResult<Product>> CreateProduct([FromBody] Product product)
{
    // Call your stored procedure: sp_InsertProduct
    var result = await _context.Database.ExecuteSqlRawAsync(
        "EXEC sp_InsertProduct @Name, @SKU, @Category, @Price, @StockQuantity, @MinStockLevel, @Status, @Supplier, @Location",
        new SqlParameter("@Name", product.Name),
        new SqlParameter("@SKU", product.SKU),
        // ... other parameters
    );
    
    return CreatedAtAction(nameof(GetProduct), new { id = product.Id }, product);
}
```

**PUT /api/products/{id}** - Update product
```csharp
[HttpPut("{id}")]
public async Task<IActionResult> UpdateProduct(string id, [FromBody] Product product)
{
    // Call your stored procedure: sp_UpdateProduct
    await _context.Database.ExecuteSqlRawAsync(
        "EXEC sp_UpdateProduct @Id, @Name, @SKU, @Category, @Price, @StockQuantity, @MinStockLevel, @Status, @Supplier, @Location",
        new SqlParameter("@Id", id),
        new SqlParameter("@Name", product.Name),
        // ... other parameters
    );
    
    return Ok(product);
}
```

**DELETE /api/products/{id}** - Delete product
```csharp
[HttpDelete("{id}")]
public async Task<IActionResult> DeleteProduct(string id)
{
    // Call your stored procedure: sp_DeleteProduct
    await _context.Database.ExecuteSqlRawAsync(
        "EXEC sp_DeleteProduct @Id",
        new SqlParameter("@Id", id)
    );
    
    return NoContent();
}
```

#### 2. Stock API

**POST /api/stock/update** - Update stock quantity
```csharp
[HttpPost("update")]
public async Task<IActionResult> UpdateStock([FromBody] StockUpdateRequest request)
{
    // Call your stored procedure: sp_UpdateStock
    await _context.Database.ExecuteSqlRawAsync(
        "EXEC sp_UpdateStock @ProductId, @Quantity, @Type, @Reason, @Notes, @Timestamp",
        new SqlParameter("@ProductId", request.ProductId),
        new SqlParameter("@Quantity", request.Quantity),
        new SqlParameter("@Type", request.Type), // 'in', 'out', 'adjustment'
        new SqlParameter("@Reason", request.Reason),
        new SqlParameter("@Notes", request.Notes ?? (object)DBNull.Value),
        new SqlParameter("@Timestamp", request.Timestamp)
    );
    
    return Ok();
}
```

**GET /api/stock/movements** - Get stock movements
```csharp
[HttpGet("movements")]
public async Task<ActionResult<IEnumerable<StockMovement>>> GetStockMovements()
{
    // Call your stored procedure: sp_GetStockMovements
    var movements = await _context.StockMovements
        .FromSqlRaw("EXEC sp_GetStockMovements")
        .ToListAsync();
    
    return Ok(movements);
}
```

#### 3. Dashboard API

**GET /api/dashboard/stats** - Get dashboard statistics
```csharp
[HttpGet("stats")]
public async Task<ActionResult<DashboardStats>> GetDashboardStats()
{
    // Call your stored procedure: sp_GetDashboardStats
    var stats = await _context.DashboardStats
        .FromSqlRaw("EXEC sp_GetDashboardStats")
        .FirstOrDefaultAsync();
    
    return Ok(stats);
}
```

---

## CORS Configuration

Since Flutter web runs on a different port than your ASP.NET API, you must enable CORS:

### Program.cs
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterCors", policy =>
    {
        policy.WithOrigins(
                "http://localhost:8080",    // Flutter web dev server
                "http://localhost:5000",    // Flutter build
                "https://yourdomain.com"    // Production domain
            )
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

// ... other services

var app = builder.Build();

// Use CORS before other middleware
app.UseCors("FlutterCors");

// ... other middleware

app.Run();
```

---

## SQL Server Database Schema

### Tables

```sql
-- Products Table
CREATE TABLE Products (
    Id NVARCHAR(50) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    SKU NVARCHAR(100) NOT NULL UNIQUE,
    Category NVARCHAR(100) NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    MinStockLevel INT NOT NULL DEFAULT 10,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Active',
    ImageUrl NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    Supplier NVARCHAR(255) NULL,
    Location NVARCHAR(100) NULL
);

-- Stock Movements Table
CREATE TABLE StockMovements (
    Id NVARCHAR(50) PRIMARY KEY DEFAULT NEWID(),
    ProductId NVARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Products(Id),
    ProductName NVARCHAR(255) NOT NULL,
    Type NVARCHAR(20) NOT NULL, -- 'in', 'out', 'adjustment'
    Quantity INT NOT NULL,
    Reason NVARCHAR(255) NOT NULL,
    Timestamp DATETIME2 NOT NULL DEFAULT GETDATE(),
    PerformedBy NVARCHAR(255) NULL,
    Notes NVARCHAR(500) NULL
);
```

### Sample Stored Procedures

```sql
-- Get All Products
CREATE PROCEDURE sp_GetAllProducts
AS
BEGIN
    SELECT Id, Name, SKU, Category, Price, StockQuantity, 
           MinStockLevel, Status, ImageUrl, CreatedAt, UpdatedAt, 
           Supplier, Location
    FROM Products
    ORDER BY Name;
END;

-- Get Product By Id
CREATE PROCEDURE sp_GetProductById
    @Id NVARCHAR(50)
AS
BEGIN
    SELECT Id, Name, SKU, Category, Price, StockQuantity, 
           MinStockLevel, Status, ImageUrl, CreatedAt, UpdatedAt, 
           Supplier, Location
    FROM Products
    WHERE Id = @Id;
END;

-- Insert Product
CREATE PROCEDURE sp_InsertProduct
    @Id NVARCHAR(50) = NULL OUTPUT,
    @Name NVARCHAR(255),
    @SKU NVARCHAR(100),
    @Category NVARCHAR(100),
    @Price DECIMAL(18, 2),
    @StockQuantity INT,
    @MinStockLevel INT = 10,
    @Status NVARCHAR(50) = 'Active',
    @Supplier NVARCHAR(255) = NULL,
    @Location NVARCHAR(100) = NULL
AS
BEGIN
    SET @Id = NEWID();
    
    INSERT INTO Products (Id, Name, SKU, Category, Price, StockQuantity, 
                          MinStockLevel, Status, CreatedAt, UpdatedAt, 
                          Supplier, Location)
    VALUES (@Id, @Name, @SKU, @Category, @Price, @StockQuantity, 
            @MinStockLevel, @Status, GETDATE(), GETDATE(), 
            @Supplier, @Location);
END;

-- Update Stock
CREATE PROCEDURE sp_UpdateStock
    @ProductId NVARCHAR(50),
    @Quantity INT,
    @Type NVARCHAR(20),
    @Reason NVARCHAR(255),
    @Notes NVARCHAR(500) = NULL,
    @Timestamp DATETIME2
AS
BEGIN
    BEGIN TRANSACTION;
    
    -- Update product stock
    IF @Type = 'in'
        UPDATE Products SET StockQuantity = StockQuantity + @Quantity, UpdatedAt = GETDATE() WHERE Id = @ProductId;
    ELSE IF @Type = 'out'
        UPDATE Products SET StockQuantity = StockQuantity - @Quantity, UpdatedAt = GETDATE() WHERE Id = @ProductId;
    ELSE IF @Type = 'adjustment'
        UPDATE Products SET StockQuantity = @Quantity, UpdatedAt = GETDATE() WHERE Id = @ProductId;
    
    -- Record movement
    INSERT INTO StockMovements (ProductId, ProductName, Type, Quantity, Reason, Timestamp, Notes)
    SELECT @ProductId, Name, @Type, @Quantity, @Reason, @Timestamp, @Notes
    FROM Products WHERE Id = @ProductId;
    
    COMMIT;
END;

-- Get Dashboard Stats
CREATE PROCEDURE sp_GetDashboardStats
AS
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM Products) AS TotalProducts,
        (SELECT COUNT(*) FROM Products WHERE StockQuantity <= MinStockLevel) AS LowStockItems,
        (SELECT COUNT(*) FROM Products WHERE StockQuantity = 0) AS OutOfStockItems,
        (SELECT ISNULL(SUM(Price * StockQuantity), 0) FROM Products) AS TotalInventoryValue,
        (SELECT COUNT(DISTINCT Category) FROM Products) AS TotalCategories,
        (SELECT COUNT(*) FROM StockMovements WHERE CAST(Timestamp AS DATE) = CAST(GETDATE() AS DATE)) AS TodayMovements;
END;
```

---

## Testing the API Connection

### 1. Test ASP.NET API

First, verify your ASP.NET API is working:
```bash
# Run your ASP.NET API
cd YourApiProject
dotnet run

# Test with curl or browser
curl https://localhost:5001/api/products
```

### 2. Update Flutter API URL

In `lib/services/api_service.dart`, update the base URL:
```dart
static const String baseUrl = 'https://localhost:5001/api';
```

### 3. Test API from Flutter

Create a simple test button in your Flutter app:
```dart
ElevatedButton(
  onPressed: () async {
    try {
      final products = await ApiService.getProducts();
      print('Success! Found ${products.length} products');
    } catch (e) {
      print('Error: $e');
    }
  },
  child: Text('Test API'),
)
```

### 4. Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| CORS errors | Enable CORS in ASP.NET (see above) |
| SSL certificate errors | Use `http` for local dev or trust the certificate |
| 404 Not Found | Check API endpoint paths match exactly |
| JSON parsing errors | Ensure property names match (case-insensitive handled) |

### 5. API Response Format

Your ASP.NET API should return JSON like this:

**Product:**
```json
{
  "id": "1",
  "name": "Laptop Dell XPS 13",
  "sku": "LAP-DEL-001",
  "category": "Electronics",
  "price": 1299.99,
  "stockQuantity": 45,
  "minStockLevel": 10,
  "status": "Active",
  "supplier": "Dell Inc.",
  "location": "A-12-04",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-03-07T14:20:00"
}
```

**Dashboard Stats:**
```json
{
  "totalProducts": 1284,
  "lowStockItems": 23,
  "outOfStockItems": 8,
  "totalInventoryValue": 284520.00,
  "totalCategories": 12,
  "todayMovements": 15
}
```

---

## Next Steps

1. **Set up your ASP.NET project** with the API controllers
2. **Create SQL Server database** and run the schema scripts
3. **Configure CORS** in your ASP.NET app
4. **Update the baseUrl** in Flutter API service
5. **Test the connection** with the test button
6. **Replace mock data** in Flutter screens with API calls

The Flutter frontend is now ready to connect to your ASP.NET backend!
