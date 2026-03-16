# Backend Integration Guide: Flutter + ASP.NET Core + SQL Server

## Overview
Connect your Flutter Web admin dashboard to an ASP.NET Core Web API backend with SQL Server using stored procedures.

---

## Step 1: ASP.NET Core Web API Setup

### 1.1 Create New ASP.NET Core Web API Project
```bash
dotnet new webapi -n WarehouseAPI
cd WarehouseAPI
```

### 1.2 Install Required NuGet Packages
```bash
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Dapper  # For stored procedures
dotnet add package System.Data.SqlClient
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer  # For JWT auth
dotnet add package Swashbuckle.AspNetCore  # API documentation
```

---

## Step 2: SQL Server Database & Stored Procedures

### 2.1 Create Database
```sql
CREATE DATABASE WarehouseDB;
GO

USE WarehouseDB;
GO
```

### 2.2 Create Tables
```sql
-- Users Table
CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    Email NVARCHAR(255) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    FullName NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50) DEFAULT 'Admin',
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    LastLogin DATETIME2 NULL
);

-- Categories Table
CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(500)
);

-- Products Table
CREATE TABLE Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    SKU NVARCHAR(100) UNIQUE NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(1000),
    CategoryId INT FOREIGN KEY REFERENCES Categories(CategoryId),
    Barcode NVARCHAR(100),
    Quantity INT DEFAULT 0,
    MinStock INT DEFAULT 10,
    Price DECIMAL(18,2) NOT NULL,
    Cost DECIMAL(18,2) NOT NULL,
    Supplier NVARCHAR(255),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

-- StockTransactions Table
CREATE TABLE StockTransactions (
    TransactionId INT PRIMARY KEY IDENTITY(1,1),
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    Quantity INT NOT NULL,  -- Positive = Stock In, Negative = Stock Out
    Type NVARCHAR(50),  -- 'IN' or 'OUT'
    Reference NVARCHAR(255),  -- Invoice number, etc.
    Notes NVARCHAR(500),
    UserId INT FOREIGN KEY REFERENCES Users(UserId),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
```

### 2.3 Create Stored Procedures

#### Authentication SPs
```sql
-- User Login
CREATE PROCEDURE sp_UserLogin
    @Email NVARCHAR(255),
    @PasswordHash NVARCHAR(500)
AS
BEGIN
    SELECT 
        UserId,
        Email,
        FullName,
        Role,
        CreatedAt
    FROM Users
    WHERE Email = @Email AND PasswordHash = @PasswordHash;
    
    -- Update last login
    UPDATE Users SET LastLogin = GETDATE() WHERE Email = @Email;
END;
GO

-- User Registration
CREATE PROCEDURE sp_UserRegister
    @Email NVARCHAR(255),
    @PasswordHash NVARCHAR(500),
    @FullName NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
    BEGIN
        SELECT -1 AS UserId; -- Email exists
        RETURN;
    END
    
    INSERT INTO Users (Email, PasswordHash, FullName)
    VALUES (@Email, @PasswordHash, @FullName);
    
    SELECT SCOPE_IDENTITY() AS UserId;
END;
GO
```

#### Product SPs
```sql
-- Get All Products
CREATE PROCEDURE sp_GetProducts
    @Search NVARCHAR(255) = NULL,
    @CategoryId INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SELECT 
        p.ProductId,
        p.SKU,
        p.Name,
        p.Description,
        c.Name AS CategoryName,
        p.Barcode,
        p.Quantity,
        p.MinStock,
        p.Price,
        p.Cost,
        p.Supplier,
        p.CreatedAt,
        p.UpdatedAt,
        CASE 
            WHEN p.Quantity = 0 THEN 'Out of Stock'
            WHEN p.Quantity <= p.MinStock THEN 'Low Stock'
            ELSE 'In Stock'
        END AS StockStatus
    FROM Products p
    LEFT JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE (@Search IS NULL OR p.Name LIKE '%' + @Search + '%' OR p.SKU LIKE '%' + @Search + '%')
        AND (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
    ORDER BY p.UpdatedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
    
    -- Return total count for pagination
    SELECT COUNT(*) AS TotalCount FROM Products
    WHERE (@Search IS NULL OR Name LIKE '%' + @Search + '%')
        AND (@CategoryId IS NULL OR CategoryId = @CategoryId);
END;
GO

-- Get Product by ID
CREATE PROCEDURE sp_GetProductById
    @ProductId INT
AS
BEGIN
    SELECT 
        p.*,
        c.Name AS CategoryName,
        CASE 
            WHEN p.Quantity = 0 THEN 'Out of Stock'
            WHEN p.Quantity <= p.MinStock THEN 'Low Stock'
            ELSE 'In Stock'
        END AS StockStatus
    FROM Products p
    LEFT JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE p.ProductId = @ProductId;
END;
GO

-- Create Product
CREATE PROCEDURE sp_CreateProduct
    @SKU NVARCHAR(100),
    @Name NVARCHAR(255),
    @Description NVARCHAR(1000),
    @CategoryId INT,
    @Barcode NVARCHAR(100),
    @Quantity INT,
    @MinStock INT,
    @Price DECIMAL(18,2),
    @Cost DECIMAL(18,2),
    @Supplier NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Products WHERE SKU = @SKU)
    BEGIN
        SELECT -1 AS ProductId; -- SKU exists
        RETURN;
    END
    
    INSERT INTO Products (SKU, Name, Description, CategoryId, Barcode, 
                       Quantity, MinStock, Price, Cost, Supplier)
    VALUES (@SKU, @Name, @Description, @CategoryId, @Barcode,
            @Quantity, @MinStock, @Price, @Cost, @Supplier);
    
    SELECT SCOPE_IDENTITY() AS ProductId;
END;
GO

-- Update Product
CREATE PROCEDURE sp_UpdateProduct
    @ProductId INT,
    @SKU NVARCHAR(100),
    @Name NVARCHAR(255),
    @Description NVARCHAR(1000),
    @CategoryId INT,
    @Barcode NVARCHAR(100),
    @MinStock INT,
    @Price DECIMAL(18,2),
    @Cost DECIMAL(18,2),
    @Supplier NVARCHAR(255)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Products WHERE SKU = @SKU AND ProductId != @ProductId)
    BEGIN
        SELECT 0 AS Success; -- SKU exists for another product
        RETURN;
    END
    
    UPDATE Products
    SET SKU = @SKU,
        Name = @Name,
        Description = @Description,
        CategoryId = @CategoryId,
        Barcode = @Barcode,
        MinStock = @MinStock,
        Price = @Price,
        Cost = @Cost,
        Supplier = @Supplier,
        UpdatedAt = GETDATE()
    WHERE ProductId = @ProductId;
    
    SELECT 1 AS Success;
END;
GO

-- Delete Product
CREATE PROCEDURE sp_DeleteProduct
    @ProductId INT
AS
BEGIN
    DELETE FROM StockTransactions WHERE ProductId = @ProductId;
    DELETE FROM Products WHERE ProductId = @ProductId;
    SELECT 1 AS Success;
END;
GO
```

#### Stock Management SPs
```sql
-- Update Stock (Add/Remove)
CREATE PROCEDURE sp_UpdateStock
    @ProductId INT,
    @Quantity INT,  -- Positive or Negative
    @Type NVARCHAR(50),  -- 'IN' or 'OUT'
    @Reference NVARCHAR(255),
    @Notes NVARCHAR(500),
    @UserId INT
AS
BEGIN
    BEGIN TRANSACTION;
    
    -- Update product quantity
    UPDATE Products
    SET Quantity = Quantity + @Quantity,
        UpdatedAt = GETDATE()
    WHERE ProductId = @ProductId;
    
    -- Record transaction
    INSERT INTO StockTransactions (ProductId, Quantity, Type, Reference, Notes, UserId)
    VALUES (@ProductId, @Quantity, @Type, @Reference, @Notes, @UserId);
    
    COMMIT;
    
    -- Return updated product info
    EXEC sp_GetProductById @ProductId;
END;
GO

-- Get Stock Transactions
CREATE PROCEDURE sp_GetStockTransactions
    @ProductId INT = NULL,
    @FromDate DATETIME2 = NULL,
    @ToDate DATETIME2 = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SELECT 
        t.TransactionId,
        t.ProductId,
        p.Name AS ProductName,
        p.SKU,
        t.Quantity,
        t.Type,
        t.Reference,
        t.Notes,
        u.FullName AS UserName,
        t.CreatedAt
    FROM StockTransactions t
    JOIN Products p ON t.ProductId = p.ProductId
    JOIN Users u ON t.UserId = u.UserId
    WHERE (@ProductId IS NULL OR t.ProductId = @ProductId)
        AND (@FromDate IS NULL OR t.CreatedAt >= @FromDate)
        AND (@ToDate IS NULL OR t.CreatedAt <= @ToDate)
    ORDER BY t.CreatedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO

-- Get Dashboard Stats
CREATE PROCEDURE sp_GetDashboardStats
AS
BEGIN
    -- Total products
    SELECT COUNT(*) AS TotalProducts FROM Products;
    
    -- Low stock count
    SELECT COUNT(*) AS LowStock FROM Products WHERE Quantity <= MinStock AND Quantity > 0;
    
    -- Out of stock count
    SELECT COUNT(*) AS OutOfStock FROM Products WHERE Quantity = 0;
    
    -- Total inventory value
    SELECT ISNULL(SUM(Quantity * Cost), 0) AS TotalValue FROM Products;
    
    -- Recent activity (last 10 transactions)
    SELECT TOP 10
        t.TransactionId,
        p.Name AS ProductName,
        p.SKU,
        t.Quantity,
        t.Type,
        t.CreatedAt
    FROM StockTransactions t
    JOIN Products p ON t.ProductId = p.ProductId
    ORDER BY t.CreatedAt DESC;
END;
GO
```

---

## Step 3: ASP.NET Core API Implementation

### 3.1 Project Structure
```
WarehouseAPI/
├── Controllers/
│   ├── AuthController.cs
│   ├── ProductsController.cs
│   ├── StockController.cs
│   └── DashboardController.cs
├── Models/
│   ├── User.cs
│   ├── Product.cs
│   ├── StockTransaction.cs
│   ├── LoginRequest.cs
│   └── LoginResponse.cs
├── Services/
│   ├── IAuthService.cs
│   ├── AuthService.cs
│   ├── IProductService.cs
│   └── ProductService.cs
├── Data/
│   └── SqlConnectionFactory.cs
├── Helpers/
│   └── PasswordHasher.cs
└── Program.cs
```

### 3.2 Create Models

**Models/Product.cs**
```csharp
public class Product
{
    public int ProductId { get; set; }
    public string SKU { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public int? CategoryId { get; set; }
    public string CategoryName { get; set; }
    public string Barcode { get; set; }
    public int Quantity { get; set; }
    public int MinStock { get; set; }
    public decimal Price { get; set; }
    public decimal Cost { get; set; }
    public string Supplier { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string StockStatus { get; set; }
}
```

**Models/User.cs**
```csharp
public class User
{
    public int UserId { get; set; }
    public string Email { get; set; }
    public string FullName { get; set; }
    public string Role { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class LoginRequest
{
    public string Email { get; set; }
    public string Password { get; set; }
}

public class RegisterRequest
{
    public string Email { get; set; }
    public string Password { get; set; }
    public string FullName { get; set; }
}

public class LoginResponse
{
    public bool Success { get; set; }
    public string Token { get; set; }
    public User User { get; set; }
    public string Message { get; set; }
}
```

### 3.3 Create SQL Connection Factory

**Data/SqlConnectionFactory.cs**
```csharp
public class SqlConnectionFactory
{
    private readonly string _connectionString;

    public SqlConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection");
    }

    public SqlConnection CreateConnection()
    {
        return new SqlConnection(_connectionString);
    }
}
```

### 3.4 Create Services

**Services/IAuthService.cs**
```csharp
public interface IAuthService
{
    Task<LoginResponse> LoginAsync(LoginRequest request);
    Task<LoginResponse> RegisterAsync(RegisterRequest request);
}
```

**Services/AuthService.cs**
```csharp
public class AuthService : IAuthService
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly IConfiguration _configuration;

    public AuthService(SqlConnectionFactory connectionFactory, IConfiguration configuration)
    {
        _connectionFactory = connectionFactory;
        _configuration = configuration;
    }

    public async Task<LoginResponse> LoginAsync(LoginRequest request)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        var passwordHash = PasswordHasher.HashPassword(request.Password);
        
        var parameters = new { Email = request.Email, PasswordHash = passwordHash };
        var user = await connection.QueryFirstOrDefaultAsync<User>(
            "sp_UserLogin", 
            parameters, 
            commandType: CommandType.StoredProcedure);

        if (user == null)
        {
            return new LoginResponse { Success = false, Message = "Invalid credentials" };
        }

        var token = GenerateJwtToken(user);
        
        return new LoginResponse 
        { 
            Success = true, 
            Token = token, 
            User = user,
            Message = "Login successful"
        };
    }

    public async Task<LoginResponse> RegisterAsync(RegisterRequest request)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        var passwordHash = PasswordHasher.HashPassword(request.Password);
        
        var parameters = new 
        { 
            Email = request.Email, 
            PasswordHash = passwordHash,
            FullName = request.FullName 
        };
        
        var userId = await connection.ExecuteScalarAsync<int>(
            "sp_UserRegister", 
            parameters, 
            commandType: CommandType.StoredProcedure);

        if (userId == -1)
        {
            return new LoginResponse { Success = false, Message = "Email already exists" };
        }

        return await LoginAsync(new LoginRequest 
        { 
            Email = request.Email, 
            Password = request.Password 
        });
    }

    private string GenerateJwtToken(User user)
    {
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Name, user.FullName),
            new Claim(ClaimTypes.Role, user.Role)
        };

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.Now.AddDays(7),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

**Services/IProductService.cs**
```csharp
public interface IProductService
{
    Task<(List<Product> Products, int TotalCount)> GetProductsAsync(
        string search, int? categoryId, int pageNumber, int pageSize);
    Task<Product> GetProductByIdAsync(int id);
    Task<int> CreateProductAsync(Product product);
    Task<bool> UpdateProductAsync(Product product);
    Task<bool> DeleteProductAsync(int id);
}
```

**Services/ProductService.cs**
```csharp
public class ProductService : IProductService
{
    private readonly SqlConnectionFactory _connectionFactory;

    public ProductService(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<(List<Product> Products, int TotalCount)> GetProductsAsync(
        string search, int? categoryId, int pageNumber, int pageSize)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        var parameters = new
        {
            Search = search,
            CategoryId = categoryId,
            PageNumber = pageNumber,
            PageSize = pageSize
        };

        using var multi = await connection.QueryMultipleAsync(
            "sp_GetProducts", 
            parameters, 
            commandType: CommandType.StoredProcedure);

        var products = (await multi.ReadAsync<Product>()).ToList();
        var totalCount = await multi.ReadSingleAsync<int>();

        return (products, totalCount);
    }

    public async Task<Product> GetProductByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        return await connection.QueryFirstOrDefaultAsync<Product>(
            "sp_GetProductById", 
            new { ProductId = id }, 
            commandType: CommandType.StoredProcedure);
    }

    public async Task<int> CreateProductAsync(Product product)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        var parameters = new
        {
            product.SKU,
            product.Name,
            product.Description,
            product.CategoryId,
            product.Barcode,
            product.Quantity,
            product.MinStock,
            product.Price,
            product.Cost,
            product.Supplier
        };

        return await connection.ExecuteScalarAsync<int>(
            "sp_CreateProduct", 
            parameters, 
            commandType: CommandType.StoredProcedure);
    }

    public async Task<bool> UpdateProductAsync(Product product)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        var parameters = new
        {
            product.ProductId,
            product.SKU,
            product.Name,
            product.Description,
            product.CategoryId,
            product.Barcode,
            product.MinStock,
            product.Price,
            product.Cost,
            product.Supplier
        };

        var result = await connection.ExecuteScalarAsync<int>(
            "sp_UpdateProduct", 
            parameters, 
            commandType: CommandType.StoredProcedure);

        return result == 1;
    }

    public async Task<bool> DeleteProductAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync();

        var result = await connection.ExecuteScalarAsync<int>(
            "sp_DeleteProduct", 
            new { ProductId = id }, 
            commandType: CommandType.StoredProcedure);

        return result == 1;
    }
}
```

### 3.5 Create Controllers

**Controllers/AuthController.cs**
```csharp
[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<LoginResponse>> Login(LoginRequest request)
    {
        var response = await _authService.LoginAsync(request);
        if (!response.Success)
            return Unauthorized(response);
        return Ok(response);
    }

    [HttpPost("register")]
    public async Task<ActionResult<LoginResponse>> Register(RegisterRequest request)
    {
        var response = await _authService.RegisterAsync(request);
        if (!response.Success)
            return BadRequest(response);
        return Ok(response);
    }
}
```

**Controllers/ProductsController.cs**
```csharp
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;

    public ProductsController(IProductService productService)
    {
        _productService = productService;
    }

    [HttpGet]
    public async Task<ActionResult<PagedResult<Product>>> GetProducts(
        [FromQuery] string search = null,
        [FromQuery] int? categoryId = null,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 20)
    {
        var (products, totalCount) = await _productService.GetProductsAsync(
            search, categoryId, pageNumber, pageSize);

        return Ok(new PagedResult<Product>
        {
            Items = products,
            TotalCount = totalCount,
            PageNumber = pageNumber,
            PageSize = pageSize
        });
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        var product = await _productService.GetProductByIdAsync(id);
        if (product == null) return NotFound();
        return Ok(product);
    }

    [HttpPost]
    public async Task<ActionResult<int>> CreateProduct(Product product)
    {
        var id = await _productService.CreateProductAsync(product);
        if (id == -1) return BadRequest("SKU already exists");
        return CreatedAtAction(nameof(GetProduct), new { id }, id);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, Product product)
    {
        product.ProductId = id;
        var success = await _productService.UpdateProductAsync(product);
        if (!success) return BadRequest("SKU already exists");
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        await _productService.DeleteProductAsync(id);
        return NoContent();
    }
}
```

### 3.6 Program.cs Configuration
```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
});

// Register services
builder.Services.AddSingleton<SqlConnectionFactory>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IProductService, ProductService>();

// JWT Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// CORS for Flutter Web
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterApp", policy =>
    {
        policy.WithOrigins("http://localhost:5000", "http://localhost:8080")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("FlutterApp");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

### 3.7 appsettings.json
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=WarehouseDB;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
  },
  "Jwt": {
    "Key": "YourSuperSecretKey123!@#",
    "Issuer": "WarehouseAPI",
    "Audience": "WarehouseApp"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  }
}
```

---

## Step 4: Update Flutter App for API Integration

### 4.1 Update ApiService

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warehouse_admin/services/auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://localhost:7001/api'; // Update with your API URL
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (AuthService().token != null) 
      'Authorization': 'Bearer ${AuthService().token}',
  };

  // Auth APIs
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': name,
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  // Product APIs
  static Future<List<dynamic>> getProducts({
    String? search,
    int? categoryId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final queryParams = {
      if (search != null) 'search': search,
      if (categoryId != null) 'categoryId': categoryId.toString(),
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };
    
    final uri = Uri.parse('$baseUrl/products')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    }
    throw Exception('Failed to load products');
  }

  static Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: headers,
      body: jsonEncode(product),
    );
    return jsonDecode(response.body);
  }

  static Future<void> updateProduct(
      int id, Map<String, dynamic> product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: headers,
      body: jsonEncode(product),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: headers,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  // Dashboard API
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/stats'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }
}
```

### 4.2 Update AuthService to Use API

```dart
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  String? _token;
  String? _userEmail;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      
      if (response['success'] == true) {
        _token = response['token'];
        _userEmail = response['user']['email'];
        _userName = response['user']['fullName'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      final response = await ApiService.register(name, email, password);
      
      if (response['success'] == true) {
        _token = response['token'];
        _userEmail = response['user']['email'];
        _userName = response['user']['fullName'];
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    _token = null;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
}
```

---

## Step 5: Run & Test

### 5.1 Start ASP.NET API
```bash
cd WarehouseAPI
dotnet run
```

### 5.2 API Endpoints
- **Swagger UI**: https://localhost:7001/swagger
- **Login**: POST /api/auth/login
- **Register**: POST /api/auth/register
- **Products**: GET/POST /api/products
- **Product Detail**: GET/PUT/DELETE /api/products/{id}

### 5.3 Update Flutter for Production
Change `baseUrl` in ApiService to your deployed API URL:
```dart
static const String baseUrl = 'https://your-api-domain.com/api';
```

---

## Additional Notes

### Security Checklist
- [ ] Use HTTPS in production
- [ ] Store JWT key securely (Azure Key Vault, AWS Secrets Manager)
- [ ] Hash passwords with salt (use BCrypt or Argon2)
- [ ] Add rate limiting
- [ ] Validate all inputs
- [ ] Use parameterized queries (already using SPs)

### Flutter Web CORS
If you get CORS errors in Flutter Web, ensure your API allows the Flutter web origin:
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("FlutterApp", policy =>
    {
        policy.WithOrigins("https://your-flutter-app.com")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});
```

### Useful Commands
```bash
# Run API with hot reload
dotnet watch run

# Create EF migration (if using EF Core)
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update

# Publish for production
dotnet publish -c Release
```
