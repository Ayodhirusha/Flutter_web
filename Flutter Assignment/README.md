# Warehouse Admin - Inventory Management System

A modern Flutter Web admin dashboard for Inventory and Warehouse Management.

## Features

- **Dashboard** - Overview with statistic cards showing total products, low stock alerts, inventory value
- **Product Management** - Searchable data table with filters for category and status
- **Add Product** - Complete form for adding new products with validation
- **Stock Update** - Interface for managing inventory movements (stock in, stock out, adjustments)

## Design Style

- Clean SaaS dashboard aesthetic
- Material Design 3 components
- Rounded cards with soft shadows
- Responsive layout for various screen sizes
- Modern spacing and icons

## Project Structure

```
lib/
├── core/
│   └── theme.dart          # App colors, shadows, spacing constants
├── models/
│   └── product.dart        # Data models (Product, StockMovement, DashboardStats)
├── routes/
│   └── app_router.dart     # Navigation routing with go_router
├── screens/
│   ├── dashboard_screen.dart    # Dashboard with statistics
│   ├── products_screen.dart     # Product management table
│   ├── add_product_screen.dart  # Add product form
│   └── stock_update_screen.dart # Stock update interface
├── widgets/
│   ├── layout/
│   │   └── main_layout.dart     # Main layout wrapper
│   ├── sidebar.dart         # Left sidebar navigation
│   ├── top_navbar.dart      # Top navbar with search
│   └── stat_card.dart       # Reusable statistic card
├── app.dart                 # App widget with theme
└── main.dart               # Entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Chrome or other web browser for Flutter Web

### Installation

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

   Or for release build:
   ```bash
   flutter run -d chrome --release
   ```

3. **Build for web deployment:**
   ```bash
   flutter build web
   ```

## Dependencies

- `google_fonts` - Custom typography (Inter font)
- `fl_chart` - Charts (ready for future chart features)
- `intl` - Date formatting
- `go_router` - Navigation routing

## Navigation

| Route | Page |
|-------|------|
| `/` | Dashboard |
| `/products` | Product Management |
| `/products/add` | Add Product |
| `/stock-update` | Stock Update |

## Design System

### Colors
- Primary: `#6366F1` (Indigo)
- Secondary: `#10B981` (Emerald)
- Success: `#22C55E`
- Warning: `#F59E0B`
- Error: `#EF4444`
- Background: `#F8FAFC`
- Sidebar: `#1E293B`

### Shadows
- Soft shadow for cards
- Medium shadow for elevated elements
- Large shadow for modals/drawers

### Spacing
- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px
- 2XL: 48px

## Customization

To customize the theme, edit `lib/core/theme.dart`:
- Change `primaryColor` for the main brand color
- Modify `softShadow`, `mediumShadow`, or `largeShadow` for different shadow effects
- Adjust spacing constants as needed

## Responsive Design

The dashboard automatically adapts to different screen sizes:
- **Desktop (>1200px)**: Full sidebar + 4-column stat grid
- **Tablet (800-1200px)**: 2-column stat grid
- **Mobile (<800px)**: Single column layout

## License

MIT License
