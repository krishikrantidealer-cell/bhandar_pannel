import '../core/network/api_client.dart';
import '../data/models/user_model.dart';
import '../models/category_model.dart';
import '../models/collection_model.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/coupon_model.dart';
import '../models/order_model.dart';
import '../models/dashboard_stats.dart';

class BhandarApiService {
  final ApiClient apiClient;

  BhandarApiService({required this.apiClient});

  void setAuthToken(String? token) {
    apiClient.authToken = token;
  }

  void updateBaseUrl(String newUrl, {String? token}) {
    apiClient.baseUrl = newUrl;
    apiClient.authToken = token;
  }

  // ==========================================
  // Authentication
  // ==========================================
  Future<UserModel> login({required String identifier, required String password, bool rememberMe = true}) async {
    final response = await apiClient.post('/api/auth/login', body: {
      'phone': identifier,
      'email': identifier,
      'identifier': identifier,
      'password': password,
      'rememberMe': rememberMe,
    });

    if (response is Map) {
      if (response['error'] != null || response['success'] == false) {
        throw ApiException(response['message'] ?? response['error'] ?? 'Invalid credentials');
      }
      final userData = response['user'] ?? response['customer'] ?? response['data'] ?? response;
      final token = response['token'] ?? response['accessToken'] ?? 'jwt_admin_${DateTime.now().millisecondsSinceEpoch}';
      return UserModel.fromJson(Map<String, dynamic>.from(userData), token: token);
    }

    throw ApiException('Invalid server response format.');
  }

  // ==========================================
  // Categories
  // ==========================================
  Future<List<CategoryModel>> getCategories() async {
    final response = await apiClient.get('/api/categories');
    if (response is List) {
      return response
          .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (response is Map) {
      final list = response['categories'] ?? response['data'];
      if (list is List) {
        return list
            .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return [];
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final response = await apiClient.post('/api/categories', body: data);
    if (response is Map) {
      final resData = response['category'] ?? response['data'] ?? response;
      return CategoryModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to create category');
  }

  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/api/categories/$id', body: data);
    if (response is Map) {
      final resData = response['category'] ?? response['data'] ?? response;
      return CategoryModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to update category');
  }

  Future<void> deleteCategory(String id) async {
    await apiClient.delete('/api/categories/$id');
  }

  // ==========================================
  // Collections
  // ==========================================
  Future<List<CollectionModel>> getCollections() async {
    final response = await apiClient.get('/api/collections');
    if (response is List) {
      return response
          .map((item) => CollectionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (response is Map) {
      final list = response['collections'] ?? response['data'];
      if (list is List) {
        return list
            .map((item) => CollectionModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return [];
  }

  Future<CollectionModel> createCollection(Map<String, dynamic> data) async {
    final response = await apiClient.post('/api/collections', body: data);
    if (response is Map) {
      final resData = response['collection'] ?? response['data'] ?? response;
      return CollectionModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to create collection');
  }

  Future<CollectionModel> updateCollection(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/api/collections/$id', body: data);
    if (response is Map) {
      final resData = response['collection'] ?? response['data'] ?? response;
      return CollectionModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to update collection');
  }

  Future<void> deleteCollection(String id) async {
    await apiClient.delete('/api/collections/$id');
  }

  // ==========================================
  // Products
  // ==========================================
  Future<List<ProductModel>> getProducts({String? category, String? search}) async {
    String endpoint = '/api/products';
    List<String> queryParams = ['limit=500'];
    if (category != null && category.isNotEmpty) queryParams.add('category=${Uri.encodeComponent(category)}');
    if (search != null && search.isNotEmpty) queryParams.add('search=${Uri.encodeComponent(search)}');
    endpoint += '?${queryParams.join('&')}';

    final response = await apiClient.get(endpoint);
    if (response is List) {
      return response
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (response is Map) {
      final list = response['products'] ?? response['data'];
      if (list is List) {
        return list
            .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return [];
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    final response = await apiClient.post('/api/products', body: data);
    if (response is Map) {
      final resData = response['product'] ?? response['data'] ?? response;
      return ProductModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to create product');
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/api/products/$id', body: data);
    if (response is Map) {
      final resData = response['product'] ?? response['data'] ?? response;
      return ProductModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to update product');
  }

  Future<void> deleteProduct(String id) async {
    await apiClient.delete('/api/products/$id');
  }

  // ==========================================
  // Banners
  // ==========================================
  Future<List<BannerModel>> getBanners() async {
    final response = await apiClient.get('/api/banners');
    if (response is List) {
      return response
          .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (response is Map) {
      final list = response['banners'] ?? response['data'];
      if (list is List) {
        return list
            .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return [];
  }

  Future<BannerModel> createBanner(Map<String, dynamic> data) async {
    final response = await apiClient.post('/api/banners', body: data);
    if (response is Map) {
      final resData = response['banner'] ?? response['data'] ?? response;
      return BannerModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to create banner');
  }

  Future<BannerModel> updateBanner(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/api/banners/$id', body: data);
    if (response is Map) {
      final resData = response['banner'] ?? response['data'] ?? response;
      return BannerModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to update banner');
  }

  Future<void> deleteBanner(String id) async {
    await apiClient.delete('/api/banners/$id');
  }

  // ==========================================
  // Coupons
  // ==========================================
  Future<List<CouponModel>> getCoupons() async {
    final response = await apiClient.get('/api/coupons');
    if (response is List) {
      return response
          .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (response is Map) {
      final list = response['coupons'] ?? response['data'];
      if (list is List) {
        return list
            .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return [];
  }

  Future<CouponModel> createCoupon(Map<String, dynamic> data) async {
    final response = await apiClient.post('/api/coupons', body: data);
    if (response is Map) {
      final resData = response['coupon'] ?? response['data'] ?? response;
      return CouponModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to create coupon');
  }

  Future<CouponModel> updateCoupon(String id, Map<String, dynamic> data) async {
    final response = await apiClient.put('/api/coupons/$id', body: data);
    if (response is Map) {
      final resData = response['coupon'] ?? response['data'] ?? response;
      return CouponModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to update coupon');
  }

  Future<void> deleteCoupon(String id) async {
    await apiClient.delete('/api/coupons/$id');
  }

  // ==========================================
  // Orders
  // ==========================================
  Future<List<OrderModel>> getOrders() async {
    final response = await apiClient.get('/api/orders?limit=500');
    if (response is List) {
      return response
          .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (response is Map) {
      final list = response['orders'] ?? response['data'];
      if (list is List) {
        return list
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
    return [];
  }

  Future<OrderModel> updateOrderStatus(String id, String status) async {
    final response = await apiClient.put('/api/orders/$id', body: {'orderStatus': status});
    if (response is Map) {
      final resData = response['order'] ?? response['data'] ?? response;
      return OrderModel.fromJson(Map<String, dynamic>.from(resData));
    }
    throw ApiException('Failed to update order status');
  }

  // ==========================================
  // Dashboard Stats
  // ==========================================
  Future<DashboardStats> getDashboardStats() async {
    final response = await apiClient.get('/api/dashboard/stats');
    if (response is Map) {
      final statData = response['data'] ?? response['stats'] ?? response;
      return DashboardStats.fromJson(Map<String, dynamic>.from(statData));
    }
    throw ApiException('Failed to load dashboard statistics');
  }

  // ==========================================
  // Image Uploads (Google Cloud Storage Bucket)
  // ==========================================
  Future<String> uploadImage({
    required List<int> bytes,
    required String filename,
    String folder = 'categories',
  }) async {
    return apiClient.uploadImageBytes(
      bytes: bytes,
      filename: filename,
      folder: folder,
    );
  }
}


