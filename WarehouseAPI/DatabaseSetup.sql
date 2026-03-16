-- =============================================
-- WarehouseDB Database Setup Script
-- Run this in SQL Server Management Studio (SSMS) or Azure Data Studio
-- =============================================

-- Create the database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'WarehouseDB')
BEGIN
    CREATE DATABASE WarehouseDB;
END
GO

USE WarehouseDB;
GO

-- =============================================
-- Create Tables
-- =============================================

-- Products Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' AND xtype='U')
BEGIN
    CREATE TABLE Products (
        Id NVARCHAR(50) PRIMARY KEY,
        Name NVARCHAR(200) NOT NULL,
        Sku NVARCHAR(100) NOT NULL,
        Category NVARCHAR(100) NOT NULL,
        Price DECIMAL(18, 2) NOT NULL DEFAULT 0,
        StockQuantity INT NOT NULL DEFAULT 0,
        MinStockLevel INT NOT NULL DEFAULT 10,
        Status NVARCHAR(50) NOT NULL DEFAULT 'Active',
        ImageUrl NVARCHAR(500) NULL,
        Supplier NVARCHAR(200) NULL,
        Location NVARCHAR(200) NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
    );
END
GO

-- StockMovements Table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='StockMovements' AND xtype='U')
BEGIN
    CREATE TABLE StockMovements (
        Id NVARCHAR(50) PRIMARY KEY,
        ProductId NVARCHAR(50) NOT NULL,
        ProductName NVARCHAR(200) NOT NULL,
        Type NVARCHAR(50) NOT NULL, -- 'in', 'out', 'adjustment'
        Quantity INT NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        Timestamp DATETIME2 NOT NULL DEFAULT GETDATE(),
        PerformedBy NVARCHAR(200) NULL,
        Notes NVARCHAR(1000) NULL,
        CONSTRAINT FK_StockMovements_Products FOREIGN KEY (ProductId) REFERENCES Products(Id)
    );
END
GO

-- =============================================
-- Create Stored Procedures
-- =============================================

-- sp_GetProducts - Get all products
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_GetProducts' AND xtype='P')
    DROP PROCEDURE sp_GetProducts;
GO

CREATE PROCEDURE sp_GetProducts
AS
BEGIN
    SELECT 
        Id,
        Name,
        Sku,
        Category,
        Price,
        StockQuantity,
        MinStockLevel,
        Status,
        ImageUrl,
        Supplier,
        Location,
        CreatedAt,
        UpdatedAt
    FROM Products
    ORDER BY Name;
END
GO

-- sp_GetProductById - Get product by ID
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_GetProductById' AND xtype='P')
    DROP PROCEDURE sp_GetProductById;
GO

CREATE PROCEDURE sp_GetProductById
    @Id NVARCHAR(50)
AS
BEGIN
    SELECT 
        Id,
        Name,
        Sku,
        Category,
        Price,
        StockQuantity,
        MinStockLevel,
        Status,
        ImageUrl,
        Supplier,
        Location,
        CreatedAt,
        UpdatedAt
    FROM Products
    WHERE Id = @Id;
END
GO

-- sp_AddProduct - Create new product
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_AddProduct' AND xtype='P')
    DROP PROCEDURE sp_AddProduct;
GO

CREATE PROCEDURE sp_AddProduct
    @Id NVARCHAR(50),
    @Name NVARCHAR(200),
    @Sku NVARCHAR(100),
    @Category NVARCHAR(100),
    @Price DECIMAL(18, 2),
    @StockQuantity INT,
    @MinStockLevel INT,
    @Status NVARCHAR(50),
    @ImageUrl NVARCHAR(500),
    @Supplier NVARCHAR(200),
    @Location NVARCHAR(200)
AS
BEGIN
    INSERT INTO Products (Id, Name, Sku, Category, Price, StockQuantity, MinStockLevel, Status, ImageUrl, Supplier, Location, CreatedAt, UpdatedAt)
    VALUES (@Id, @Name, @Sku, @Category, @Price, @StockQuantity, @MinStockLevel, @Status, @ImageUrl, @Supplier, @Location, GETDATE(), GETDATE());
END
GO

-- sp_UpdateProduct - Update product
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_UpdateProduct' AND xtype='P')
    DROP PROCEDURE sp_UpdateProduct;
GO

CREATE PROCEDURE sp_UpdateProduct
    @Id NVARCHAR(50),
    @Name NVARCHAR(200),
    @Sku NVARCHAR(100),
    @Category NVARCHAR(100),
    @Price DECIMAL(18, 2),
    @StockQuantity INT,
    @MinStockLevel INT,
    @Status NVARCHAR(50),
    @ImageUrl NVARCHAR(500),
    @Supplier NVARCHAR(200),
    @Location NVARCHAR(200)
AS
BEGIN
    UPDATE Products
    SET Name = @Name,
        Sku = @Sku,
        Category = @Category,
        Price = @Price,
        StockQuantity = @StockQuantity,
        MinStockLevel = @MinStockLevel,
        Status = @Status,
        ImageUrl = @ImageUrl,
        Supplier = @Supplier,
        Location = @Location,
        UpdatedAt = GETDATE()
    WHERE Id = @Id;
END
GO

-- sp_DeleteProduct - Delete product
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_DeleteProduct' AND xtype='P')
    DROP PROCEDURE sp_DeleteProduct;
GO

CREATE PROCEDURE sp_DeleteProduct
    @Id NVARCHAR(50)
AS
BEGIN
    DELETE FROM Products WHERE Id = @Id;
END
GO

-- sp_UpdateStock - Update stock quantity and record movement
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_UpdateStock' AND xtype='P')
    DROP PROCEDURE sp_UpdateStock;
GO

CREATE PROCEDURE sp_UpdateStock
    @ProductId NVARCHAR(50),
    @Quantity INT,
    @Type NVARCHAR(50),
    @Reason NVARCHAR(500),
    @Notes NVARCHAR(1000) = NULL,
    @Timestamp DATETIME2 = NULL
AS
BEGIN
    IF @Timestamp IS NULL
        SET @Timestamp = GETDATE();

    DECLARE @NewId NVARCHAR(50) = NEWID();
    DECLARE @ProductName NVARCHAR(200);

    -- Get product name
    SELECT @ProductName = Name FROM Products WHERE Id = @ProductId;

    -- Record the stock movement
    INSERT INTO StockMovements (Id, ProductId, ProductName, Type, Quantity, Reason, Timestamp, PerformedBy, Notes)
    VALUES (@NewId, @ProductId, @ProductName, @Type, @Quantity, @Reason, @Timestamp, 'System', @Notes);

    -- Update product stock quantity based on movement type
    IF @Type = 'in'
    BEGIN
        UPDATE Products SET StockQuantity = StockQuantity + @Quantity, UpdatedAt = GETDATE() WHERE Id = @ProductId;
    END
    ELSE IF @Type = 'out'
    BEGIN
        UPDATE Products SET StockQuantity = StockQuantity - @Quantity, UpdatedAt = GETDATE() WHERE Id = @ProductId;
    END
    ELSE IF @Type = 'adjustment'
    BEGIN
        UPDATE Products SET StockQuantity = @Quantity, UpdatedAt = GETDATE() WHERE Id = @ProductId;
    END
END
GO

-- sp_GetStockMovements - Get all stock movements
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_GetStockMovements' AND xtype='P')
    DROP PROCEDURE sp_GetStockMovements;
GO

CREATE PROCEDURE sp_GetStockMovements
AS
BEGIN
    SELECT 
        Id,
        ProductId,
        ProductName,
        Type,
        Quantity,
        Reason,
        Timestamp,
        PerformedBy,
        Notes
    FROM StockMovements
    ORDER BY Timestamp DESC;
END
GO

-- sp_GetDashboardStats - Get dashboard statistics
IF EXISTS (SELECT * FROM sysobjects WHERE name='sp_GetDashboardStats' AND xtype='P')
    DROP PROCEDURE sp_GetDashboardStats;
GO

CREATE PROCEDURE sp_GetDashboardStats
AS
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM Products) AS TotalProducts,
        (SELECT COUNT(*) FROM Products WHERE StockQuantity <= MinStockLevel AND StockQuantity > 0) AS LowStockItems,
        (SELECT COUNT(*) FROM Products WHERE StockQuantity = 0) AS OutOfStockItems,
        (SELECT ISNULL(SUM(Price * StockQuantity), 0) FROM Products) AS TotalInventoryValue,
        (SELECT COUNT(DISTINCT Category) FROM Products) AS TotalCategories,
        (SELECT COUNT(*) FROM StockMovements WHERE CAST(Timestamp AS DATE) = CAST(GETDATE() AS DATE)) AS TodayMovements;
END
GO

-- =============================================
-- Insert Sample Data (Optional)
-- =============================================

-- Add sample products
IF NOT EXISTS (SELECT * FROM Products WHERE Id = 'PROD-001')
BEGIN
    INSERT INTO Products (Id, Name, Sku, Category, Price, StockQuantity, MinStockLevel, Status, Supplier, Location)
    VALUES 
        ('PROD-001', 'Laptop Dell XPS 15', 'LAP-DEL-001', 'Electronics', 1299.99, 25, 5, 'Active', 'Dell Inc.', 'Warehouse A-12'),
        ('PROD-002', 'Wireless Mouse Logitech', 'MOU-LOG-001', 'Electronics', 29.99, 150, 20, 'Active', 'Logitech', 'Warehouse B-03'),
        ('PROD-003', 'Mechanical Keyboard', 'KEY-MECH-001', 'Electronics', 89.99, 45, 10, 'Active', 'Keychron', 'Warehouse B-04'),
        ('PROD-004', '27-inch Monitor 4K', 'MON-4K-001', 'Electronics', 349.99, 8, 5, 'Active', 'LG', 'Warehouse A-15'),
        ('PROD-005', 'USB-C Hub', 'USB-HUB-001', 'Electronics', 49.99, 0, 15, 'Out of Stock', 'Anker', 'Warehouse C-01'),
        ('PROD-006', 'Office Chair Ergonomic', 'CHR-ERG-001', 'Furniture', 299.99, 12, 3, 'Active', 'Herman Miller', 'Warehouse D-08'),
        ('PROD-007', 'Standing Desk', 'DESK-STND-001', 'Furniture', 499.99, 6, 2, 'Low Stock', 'Autonomous', 'Warehouse D-09');
END
GO

PRINT 'WarehouseDB setup completed successfully!';
GO
