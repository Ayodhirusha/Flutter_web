class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final int stockQuantity;
  final int minStockLevel;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? supplier;
  final String? location;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stockQuantity,
    this.minStockLevel = 10,
    required this.status,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.supplier,
    this.location,
  });

  bool get isLowStock => stockQuantity <= minStockLevel;
  bool get isOutOfStock => stockQuantity == 0;

  // JSON deserialization - for receiving data from ASP.NET API
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? '',
      name: json['name'] ?? json['Name'] ?? '',
      sku: json['sku'] ?? json['SKU'] ?? '',
      category: json['category'] ?? json['Category'] ?? '',
      price: (json['price'] ?? json['Price'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? json['StockQuantity'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? json['MinStockLevel'] ?? 10,
      status: json['status'] ?? json['Status'] ?? 'Active',
      imageUrl: json['imageUrl'] ?? json['ImageUrl'],
      createdAt: json['createdAt'] != null || json['CreatedAt'] != null
          ? DateTime.parse(json['createdAt'] ?? json['CreatedAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['UpdatedAt'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['UpdatedAt'])
          : DateTime.now(),
      supplier: json['supplier'] ?? json['Supplier'],
      location: json['location'] ?? json['Location'],
    );
  }

  // JSON serialization - for sending data to ASP.NET API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'price': price,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'status': status,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'supplier': supplier,
      'location': location,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    double? price,
    int? stockQuantity,
    int? minStockLevel,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? supplier,
    String? location,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      supplier: supplier ?? this.supplier,
      location: location ?? this.location,
    );
  }
}

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'in', 'out', 'adjustment'
  final int quantity;
  final String reason;
  final DateTime timestamp;
  final String? performedBy;
  final String? notes;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.timestamp,
    this.performedBy,
    this.notes,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id']?.toString() ?? json['Id']?.toString() ?? '',
      productId:
          json['productId']?.toString() ?? json['ProductId']?.toString() ?? '',
      productName: json['productName'] ?? json['ProductName'] ?? '',
      type: json['type'] ?? json['Type'] ?? '',
      quantity: json['quantity'] ?? json['Quantity'] ?? 0,
      reason: json['reason'] ?? json['Reason'] ?? '',
      timestamp: json['timestamp'] != null || json['Timestamp'] != null
          ? DateTime.parse(json['timestamp'] ?? json['Timestamp'])
          : DateTime.now(),
      performedBy: json['performedBy'] ?? json['PerformedBy'],
      notes: json['notes'] ?? json['Notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
      'notes': notes,
    };
  }
}

class DashboardStats {
  final int totalProducts;
  final int lowStockItems;
  final int outOfStockItems;
  final double totalInventoryValue;
  final int totalCategories;
  final int todayMovements;

  DashboardStats({
    required this.totalProducts,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.totalInventoryValue,
    required this.totalCategories,
    required this.todayMovements,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: json['totalProducts'] ?? json['TotalProducts'] ?? 0,
      lowStockItems: json['lowStockItems'] ?? json['LowStockItems'] ?? 0,
      outOfStockItems: json['outOfStockItems'] ?? json['OutOfStockItems'] ?? 0,
      totalInventoryValue:
          (json['totalInventoryValue'] ?? json['TotalInventoryValue'] ?? 0)
              .toDouble(),
      totalCategories: json['totalCategories'] ?? json['TotalCategories'] ?? 0,
      todayMovements: json['todayMovements'] ?? json['TodayMovements'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'totalInventoryValue': totalInventoryValue,
      'totalCategories': totalCategories,
      'todayMovements': todayMovements,
    };
  }
}
