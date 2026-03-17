namespace WarehouseAPI.Models;

public class DashboardStats
{
    public int TotalProducts { get; set; }
    public int LowStockItems { get; set; }
    public int OutOfStockItems { get; set; }
    public decimal TotalInventoryValue { get; set; }
    public int TotalCategories { get; set; }
    public int TodayMovements { get; set; }
}
