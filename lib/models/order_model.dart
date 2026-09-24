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
    double price = 0.0;
    if (json['price'] != null) {
      price = (json['price'] is num) ? (json['price'] as num).toDouble() : (double.tryParse(json['price']?.toString() ?? '0') ?? 0.0);
    } else if (json['unitPrice'] != null) {
      price = (json['unitPrice'] is num) ? (json['unitPrice'] as num).toDouble() : (double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0);
    }

    int qty = 1;
    if (json['quantity'] != null) {
      qty = json['quantity'] is int ? json['quantity'] : (int.tryParse(json['quantity']?.toString() ?? '1') ?? 1);
    }

    double tot = price * qty;
    if (json['totalAmount'] != null) {
      tot = (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : (double.tryParse(json['totalAmount']?.toString() ?? '0') ?? tot);
    }

    return OrderItem(
      productId: json['productId'] ?? json['product_id'] ?? json['id'] ?? '',
      title: json['name'] ?? json['title'] ?? 'Item',
      variantTitle: json['sku'] ?? json['variantTitle'] ?? json['variant_title'],
      quantity: qty,
      unitPrice: price,
      totalAmount: tot,
      image: json['image'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': title,
        'title': title,
        'variantTitle': variantTitle,
        'sku': variantTitle,
        'quantity': quantity,
        'price': unitPrice,
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
    final s = (json['status'] ?? json['fulfillmentStatus'] ?? '').toString().toLowerCase();
    if (s.contains('confirm')) {
      oStatus = OrderStatus.confirmed;
    } else if (s.contains('process')) {
      oStatus = OrderStatus.processing;
    } else if (s.contains('ship')) {
      oStatus = OrderStatus.shipped;
    } else if (s.contains('deliver') || s.contains('complete')) {
      oStatus = OrderStatus.delivered;
    } else if (s.contains('cancel') || s.contains('refund')) {
      oStatus = OrderStatus.cancelled;
    }

    List<OrderItem> itemsList = [];
    final rawItems = json['lineItems'] ?? json['items'];
    if (rawItems != null && rawItems is List) {
      itemsList = rawItems
          .map((i) => OrderItem.fromJson(Map<String, dynamic>.from(i)))
          .toList();
    }

    String custName = 'Farmer Customer';
    if (json['shippingAddress'] is Map && json['shippingAddress']['name'] != null && json['shippingAddress']['name'].toString().isNotEmpty) {
      custName = json['shippingAddress']['name'].toString();
    } else if (json['billingAddress'] is Map && json['billingAddress']['name'] != null && json['billingAddress']['name'].toString().isNotEmpty) {
      custName = json['billingAddress']['name'].toString();
    } else if (json['customerName'] != null) {
      custName = json['customerName'].toString();
    } else if (json['customer'] is Map && json['customer']['name'] != null) {
      custName = json['customer']['name'].toString();
    }

    String custPhone = json['phone'] ?? json['customerPhone'] ?? (json['customer'] is Map ? json['customer']['phone'] : null) ?? '+91 9876543210';
    String? custEmail = json['email'] ?? json['customerEmail'] ?? (json['customer'] is Map ? json['customer']['email'] : null);

    String shipAddr = 'Village Agri Sector, Maharashtra, India';
    if (json['shippingAddress'] is String && json['shippingAddress'].toString().isNotEmpty) {
      shipAddr = json['shippingAddress'].toString();
    } else if (json['shippingAddress'] is Map) {
      final sa = json['shippingAddress'] as Map;
      final parts = [
        sa['address1'] ?? sa['street'],
        sa['address2'],
        sa['city'],
        sa['province'],
        sa['zip'],
        sa['country'] ?? 'India'
      ].where((p) => p != null && p.toString().trim().isNotEmpty).toList();
      if (parts.isNotEmpty) shipAddr = parts.join(', ');
    } else if (json['address'] != null) {
      shipAddr = json['address'].toString();
    }

    double subTot = 0.0;
    if (json['subtotal'] != null) {
      subTot = (json['subtotal'] is num) ? (json['subtotal'] as num).toDouble() : (double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0);
    }

    double disc = 0.0;
    if (json['discountAmount'] != null) {
      disc = (json['discountAmount'] is num) ? (json['discountAmount'] as num).toDouble() : (double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0);
    } else if (json['discount'] != null) {
      disc = (json['discount'] is num) ? (json['discount'] as num).toDouble() : (double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0);
    }

    double delCharge = 0.0;
    if (json['shipping'] != null) {
      delCharge = (json['shipping'] is num) ? (json['shipping'] as num).toDouble() : (double.tryParse(json['shipping']?.toString() ?? '0') ?? 0.0);
    } else if (json['deliveryCharge'] != null) {
      delCharge = (json['deliveryCharge'] is num) ? (json['deliveryCharge'] as num).toDouble() : (double.tryParse(json['deliveryCharge']?.toString() ?? '0') ?? 0.0);
    }

    double totAmt = subTot;
    if (json['total'] != null) {
      totAmt = (json['total'] is num) ? (json['total'] as num).toDouble() : (double.tryParse(json['total']?.toString() ?? '0') ?? subTot);
    } else if (json['totalAmount'] != null) {
      totAmt = (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : (double.tryParse(json['totalAmount']?.toString() ?? '0') ?? subTot);
    }

    String orderNum = json['name'] ?? json['orderNumber'] ?? json['order_number'] ?? '#KB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    String payMethod = json['paymentMethod'] ?? 'Razorpay Online';
    String payStatus = json['financialStatus'] ?? json['paymentStatus'] ?? 'Completed';

    return OrderModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      orderNumber: orderNum,
      customerName: custName,
      customerPhone: custPhone,
      customerEmail: custEmail,
      shippingAddress: shipAddr,
      items: itemsList,
      subtotal: subTot,
      discount: disc,
      deliveryCharge: delCharge,
      totalAmount: totAmt,
      paymentMethod: payMethod,
      paymentStatus: payStatus,
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
