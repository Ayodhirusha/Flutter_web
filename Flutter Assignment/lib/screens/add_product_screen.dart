import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:warehouse_admin/core/theme.dart';
import 'package:warehouse_admin/models/product.dart';
import 'package:warehouse_admin/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  final String? productId;
  const AddProductScreen({super.key, this.productId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController(text: '10');

  String _selectedCategory = 'Processors';
  bool _isLoading = false;

  final _categories = [
    'Processors',
    'Graphics Cards',
    'Memory (RAM)',
    'Storage',
    'Motherboards',
    'Cooling',
    'Power Supplies',
    'Cases',
    'Peripherals',
    'Networking',
    'Cables & Adapters',
    'Software'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await ApiService.getProductById(widget.productId!);
      setState(() {
        _nameController.text = product.name;
        _skuController.text = product.sku;
        _priceController.text = product.price.toString();
        _stockController.text = product.stockQuantity.toString();
        _minStockController.text = product.minStockLevel.toString();
        _selectedCategory = product.category;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load product: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final product = Product(
          id: widget.productId ?? '',
          name: _nameController.text,
          sku: widget.productId != null
              ? _skuController.text
              : _nameController.text.toLowerCase().replaceAll(' ', '-'),
          category: _selectedCategory,
          price: double.parse(_priceController.text),
          stockQuantity: int.parse(_stockController.text),
          minStockLevel: int.parse(_minStockController.text),
          status: 'Active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.productId != null) {
          await ApiService.updateProduct(widget.productId!, product);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
        } else {
          await ApiService.createProduct(product);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product created successfully!')),
          );
        }

        context.go('/products');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/products'),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 16),
            Text(
              widget.productId != null ? 'Edit Product' : 'Add Product',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildProductForm(isMobile),
      ],
    );
  }

  Widget _buildProductForm(bool isMobile) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: AppTheme.glassDecoration.copyWith(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            _buildTextField(
              controller: _nameController,
              label: 'Product Name *',
              hint: 'Enter product name',
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Category
            _buildDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: _categories,
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),

            // Price, Stock & Min Stock - Responsive layout
            isMobile
                ? Column(
                    children: [
                      _buildPriceField(),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _stockController,
                        label: 'Stock *',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _minStockController,
                        label: 'Min Stock *',
                        hint: '10',
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _buildPriceField()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _stockController,
                          label: 'Stock *',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _minStockController,
                          label: 'Min Stock *',
                          hint: '10',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 32),

            // Action Buttons - Responsive
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitForm,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check),
                        label: Text(_isLoading ? 'Saving...' : 'Save Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => context.go('/products'),
                        child: const Text('Cancel'),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitForm,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check),
                        label: Text(_isLoading ? 'Saving...' : 'Save Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed:
                            _isLoading ? null : () => context.go('/products'),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          decoration: const InputDecoration(
            hintText: '0.00',
            prefixText: 'Rs. ',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
