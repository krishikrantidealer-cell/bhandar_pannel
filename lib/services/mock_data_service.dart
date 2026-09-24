import '../models/category_model.dart';
import '../models/collection_model.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/coupon_model.dart';
import '../models/order_model.dart';
import '../models/dashboard_stats.dart';

class MockDataService {
  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        id: 'cat_fungicides',
        name: 'Fungicides',
        slug: 'fungicides',
        title: 'Crop Disease Protection & Fungicides',
        description: 'Comprehensive fungal control for agricultural crops',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/fungicides_full.webp',
        stripBanner: 'https://storage.googleapis.com/bhandar-product-images/banners/strip/fungicides_full.webp',
        iconImage: 'https://storage.googleapis.com/krishi-product-images/categoryicons/fungicides_1786955071212.webp',
        cataloguePdf: 'https://storage.googleapis.com/krishi-product-images/categorycatalogues/fungicides_1784705328136.pdf',
        productsCount: 42,
        subCategories: [
          SubCategory(id: 'sub_f1', name: 'Chemical-Fungicide'),
          SubCategory(id: 'sub_f2', name: 'Bio-Fungicide'),
          SubCategory(id: 'sub_f3', name: 'Organic-Fungicide'),
        ],
      ),
      CategoryModel(
        id: 'cat_insecticides',
        name: 'Insecticides',
        slug: 'insecticides',
        title: 'Insect Pest Control Solutions',
        description: 'Broad-spectrum pest repellents and systemic insecticides',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/insecticides_full.webp',
        stripBanner: 'https://storage.googleapis.com/bhandar-product-images/banners/strip/insecticides_full.webp',
        productsCount: 58,
        subCategories: [
          SubCategory(id: 'sub_i1', name: 'Systemic Insecticide'),
          SubCategory(id: 'sub_i2', name: 'Contact Insecticide'),
          SubCategory(id: 'sub_i3', name: 'Bio-Insecticide'),
        ],
      ),
      CategoryModel(
        id: 'cat_herbicides',
        name: 'Herbicides',
        slug: 'herbicides',
        title: 'Weed Control Solutions',
        description: 'Selective and non-selective weed control solutions',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/herbicides_full.webp',
        stripBanner: 'https://storage.googleapis.com/bhandar-product-images/banners/strip/herbicides_full.webp',
        productsCount: 31,
        subCategories: [
          SubCategory(id: 'sub_h1', name: 'Chemical Herbicide'),
          SubCategory(id: 'sub_h2', name: 'Pre-Emergent'),
        ],
      ),
      CategoryModel(
        id: 'cat_pgrs',
        name: 'PGRs',
        slug: 'pgrs',
        title: 'Plant Growth Regulators & Boosters',
        description: 'Enhance plant vegetative development, flowering, and fruit setting',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/pgrs_full.webp',
        stripBanner: 'https://storage.googleapis.com/bhandar-product-images/banners/strip/pgrs_full.webp',
        productsCount: 26,
        subCategories: [
          SubCategory(id: 'sub_p1', name: 'Bio Stimulants'),
          SubCategory(id: 'sub_p2', name: 'Growth Promoters'),
        ],
      ),
      CategoryModel(
        id: 'cat_fertilizers',
        name: 'Fertilizers & Nutrients',
        slug: 'fertilizers',
        title: 'Micro & Macro Crop Nutrients',
        description: 'Water-soluble fertilizers, Chelated Zinc, Boron & NPK Blends',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/fertilizers_full.webp',
        stripBanner: 'https://storage.googleapis.com/bhandar-product-images/banners/strip/fertilizers_full.webp',
        productsCount: 64,
        subCategories: [
          SubCategory(id: 'sub_fert1', name: 'NPK 19:19:19'),
          SubCategory(id: 'sub_fert2', name: 'Micronutrient Mix'),
          SubCategory(id: 'sub_fert3', name: 'Chelated Zinc & Boron'),
        ],
      ),
    ];
  }

  static List<ProductModel> getProducts() {
    return [
      ProductModel(
        id: 'prod_1',
        title: 'Bhandar Super Chlorpyrifos 50% + Cypermethrin 5% EC',
        description: 'High efficiency combination insecticide for sucking and chewing pests in cotton and paddy.',
        category: 'Insecticides',
        subCategory: 'Systemic Insecticide',
        brand: 'Krishi Bhandar',
        price: 780.0,
        mrp: 950.0,
        stock: 150,
        inStock: true,
        images: [
          'https://storage.googleapis.com/bhandar-product-images/banners/category/insecticides_full.webp',
        ],
        variants: [
          ProductVariant(id: 'v1_1', title: '500 ml', price: 420.0, mrp: 510.0, inventoryQuantity: 80, sku: 'KB-IN-500'),
          ProductVariant(id: 'v1_2', title: '1 Litre', price: 780.0, mrp: 950.0, inventoryQuantity: 70, sku: 'KB-IN-1000'),
        ],
      ),
      ProductModel(
        id: 'prod_2',
        title: 'Bhandar Mancozeb 75% WP Broad Spectrum Fungicide',
        description: 'Protective contact fungicide for early and late blight in potato, tomato, and fruit crops.',
        category: 'Fungicides',
        subCategory: 'Chemical-Fungicide',
        brand: 'Krishi Bhandar',
        price: 360.0,
        mrp: 450.0,
        stock: 320,
        inStock: true,
        images: [
          'https://storage.googleapis.com/bhandar-product-images/banners/category/fungicides_full.webp',
        ],
        variants: [
          ProductVariant(id: 'v2_1', title: '500 g', price: 360.0, mrp: 450.0, inventoryQuantity: 200, sku: 'KB-FG-500'),
          ProductVariant(id: 'v2_2', title: '1 kg', price: 680.0, mrp: 850.0, inventoryQuantity: 120, sku: 'KB-FG-1000'),
        ],
      ),
      ProductModel(
        id: 'prod_3',
        title: 'Bhandar Humic Acid 98% Bio Stimulant & Root Booster',
        description: 'Organic soil conditioner and plant metabolic stimulant for high root growth and soil aeration.',
        category: 'PGRs',
        subCategory: 'Bio Stimulants',
        brand: 'Krishi Bhandar',
        price: 499.0,
        mrp: 750.0,
        stock: 18, // low stock alert
        inStock: true,
        images: [
          'https://storage.googleapis.com/bhandar-product-images/banners/category/pgrs_full.webp',
        ],
      ),
      ProductModel(
        id: 'prod_4',
        title: 'Bhandar Glyphosate 41% SL Non-Selective Herbicide',
        description: 'Post-emergence systemic herbicide for total weed control in non-cropped areas and tea plantations.',
        category: 'Herbicides',
        subCategory: 'Chemical Herbicide',
        brand: 'Krishi Bhandar',
        price: 520.0,
        mrp: 650.0,
        stock: 95,
        inStock: true,
        images: [
          'https://storage.googleapis.com/bhandar-product-images/banners/category/herbicides_full.webp',
        ],
      ),
      ProductModel(
        id: 'prod_5',
        title: 'Bhandar 100% Water Soluble NPK 19:19:19 Fertilizer',
        description: 'Complete balanced nutrition for foliar spray and drip irrigation in all crops.',
        category: 'Fertilizers & Nutrients',
        subCategory: 'NPK 19:19:19',
        brand: 'Krishi Bhandar',
        price: 210.0,
        mrp: 290.0,
        stock: 450,
        inStock: true,
        images: [
          'https://storage.googleapis.com/bhandar-product-images/banners/category/fertilizers_full.webp',
        ],
      ),
    ];
  }

  static List<BannerModel> getBanners() {
    return [
      BannerModel(
        id: 'ban_1',
        title: 'Kisan Special Season Sale - Up to 40% Off',
        subtitle: 'Genuine Agri Inputs Delivered Straight To Your Village',
        imageUrl: 'https://storage.googleapis.com/bhandar-product-images/banners/category/fertilizers_full.webp',
        type: BannerType.hero,
        priority: 1,
        isActive: true,
      ),
      BannerModel(
        id: 'ban_2',
        title: 'Special Disease Prevention Strip',
        subtitle: 'Protect your Kharif & Rabi harvest with top fungicides',
        imageUrl: 'https://storage.googleapis.com/bhandar-product-images/banners/strip/fungicides_full.webp',
        type: BannerType.strip,
        categorySlug: 'fungicides',
        priority: 2,
        isActive: true,
      ),
      BannerModel(
        id: 'ban_3',
        title: 'Herbicides & Weed Cleansing Promo',
        subtitle: 'Clean fields, Maximum Yield',
        imageUrl: 'https://storage.googleapis.com/bhandar-product-images/banners/strip/herbicides_full.webp',
        type: BannerType.strip,
        categorySlug: 'herbicides',
        priority: 3,
        isActive: true,
      ),
    ];
  }

  static List<CouponModel> getCoupons() {
    return [
      CouponModel(
        id: 'cp_1',
        code: 'BHANDAR10',
        title: 'First Order 10% Discount',
        description: 'Flat 10% instant discount for new farmer registrations',
        discountType: DiscountType.percentage,
        discountValue: 10,
        minOrderAmount: 999,
        maxDiscountAmount: 300,
        usageLimit: 500,
        usedCount: 243,
        isActive: true,
      ),
      CouponModel(
        id: 'cp_2',
        code: 'KISAN500',
        title: 'Bulk Order Mega Saver',
        description: 'Flat ₹500 off on fertilizer orders above ₹5,000',
        discountType: DiscountType.flatAmount,
        discountValue: 500,
        minOrderAmount: 5000,
        maxDiscountAmount: 500,
        usageLimit: 100,
        usedCount: 68,
        isActive: true,
      ),
      CouponModel(
        id: 'cp_3',
        code: 'FREESHIP',
        title: 'Free Express Village Delivery',
        description: 'Zero shipping charge on all pesticide combinations',
        discountType: DiscountType.flatAmount,
        discountValue: 99,
        minOrderAmount: 1499,
        maxDiscountAmount: 99,
        usageLimit: 1000,
        usedCount: 820,
        isActive: true,
      ),
    ];
  }

  static List<OrderModel> getOrders() {
    final now = DateTime.now();
    return [
      OrderModel(
        id: 'ord_1',
        orderNumber: '#KB-98214',
        customerName: 'Ramesh Patil',
        customerPhone: '+91 98220 14589',
        customerEmail: 'ramesh.patil@example.com',
        shippingAddress: 'Gat No. 44, Post Rahuri, Tal. Rahuri, Ahmednagar, MH - 413705',
        subtotal: 2340.0,
        discount: 234.0,
        deliveryCharge: 0.0,
        totalAmount: 2106.0,
        paymentMethod: 'Razorpay UPI',
        paymentStatus: 'Paid',
        status: OrderStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 3)),
        items: [
          OrderItem(
            productId: 'prod_1',
            title: 'Bhandar Super Chlorpyrifos 50% + Cypermethrin',
            quantity: 2,
            unitPrice: 780.0,
            totalAmount: 1560.0,
          ),
          OrderItem(
            productId: 'prod_2',
            title: 'Bhandar Mancozeb 75% WP',
            quantity: 1,
            unitPrice: 780.0,
            totalAmount: 780.0,
          ),
        ],
      ),
      OrderModel(
        id: 'ord_2',
        orderNumber: '#KB-98215',
        customerName: 'Suresh Shinde',
        customerPhone: '+91 94231 87654',
        shippingAddress: 'Plot 12, Krishi Bazar Road, Baramati, Pune, MH - 413102',
        subtotal: 4200.0,
        discount: 500.0,
        deliveryCharge: 0.0,
        totalAmount: 3700.0,
        paymentMethod: 'Cash on Delivery (COD)',
        paymentStatus: 'Pending',
        status: OrderStatus.processing,
        createdAt: now.subtract(const Duration(hours: 6)),
        items: [
          OrderItem(
            productId: 'prod_5',
            title: 'Bhandar NPK 19:19:19 Fertilizer (25kg pack)',
            quantity: 2,
            unitPrice: 2100.0,
            totalAmount: 4200.0,
          ),
        ],
      ),
      OrderModel(
        id: 'ord_3',
        orderNumber: '#KB-98216',
        customerName: 'Anil Deshmukh',
        customerPhone: '+91 99750 33412',
        shippingAddress: 'Near Primary School, Village Shegaon, Buldhana, MH - 444203',
        subtotal: 1499.0,
        discount: 100.0,
        deliveryCharge: 50.0,
        totalAmount: 1449.0,
        paymentMethod: 'Razorpay NetBanking',
        paymentStatus: 'Paid',
        status: OrderStatus.shipped,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        items: [
          OrderItem(
            productId: 'prod_3',
            title: 'Bhandar Humic Acid 98% Bio Stimulant',
            quantity: 3,
            unitPrice: 499.0,
            totalAmount: 1497.0,
          ),
        ],
      ),
      OrderModel(
        id: 'ord_4',
        orderNumber: '#KB-98217',
        customerName: 'Ganesh Jadhav',
        customerPhone: '+91 98812 65432',
        shippingAddress: 'House 88, At Post Loni, Sangamner, MH - 413736',
        subtotal: 3120.0,
        discount: 0.0,
        deliveryCharge: 0.0,
        totalAmount: 3120.0,
        paymentMethod: 'Razorpay UPI',
        paymentStatus: 'Paid',
        status: OrderStatus.delivered,
        createdAt: now.subtract(const Duration(days: 3)),
        deliveredAt: now.subtract(const Duration(days: 1)),
        items: [
          OrderItem(
            productId: 'prod_4',
            title: 'Bhandar Glyphosate 41% SL Non-Selective Herbicide',
            quantity: 6,
            unitPrice: 520.0,
            totalAmount: 3120.0,
          ),
        ],
      ),
    ];
  }

  static DashboardStats getDashboardStats() {
    return DashboardStats(
      totalProducts: 165,
      activeCategories: 5,
      totalOrders: 1420,
      totalRevenue: 384520.0,
      lowStockProducts: 4,
      activeCoupons: 3,
      averageOrderValue: 270.8,
      revenueTrend: [
        RevenueDataPoint(label: 'Mon', amount: 38400, orders: 142),
        RevenueDataPoint(label: 'Tue', amount: 45200, orders: 168),
        RevenueDataPoint(label: 'Wed', amount: 51800, orders: 195),
        RevenueDataPoint(label: 'Thu', amount: 49100, orders: 180),
        RevenueDataPoint(label: 'Fri', amount: 62400, orders: 230),
        RevenueDataPoint(label: 'Sat', amount: 74200, orders: 285),
        RevenueDataPoint(label: 'Sun', amount: 63420, orders: 220),
      ],
    );
  }

  static List<CollectionModel> getCollections() {
    return [
      CollectionModel(
        id: 'col_featured',
        name: 'Featured Products',
        slug: 'featured-products',
        description: 'Handpicked top performing agricultural inputs and formulations',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/fungicides_full.webp',
        bannerTitle: 'Top Performing Crop Solutions',
        isActive: true,
        priority: 10,
        subCollections: [
          const SubCollectionModel(name: 'Top Sellers', slug: 'top-sellers', isActive: true),
          const SubCollectionModel(name: 'New Releases', slug: 'new-releases', isActive: true),
        ],
      ),
      CollectionModel(
        id: 'col_bogo',
        name: 'Buy 1 Get 1 Deals',
        slug: 'buy-1-get-1',
        description: 'Exclusive combo offers and double-pack discounts',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/insecticides_full.webp',
        bannerTitle: 'Double Value Farm Packs',
        isActive: true,
        priority: 9,
        subCollections: [
          const SubCollectionModel(name: 'Insecticide Combos', slug: 'insecticide-combos', isActive: true),
          const SubCollectionModel(name: 'Fungicide Combos', slug: 'fungicide-combos', isActive: true),
        ],
      ),
      CollectionModel(
        id: 'col_monsoon',
        name: 'Monsoon Special Care',
        slug: 'monsoon-special',
        description: 'Essential preventive sprays and fungal treatments for heavy rainfall season',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/herbicides_full.webp',
        bannerTitle: 'Kharif Crop Rain Defense',
        isActive: true,
        priority: 8,
        subCollections: [
          const SubCollectionModel(name: 'Rain-Fast Sprays', slug: 'rain-fast-sprays', isActive: true),
          const SubCollectionModel(name: 'Root Rot Blockers', slug: 'root-rot-blockers', isActive: true),
        ],
      ),
      CollectionModel(
        id: 'col_cotton',
        name: 'Cotton Special Protection',
        slug: 'cotton-special',
        description: 'Targeted bollworm, whitefly and sucking pest packages for cotton growers',
        bannerImage: 'https://storage.googleapis.com/bhandar-product-images/banners/category/pgrs_full.webp',
        bannerTitle: 'Complete Cotton Crop Shield',
        isActive: true,
        priority: 7,
        subCollections: [
          const SubCollectionModel(name: 'Pink Bollworm Defense', slug: 'pink-bollworm-defense', isActive: true),
          const SubCollectionModel(name: 'Square Dropping Preventers', slug: 'square-dropping-preventers', isActive: true),
        ],
      ),
    ];
  }
}
