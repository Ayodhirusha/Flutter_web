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
          decoration: AppTheme.glassDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Search
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search product to update...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product List
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.separated(
                    itemCount: _filteredProducts.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isSelected = _selectedProductId == product.id;
                      return ListTile(
                        selected: isSelected,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        selectedTileColor:
                            AppTheme.primaryColor.withOpacity(0.1),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'SKU: ${product.sku} | Current: ${product.stockQuantity}',
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.textPrimary.withOpacity(0.7)
                                : AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppTheme.primaryColor)
                            : null,
                        onTap: () =>
                            setState(() => _selectedProductId = product.id),
                      );
                    },
                  ),
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
    return Row(
      children: [
        _buildTypeButton(
            'Stock In', Icons.arrow_downward, AppTheme.successColor),
        const SizedBox(width: 8),
        _buildTypeButton('Stock Out', Icons.arrow_upward, AppTheme.errorColor),
        const SizedBox(width: 8),
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
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: isSelected
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : AppTheme.glassDecoration.copyWith(
                  borderRadius: BorderRadius.circular(16),
                ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
