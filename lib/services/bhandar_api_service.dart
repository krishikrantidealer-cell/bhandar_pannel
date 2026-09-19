import '../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/banner_model.dart';
import '../models/coupon_model.dart';
import '../models/order_model.dart';
import '../models/dashboard_stats.dart';
import 'mock_data_service.dart';

class BhandarApiService {
  final ApiClient apiClient;

  BhandarApiService({required this.apiClient});

  void updateBaseUrl(String newUrl, {String? token}) {
    apiClient.baseUrl = newUrl;
    apiClient.authToken = token;
  }

  // Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.get('/api/categories');
      if (response is List) {
        return response
            .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map && response['categories'] is List) {
        return (response['categories'] as List)
            .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return MockDataService.getCategories();
    } catch (e) {
      return MockDataService.getCategories();
    }
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/categories', body: data);
      if (response is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (_) {}
    return CategoryModel.fromJson(data);
  }

  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/categories/$id', body: data);
      if (response is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (_) {}
    return CategoryModel.fromJson(data);
  }

  Future<void> deleteCategory(String id) async {
    try {
      await apiClient.delete('/api/categories/$id');
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
      } else if (response is Map && response['products'] is List) {
        return (response['products'] as List)
            .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return MockDataService.getProducts();
    } catch (e) {
      return MockDataService.getProducts();
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/products', body: data);
      if (response is Map) {
        return ProductModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (_) {}
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('/api/products/$id', body: data);
      if (response is Map) {
        return ProductModel.fromJson(Map<String, dynamic>.from(response));
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
      } else if (response is Map && response['banners'] is List) {
        return (response['banners'] as List)
            .map((item) => BannerModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return MockDataService.getBanners();
    } catch (e) {
      return MockDataService.getBanners();
    }
  }

  // Coupons
  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await apiClient.get('/api/coupons');
      if (response is List) {
        return response
            .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (response is Map && response['coupons'] is List) {
        return (response['coupons'] as List)
            .map((item) => CouponModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return MockDataService.getCoupons();
    } catch (e) {
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
      } else if (response is Map && response['orders'] is List) {
        return (response['orders'] as List)
            .map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return MockDataService.getOrders();
    } catch (e) {
      return MockDataService.getOrders();
    }
  }

  // Dashboard Stats
  Future<DashboardStats> getDashboardStats() async {
    return MockDataService.getDashboardStats();
  }
}
