# Use official .NET SDK image to build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY WarehouseAPI/WarehouseAPI.csproj ./
RUN dotnet restore

# Copy all files and build
COPY WarehouseAPI/. ./
RUN dotnet publish -c Release -o /app/publish

# Use runtime image for smaller size
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish ./

EXPOSE 8080

ENTRYPOINT ["dotnet", "WarehouseAPI.dll"]
