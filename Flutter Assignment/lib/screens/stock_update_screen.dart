import 'package:flutter/material.dart';
import 'package:warehouse_admin/core/theme.dart';
import 'package:warehouse_admin/models/product.dart';
import 'package:warehouse_admin/services/api_service.dart';

class StockUpdateScreen extends StatefulWidget {
  const StockUpdateScreen({super.key});

  @override
  State<StockUpdateScreen> createState() => _StockUpdateScreenState();
}

class _StockUpdateScreenState extends State<StockUpdateScreen> {
  final _searchController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  String? _selectedProductId;
  String _movementType = 'in';
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isUpdating = false;
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

  Future<void> _submitUpdate() async {
    if (_selectedProductId == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select product and enter quantity')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await ApiService.updateStock(
        productId: _selectedProductId!,
        quantity: int.parse(_quantityController.text),
        type: _movementType,
        reason: _reasonController.text.isNotEmpty
            ? _reasonController.text
            : 'Stock update',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated successfully!')),
      );

      setState(() {
        _selectedProductId = null;
        _quantityController.clear();
        _reasonController.clear();
        _searchController.clear();
      });

      // Reload products to show updated stock
      await _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update stock: $e')),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  List<Product> get _filteredProducts {
    if (_searchController.text.isEmpty) return _products;
    return _products
        .where((p) =>
            p.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            p.sku.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
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
        Text(
          'Stock Update',
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 24),

        // Movement Type Selection - horizontal on desktop, vertical on mobile
        isMobile ? _buildMobileTypeButtons() : _buildDesktopTypeButtons(),
        const SizedBox(height: 24),

        // Form
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Search
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search product...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),

              // Product List
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final isSelected = _selectedProductId == product.id;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                      title: Text(product.name),
                      subtitle: Text(
                          'Stock: ${product.stockQuantity} | SKU: ${product.sku}'),
                      onTap: () =>
                          setState(() => _selectedProductId = product.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Quantity & Reason
              isMobile
                  ? Column(
                      children: [
                        TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Quantity',
                            prefixIcon: Icon(Icons.numbers),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            hintText: 'Reason (optional)',
                            prefixIcon: Icon(Icons.note),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Quantity',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _reasonController,
                            decoration: const InputDecoration(
                              hintText: 'Reason (optional)',
                              prefixIcon: Icon(Icons.note),
                            ),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : _submitUpdate,
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check),
                  label: Text(_isUpdating ? 'Updating...' : 'Update Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTypeButtons() {
    return Column(
      children: [
        _buildTypeButton(
            'Stock In', Icons.arrow_downward, AppTheme.successColor),
        const SizedBox(height: 8),
        _buildTypeButton('Stock Out', Icons.arrow_upward, AppTheme.errorColor),
        const SizedBox(height: 8),
        _buildTypeButton('Adjustment', Icons.sync_alt, AppTheme.infoColor),
      ],
    );
  }

  Widget _buildDesktopTypeButtons() {
    return Row(
      children: [
        _buildTypeButton(
            'Stock In', Icons.arrow_downward, AppTheme.successColor),
        const SizedBox(width: 12),
        _buildTypeButton('Stock Out', Icons.arrow_upward, AppTheme.errorColor),
        const SizedBox(width: 12),
        _buildTypeButton('Adjustment', Icons.sync_alt, AppTheme.infoColor),
      ],
    );
  }

  Widget _buildTypeButton(String label, IconData icon, Color color) {
    final typeValue = label == 'Stock In'
        ? 'in'
        : label == 'Stock Out'
            ? 'out'
            : 'adjustment';
    final isSelected = _movementType == typeValue;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _movementType = typeValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
