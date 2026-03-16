namespace WarehouseAPI.Models;

public class StockMovement
{
    public string Id { get; set; }
    public string ProductId { get; set; }
    public string ProductName { get; set; }
    public string Type { get; set; } // 'in', 'out', 'adjustment'
    public int Quantity { get; set; }
    public string Reason { get; set; }
    public DateTime Timestamp { get; set; }
    public string? PerformedBy { get; set; }
    public string? Notes { get; set; }
}
