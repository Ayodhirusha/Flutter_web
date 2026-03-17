import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warehouse_admin/models/product.dart';

class ApiService {
  // backend URL - update this with your ASP.NET API URL
  static const baseUrl = "http://localhost:5163/api";

  static final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ==================== PRODUCT APIs ====================

  // GET: api/products - Get all products
  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: defaultHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  // GET: api/products/{id} - Get product by ID
  static Future<Product> getProductById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: defaultHeaders,
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  // POST: api/products - Create new product
  static Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: defaultHeaders,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.statusCode}');
    }
  }

  // PUT: api/products/{id} - Update product
  static Future<void> updateProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: defaultHeaders,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
    // Success - no need to return anything
  }

  // DELETE: api/products/{id} - Delete product
  static Future<void> deleteProduct(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: defaultHeaders,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  // ==================== STOCK APIs ====================

  // POST: api/stock/update - Update stock quantity
  static Future<void> updateStock({
    required String productId,
    required int quantity,
    required String type, // 'in', 'out', 'adjustment'
    required String reason,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stock/update'),
      headers: defaultHeaders,
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
        'type': type,
        'reason': reason,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = response.body.trim();
      throw Exception(
          'Failed to update stock: ${response.statusCode}${body.isNotEmpty ? ' - $body' : ''}');
    }
  }

  // GET: api/stock/movements - Get stock movements
  static Future<List<StockMovement>> getStockMovements() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stock/movements'),
      headers: defaultHeaders,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => StockMovement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stock movements: ${response.statusCode}');
    }
  }

  // ==================== DASHBOARD APIs ====================

  // GET: api/dashboard/stats - Get dashboard statistics
  static Future<DashboardStats> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/stats'),
      headers: defaultHeaders,
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats: ${response.statusCode}');
    }
  }
}
