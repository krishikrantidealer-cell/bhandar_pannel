import '../core/network/api_client.dart';
import '../data/models/user_model.dart';
import '../models/category_model.dart';
import '../models/collection_model.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/coupon_model.dart';
import '../models/order_model.dart';
import '../models/dashboard_stats.dart';
import 'mock_data_service.dart';

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

  // Authentication
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

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.get('/api/categories');
      if (response is List) {
        return response
            .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map) {
        if (response['categories'] is List) {
          return (response['categories'] as List)
              .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return MockDataService.getCategories();
    } catch (_) {
      return MockDataService.getCategories();
    }
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/categories', body: data);
      if (response is Map) {
        final resData = response['category'] ?? response['data'] ?? response;
        return CategoryModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return CategoryModel.fromJson(data);
  }

  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/categories/$id', body: data);
      if (response is Map) {
        final resData = response['category'] ?? response['data'] ?? response;
        return CategoryModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return CategoryModel.fromJson(data);
  }

  Future<void> deleteCategory(String id) async {
    try {
      await apiClient.delete('/api/categories/$id');
    } catch (_) {}
  }

  // Collections
  Future<List<CollectionModel>> getCollections() async {
    try {
      final response = await apiClient.get('/api/collections');
      if (response is List) {
        return response
            .map((item) => CollectionModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map) {
        if (response['collections'] is List) {
          return (response['collections'] as List)
              .map((item) => CollectionModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => CollectionModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return MockDataService.getCollections();
    } catch (_) {
      return MockDataService.getCollections();
    }
  }

  Future<CollectionModel> createCollection(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/collections', body: data);
      if (response is Map) {
        final resData = response['collection'] ?? response['data'] ?? response;
        return CollectionModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return CollectionModel.fromJson(data);
  }

  Future<CollectionModel> updateCollection(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/collections/$id', body: data);
      if (response is Map) {
        final resData = response['collection'] ?? response['data'] ?? response;
        return CollectionModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return CollectionModel.fromJson(data);
  }

  Future<void> deleteCollection(String id) async {
    try {
      await apiClient.delete('/api/collections/$id');
    } catch (_) {}
  }

  // Products
  Future<List<ProductModel>> getProducts({String? category, String? search}) async {
    try {
      String endpoint = '/api/products';
      List<String> queryParams = [];
      if (category != null && category.isNotEmpty) queryParams.add('category=$category');
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');
      if (queryParams.isNotEmpty) endpoint += '?${queryParams.join('&')}';

      final response = await apiClient.get(endpoint);
      if (response is List) {
        return response
            .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map) {
        if (response['products'] is List) {
          return (response['products'] as List)
              .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return MockDataService.getProducts();
    } catch (_) {
      return MockDataService.getProducts();
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/products', body: data);
      if (response is Map) {
        final resData = response['product'] ?? response['data'] ?? response;
        return ProductModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/products/$id', body: data);
      if (response is Map) {
        final resData = response['product'] ?? response['data'] ?? response;
        return ProductModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return ProductModel.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    try {
      await apiClient.delete('/api/products/$id');
    } catch (_) {}
  }

  // Banners
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await apiClient.get('/api/banners');
      if (response is List) {
        return response
            .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map) {
        if (response['banners'] is List) {
          return (response['banners'] as List)
              .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return MockDataService.getBanners();
    } catch (_) {
      return MockDataService.getBanners();
    }
  }

  Future<BannerModel> createBanner(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/banners', body: data);
      if (response is Map) {
        final resData = response['banner'] ?? response['data'] ?? response;
        return BannerModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return BannerModel.fromJson(data);
  }

  Future<BannerModel> updateBanner(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/banners/$id', body: data);
      if (response is Map) {
        final resData = response['banner'] ?? response['data'] ?? response;
        return BannerModel.fromJson(Map<String, dynamic>.from(resData));
      }
    } catch (_) {}
    return BannerModel.fromJson(data);
  }

  Future<void> deleteBanner(String id) async {
    try {
      await apiClient.delete('/api/banners/$id');
    } catch (_) {}
  }

  // Coupons
  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await apiClient.get('/api/coupons');
      if (response is List) {
        return response
            .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map) {
        if (response['coupons'] is List) {
          return (response['coupons'] as List)
              .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return MockDataService.getCoupons();
    } catch (_) {
      return MockDataService.getCoupons();
    }
  }

  // Orders
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await apiClient.get('/api/orders');
      if (response is List) {
        return response
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map) {
        if (response['orders'] is List) {
          return (response['orders'] as List)
              .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return MockDataService.getOrders();
    } catch (_) {
      return MockDataService.getOrders();
    }
  }

  // Dashboard Stats
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await apiClient.get('/api/dashboard/stats');
      if (response is Map) {
        final statData = response['data'] ?? response['stats'] ?? response;
        return DashboardStats.fromJson(Map<String, dynamic>.from(statData));
      }
    } catch (_) {}
    return MockDataService.getDashboardStats();
  }
}
