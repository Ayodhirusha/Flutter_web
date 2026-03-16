# Deployment Guide

## Backend (.NET Web API) - Render

### Option 1: Render (Recommended for Free Hosting)

1. **Push code to GitHub**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. **Create Render Account**
   - Go to https://render.com
   - Sign up with GitHub

3. **New Web Service**
   - Click "New +" → "Web Service"
   - Connect your GitHub repo
   - Select the `WarehouseAPI` folder

4. **Configure Service**
   - **Name**: warehouse-api
   - **Environment**: .NET
   - **Build Command**: `dotnet publish -c Release -o ./out`
   - **Start Command**: `dotnet ./out/WarehouseAPI.dll`
   - **Plan**: Free

5. **Environment Variables**
   Add these in Render dashboard:
   ```
   ASPNETCORE_ENVIRONMENT=Production
   ConnectionStrings__DefaultConnection=Server=your-sql-server;Database=WarehouseDB;User Id=your-user;Password=your-password;
   ```

6. **Deploy**
   - Click "Create Web Service"
   - Render auto-deploys on every push

### Option 2: Azure App Service (If you have Azure credits)

```bash
# Install Azure CLI
az login

# Create resource group
az group create --name warehouse-rg --location eastus

# Create app service plan (FREE tier)
az appservice plan create --name warehouse-plan --resource-group warehouse-rg --sku F1 --is-linux

# Create web app
az webapp create --name warehouse-api-app --resource-group warehouse-rg --plan warehouse-plan --runtime "dotnetcore:8.0"

# Deploy
az webapp deployment source config-zip --resource-group warehouse-rg --name warehouse-api-app --src ./publish.zip
```

---

## Frontend (Flutter Web) - Firebase

### Prerequisites
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login
```

### Deploy Steps

1. **Build Flutter Web**
   ```bash
   flutter build web --release
   ```

2. **Initialize Firebase** (First time only)
   ```bash
   firebase init hosting
   # Select: Use existing project or create new
   # Public directory: build/web
   # Configure as single-page app: Yes
   ```

3. **Deploy**
   ```bash
   firebase deploy --only hosting
   ```

Your app will be live at: `https://your-project-id.web.app`

---

## Alternative: Netlify (Even Easier)

1. **Build Flutter Web**
   ```bash
   flutter build web --release
   ```

2. **Drag & Drop Deploy**
   - Go to https://app.netlify.com/drop
   - Drag the `build/web` folder
   - Done! Site is live instantly

Or use Netlify CLI:
```bash
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```

---

## Database Setup for Production

### SQL Server Options

1. **Azure SQL Database** (Free tier: 250 GB for 12 months)
2. **AWS RDS SQL Server** (Free tier: 750 hours/month for 12 months)
3. **ElephantSQL** (PostgreSQL - Free 20MB, would need to migrate)
4. **Self-hosted** (Keep current setup, but need static IP)

### Important: Update API Base URL

After hosting backend, update the Flutter API service:

```dart
// lib/services/api_service.dart
// Change from:
static const String baseUrl = 'http://localhost:5163/api';

// To your hosted backend:
static const String baseUrl = 'https://warehouse-api.onrender.com/api';
```

---

## Quick Checklist

- [ ] Backend pushed to GitHub
- [ ] Render web service created
- [ ] Environment variables configured
- [ ] Database accessible from Render
- [ ] Frontend `baseUrl` updated to production
- [ ] Flutter web built (`flutter build web`)
- [ ] Frontend deployed to Firebase/Netlify
- [ ] Test login and all features

## Troubleshooting

### CORS Issues
Update `Program.cs` to add your frontend domain:
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",
                "https://your-project.web.app",  // Firebase
                "https://your-project.netlify.app" // Netlify
            )
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});
```

### Database Connection Failures
- Check firewall rules allow Render/Azure IP
- Verify connection string format
- Ensure SQL Server allows remote connections
