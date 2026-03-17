import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_admin/core/theme.dart';
import 'package:warehouse_admin/models/product.dart';
import 'package:warehouse_admin/services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Product> _products = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() => _isLoading = true);
      final products = await ApiService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _showDeleteConfirmation(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProduct(id);
    }
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await ApiService.deleteProduct(id);
      setState(() {
        _products.removeWhere((p) => p.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/products/add'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/products/add'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 20),

        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 20),

        // Products List/Table
        isMobile ? _buildMobileProductList() : _buildDesktopProductTable(),
      ],
    );
  }

  Widget _buildMobileProductList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildMobileProductCard(product);
      },
    );
  }

  Widget _buildMobileProductCard(Product product) {
    // Determine status based on stock quantity
    final (statusText, statusColor) = _getStatusInfo(product);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category Type',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                    Text(product.category,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                    Text('LKR${product.price}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                    Text('${product.stockQuantity}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  if (product.id.isNotEmpty) {
                    context.go('/products/edit/${product.id}');
                  }
                },
                icon: const Icon(Icons.edit,
                    size: 20, color: AppTheme.primaryColor),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(product.id),
                icon: const Icon(Icons.delete,
                    size: 20, color: AppTheme.errorColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProductTable() {
    return Container(
      decoration: AppTheme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(
                  bottom:
                      BorderSide(color: AppTheme.borderColor.withOpacity(0.5))),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Name',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Category Type',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Price',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Stock',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                    child: Text('Status',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 80),
              ],
            ),
          ),

          // Table Body
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredProducts.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.grey.shade100, height: 1),
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return _buildDesktopProductRow(product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopProductRow(Product product) {
    // Determine status based on stock quantity
    final (statusText, statusColor) = _getStatusInfo(product);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(product.category)),
          Expanded(child: Text('LKR${product.price}')),
          Expanded(child: Text('${product.stockQuantity}')),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    if (product.id.isNotEmpty) {
                      context.go('/products/edit/${product.id}');
                    }
                  },
                  icon: const Icon(Icons.edit,
                      size: 20, color: AppTheme.primaryColor),
                ),
                IconButton(
                  onPressed: () => _showDeleteConfirmation(product.id),
                  icon: const Icon(Icons.delete,
                      size: 20, color: AppTheme.errorColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine status based on stock quantity
  (String, Color) _getStatusInfo(Product product) {
    if (product.stockQuantity == 0) {
      return ('Out of Stock', AppTheme.errorColor);
    } else if (product.stockQuantity <= product.minStockLevel) {
      return ('Low Stock', AppTheme.warningColor);
    } else {
      return ('Active', AppTheme.successColor);
    }
  }
}
