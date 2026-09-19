enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderItem {
  final String productId;
  final String title;
  final String? variantTitle;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? image;

  OrderItem({
    required this.productId,
    required this.title,
    this.variantTitle,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? json['product_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'Item',
      variantTitle: json['variantTitle'] ?? json['variant_title'],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] is num) ? (json['unitPrice'] as num).toDouble() : (double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0),
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : (double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0),
      image: json['image'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'variantTitle': variantTitle,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalAmount': totalAmount,
        'image': image,
      };
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String shippingAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.deliveryCharge = 0.0,
    required this.totalAmount,
    this.paymentMethod = 'Online / Razorpay',
    this.paymentStatus = 'Paid',
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    OrderStatus oStatus = OrderStatus.pending;
    final s = (json['status'] ?? '').toString().toLowerCase();
    if (s.contains('confirm')) {
      oStatus = OrderStatus.confirmed;
    } else if (s.contains('process')) {
      oStatus = OrderStatus.processing;
    } else if (s.contains('ship')) {
      oStatus = OrderStatus.shipped;
    } else if (s.contains('deliver')) {
      oStatus = OrderStatus.delivered;
    } else if (s.contains('cancel')) {
      oStatus = OrderStatus.cancelled;
    }

    List<OrderItem> itemsList = [];
    if (json['items'] != null && json['items'] is List) {
      itemsList = (json['items'] as List)
          .map((i) => OrderItem.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    return OrderModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '#KB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      customerName: json['customerName'] ?? (json['customer'] != null ? json['customer']['name'] : 'Farmer Customer') ?? 'Farmer Customer',
      customerPhone: json['customerPhone'] ?? (json['customer'] != null ? json['customer']['phone'] : '+91 9876543210') ?? '+91 9876543210',
      customerEmail: json['customerEmail'],
      shippingAddress: json['shippingAddress'] ?? json['address'] ?? 'Village Agri Sector, Maharashtra, India',
      items: itemsList,
      subtotal: (json['subtotal'] is num) ? (json['subtotal'] as num).toDouble() : (double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0),
      discount: (json['discount'] is num) ? (json['discount'] as num).toDouble() : (double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0),
      deliveryCharge: (json['deliveryCharge'] is num) ? (json['deliveryCharge'] as num).toDouble() : 0.0,
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : (double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0),
      paymentMethod: json['paymentMethod'] ?? 'Razorpay Online',
      paymentStatus: json['paymentStatus'] ?? 'Completed',
      status: oStatus,
      createdAt: json['createdAt'] != null ? (DateTime.tryParse(json['createdAt']) ?? DateTime.now()) : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt']) : null,
    );
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? shippingAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? deliveryCharge,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
