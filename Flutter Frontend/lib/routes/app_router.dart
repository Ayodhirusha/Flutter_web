import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_admin/screens/dashboard_screen.dart';
import 'package:warehouse_admin/screens/products_screen.dart';
import 'package:warehouse_admin/screens/add_product_screen.dart';
import 'package:warehouse_admin/screens/stock_update_screen.dart';
import 'package:warehouse_admin/widgets/layout/main_layout.dart';

// Static navigator keys to prevent duplicates
class _NavigatorKeys {
  static final root = GlobalKey<NavigatorState>();
  static final shell = GlobalKey<NavigatorState>();
}

final _rootNavigatorKey = _NavigatorKeys.root;
final _shellNavigatorKey = _NavigatorKeys.shell;

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Main layout with all routes
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/products/add',
          name: 'add-product',
          builder: (context, state) => const AddProductScreen(),
        ),
        GoRoute(
          path: '/products/edit/:id',
          name: 'edit-product',
          builder: (context, state) => AddProductScreen(
            productId: state.pathParameters['id'],
          ),
        ),
        GoRoute(
          path: '/stock-update',
          name: 'stock-update',
          builder: (context, state) => const StockUpdateScreen(),
        ),
      ],
    ),
  ],
);
