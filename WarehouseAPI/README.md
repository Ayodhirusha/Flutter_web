# Warehouse API - Setup Guide

## Project Overview
This is the ASP.NET Web API backend for the Warehouse Admin Flutter application.

## Prerequisites
- .NET 10.0 SDK
- SQL Server (LocalDB, Express, or full instance)
- Visual Studio 2022 or VS Code

## Database Setup

### Option 1: Using SQL Server LocalDB (Default)
The default connection string uses LocalDB (installed with Visual Studio):
```json
"ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\MSSQLLocalDB;Database=WarehouseDB;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

### Option 2: Using SQL Server Express or Full Instance
Update `appsettings.json` with your connection string:
```json
"ConnectionStrings": {
    "DefaultConnection": "Server=YOUR_SERVER;Database=WarehouseDB;User Id=YOUR_USER;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
}
```

### Step-by-Step Database Setup

1. **Open SQL Server Management Studio (SSMS)** or **Azure Data Studio**

2. **Connect to your SQL Server instance**
   - For LocalDB: Server name = `(localdb)\MSSQLLocalDB`
   - For Express: Server name = `localhost\SQLEXPRESS`

3. **Run the Database Setup Script**
   - Open `DatabaseSetup.sql` in SSMS
   - Execute the script (F5 or click Execute)
   - This creates:
     - `WarehouseDB` database
     - `Products` table
     - `StockMovements` table
     - All required stored procedures
     - Sample data (optional)

4. **Verify Connection**
   - The API will automatically connect using the connection string in `appsettings.json`

## Running the API

### Using Visual Studio
1. Open `WarehouseAPI.slnx`
2. Press F5 or click the Play button
3. The API will start at `https://localhost:5163` (or another port)

### Using VS Code or Command Line
```bash
cd WarehouseAPI
dotnet run
```

### Verify API is Running
Open a browser and navigate to:
- `http://localhost:5163/api/products` - Should return JSON array of products
- Swagger UI: `http://localhost:5163/swagger` (if enabled in development)

## API Endpoints

### Products
- `GET /api/products` - Get all products
- `GET /api/products/{id}` - Get product by ID
- `POST /api/products` - Create new product
- `PUT /api/products/{id}` - Update product
- `DELETE /api/products/{id}` - Delete product

### Stock
- `POST /api/stock/update` - Update stock quantity
- `GET /api/stock/movements` - Get stock movement history

### Dashboard
- `GET /api/dashboard/stats` - Get dashboard statistics

## Troubleshooting

### Database Connection Errors
1. **Verify SQL Server is running**
   - Open Services (services.msc)
   - Look for "SQL Server (MSSQLSERVER)" or "SQL Server (SQLEXPRESS)"
   - Ensure status is "Running"

2. **Check connection string**
   - Verify server name is correct
   - For LocalDB: `(localdb)\MSSQLLocalDB`
   - For Express: `localhost\SQLEXPRESS`

3. **Run DatabaseSetup.sql again**
   - The database or stored procedures might be missing

### Port Already in Use
If port 5163 is in use, the API will use a different port. Check the console output for the actual URL.

### CORS Issues
The API is configured to allow all origins (`AllowAll` CORS policy). This is suitable for development. For production, configure specific allowed origins in `Program.cs`.

## Connection String Examples

### SQL Server LocalDB (Windows)
```json
"Server=(localdb)\\MSSQLLocalDB;Database=WarehouseDB;Trusted_Connection=True;TrustServerCertificate=True;"
```

### SQL Server with Windows Authentication
```json
"Server=localhost;Database=WarehouseDB;Integrated Security=True;TrustServerCertificate=True;"
```

### SQL Server with SQL Authentication
```json
"Server=localhost;Database=WarehouseDB;User Id=sa;Password=YourPassword;TrustServerCertificate=True;"
```

### Azure SQL Database
```json
"Server=myserver.database.windows.net;Database=WarehouseDB;User Id=myuser;Password=mypassword;Encrypt=True;"
```

## Next Steps
1. Run the database setup script
2. Start the API backend
3. Configure the Flutter frontend to point to the correct API URL
4. Test the connection
