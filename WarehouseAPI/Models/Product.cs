namespace WarehouseAPI.Models;

public class Product
{
    public string Id { get; set; }          // Was ProductID
    public string Name { get; set; }        // Was ProductName
    public string Sku { get; set; }         // Was Barcode
    public string Category { get; set; }
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }  // Was Quantity
    public int MinStockLevel { get; set; }
    public string Status { get; set; }
    public string? ImageUrl { get; set; }
    public string? Supplier { get; set; }
    public string? Location { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}