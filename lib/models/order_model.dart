import 'package:flutter/material.dart';

enum OrderStatus {
  notConfirmed,
  confirmed,
  shipped,
  rackUp,
  inTransit,
  outForDelivery,
  delivered,
  rtoInTransit,
  rtoDelivered,
  hold,
  delayed,
  lost,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.notConfirmed:
        return 'Not Confirmed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.rackUp:
        return 'Rack Up';
      case OrderStatus.inTransit:
        return 'In-Transit';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.rtoInTransit:
        return 'RTO In-Transit';
      case OrderStatus.rtoDelivered:
        return 'RTO Delivered';
      case OrderStatus.hold:
        return 'Hold';
      case OrderStatus.delayed:
        return 'Delayed';
      case OrderStatus.lost:
        return 'Lost';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get apiValue {
    switch (this) {
      case OrderStatus.notConfirmed:
        return 'not_confirmed';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.rackUp:
        return 'rack_up';
      case OrderStatus.inTransit:
        return 'in_transit';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.rtoInTransit:
        return 'rto_in_transit';
      case OrderStatus.rtoDelivered:
        return 'rto_delivered';
      case OrderStatus.hold:
        return 'hold';
      case OrderStatus.delayed:
        return 'delayed';
      case OrderStatus.lost:
        return 'lost';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  Color get badgeBg {
    switch (this) {
      case OrderStatus.notConfirmed:
        return const Color(0xFFFCEAE6);
      case OrderStatus.confirmed:
        return const Color(0xFFE2F0D9);
      case OrderStatus.shipped:
        return const Color(0xFFD9E8FB);
      case OrderStatus.rackUp:
        return const Color(0xFFD1E1EB);
      case OrderStatus.inTransit:
        return const Color(0xFFFCF0D3);
      case OrderStatus.outForDelivery:
        return const Color(0xFF8A1C14);
      case OrderStatus.delivered:
        return const Color(0xFF38761D);
      case OrderStatus.rtoInTransit:
        return const Color(0xFF3F606F);
      case OrderStatus.rtoDelivered:
        return const Color(0xFFE1D5E7);
      case OrderStatus.hold:
        return const Color(0xFF4A86E8);
      case OrderStatus.delayed:
        return const Color(0xFFE69138);
      case OrderStatus.lost:
        return const Color(0xFFD9EAD3);
      case OrderStatus.cancelled:
        return const Color(0xFFF8CECC);
    }
  }

  Color get badgeFg {
    switch (this) {
      case OrderStatus.notConfirmed:
        return const Color(0xFF9C4221);
      case OrderStatus.confirmed:
        return const Color(0xFF2E7D32);
      case OrderStatus.shipped:
        return const Color(0xFF1565C0);
      case OrderStatus.rackUp:
        return const Color(0xFF37474F);
      case OrderStatus.inTransit:
        return const Color(0xFFD97706);
      case OrderStatus.outForDelivery:
        return Colors.white;
      case OrderStatus.delivered:
        return Colors.white;
      case OrderStatus.rtoInTransit:
        return Colors.white;
      case OrderStatus.rtoDelivered:
        return const Color(0xFF6B21A8);
      case OrderStatus.hold:
        return Colors.white;
      case OrderStatus.delayed:
        return Colors.white;
      case OrderStatus.lost:
        return const Color(0xFF365314);
      case OrderStatus.cancelled:
        return const Color(0xFF991B1B);
    }
  }

  static OrderStatus fromString(String? val) {
    if (val == null || val.isEmpty) return OrderStatus.notConfirmed;
    final s = val.toLowerCase().trim().replaceAll('-', '_').replaceAll(' ', '_');
    switch (s) {
      case 'not_confirmed':
      case 'pending':
        return OrderStatus.notConfirmed;
      case 'confirmed':
      case 'processing':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'rack_up':
      case 'rackup':
        return OrderStatus.rackUp;
      case 'in_transit':
      case 'intransit':
        return OrderStatus.inTransit;
      case 'out_for_delivery':
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
      case 'completed':
        return OrderStatus.delivered;
      case 'rto_in_transit':
      case 'rtointransit':
        return OrderStatus.rtoInTransit;
      case 'rto_delivered':
      case 'rtodelivered':
        return OrderStatus.rtoDelivered;
      case 'hold':
      case 'on_hold':
        return OrderStatus.hold;
      case 'delayed':
        return OrderStatus.delayed;
      case 'lost':
        return OrderStatus.lost;
      case 'cancelled':
      case 'canceled':
      case 'refunded':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.notConfirmed;
    }
  }
}

class OrderItem {
  final String productId;
  final String title;
  final String? variantTitle;
  final String? sku;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String? image;

  OrderItem({
    required this.productId,
    required this.title,
    this.variantTitle,
    this.sku,
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

    final rawSku = (json['sku'] ?? json['variantSku'] ?? json['variant_sku'] ?? '').toString().trim();
    final rawVariantTitle = (json['variantTitle'] ?? json['variant_title'] ?? json['option'] ?? '').toString().trim();

    String? imageUrl;
    var rawImage = json['image'] ?? json['imageUrl'] ?? json['img'] ?? json['featuredImage'] ?? json['productImage'];

    if (rawImage != null) {
      if (rawImage is String) {
        imageUrl = rawImage;
      } else if (rawImage is Map) {
        imageUrl = (rawImage['src'] ?? rawImage['url'] ?? rawImage['original'] ?? rawImage['medium'] ?? rawImage['low'])?.toString();
      }
    }

    if (imageUrl == null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      final first = json['images'][0];
      if (first is Map) {
        imageUrl = (first['src'] ?? first['url'] ?? first['original'] ?? first['medium'] ?? first['low'])?.toString();
      } else {
        imageUrl = first?.toString();
      }
    }

    if (imageUrl != null) {
      imageUrl = imageUrl.trim();
      if (imageUrl.startsWith('/uploads/')) {
        imageUrl = 'https://backend-bhandar-205278744741.asia-south1.run.app$imageUrl';
      } else if (imageUrl.isEmpty) {
        imageUrl = null;
      }
    }

    return OrderItem(
      productId: (json['productId'] ?? json['product_id'] ?? json['id'] ?? '').toString(),
      title: (json['name'] ?? json['title'] ?? 'Product Item').toString(),
      variantTitle: rawVariantTitle.isNotEmpty ? rawVariantTitle : null,
      sku: rawSku.isNotEmpty ? rawSku : (rawVariantTitle.isNotEmpty ? rawVariantTitle : null),
      quantity: qty,
      unitPrice: price,
      totalAmount: tot,
      image: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': title,
        'title': title,
        'variantTitle': variantTitle,
        'sku': sku,
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
    this.status = OrderStatus.notConfirmed,
    required this.createdAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? json['orderStatus'] ?? json['fulfillmentStatus'] ?? '').toString();
    final oStatus = OrderStatusX.fromString(rawStatus);

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
