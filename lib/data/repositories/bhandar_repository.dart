import '../../services/bhandar_api_service.dart';
import '../models/user_model.dart';
import '../../models/category_model.dart';
import '../../models/collection_model.dart';
import '../../models/product_model.dart';
import '../../models/banner_model.dart';
import '../../models/coupon_model.dart';
import '../../models/order_model.dart';
import '../../models/dashboard_stats.dart';

class BhandarRepository {
  final BhandarApiService apiService;

  BhandarRepository({required this.apiService});

  Future<UserModel> login({required String identifier, required String password, bool rememberMe = true}) async {
    final user = await apiService.login(identifier: identifier, password: password, rememberMe: rememberMe);
    if (user.token != null) {
      apiService.setAuthToken(user.token);
    }
    return user;
  }

  void logout() {
    apiService.setAuthToken(null);
  }

  void setAuthToken(String? token) {
    apiService.setAuthToken(token);
  }

  Future<List<CategoryModel>> getCategories() => apiService.getCategories();
  Future<CategoryModel> addCategory(Map<String, dynamic> data) => apiService.createCategory(data);
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) => apiService.updateCategory(id, data);
  Future<void> deleteCategory(String id) => apiService.deleteCategory(id);

  Future<List<CollectionModel>> getCollections() => apiService.getCollections();
  Future<CollectionModel> addCollection(Map<String, dynamic> data) => apiService.createCollection(data);
  Future<CollectionModel> updateCollection(String id, Map<String, dynamic> data) => apiService.updateCollection(id, data);
  Future<void> deleteCollection(String id) => apiService.deleteCollection(id);

  Future<List<ProductModel>> getProducts({String? category, String? search}) =>
      apiService.getProducts(category: category, search: search);
  Future<ProductModel> addProduct(Map<String, dynamic> data) => apiService.createProduct(data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) => apiService.updateProduct(id, data);
  Future<void> deleteProduct(String id) => apiService.deleteProduct(id);

  Future<List<BannerModel>> getBanners() => apiService.getBanners();
  Future<BannerModel> addBanner(Map<String, dynamic> data) => apiService.createBanner(data);
  Future<BannerModel> updateBanner(String id, Map<String, dynamic> data) => apiService.updateBanner(id, data);
  Future<void> deleteBanner(String id) => apiService.deleteBanner(id);

  Future<List<CouponModel>> getCoupons() => apiService.getCoupons();
  Future<CouponModel> addCoupon(Map<String, dynamic> data) => apiService.createCoupon(data);
  Future<CouponModel> updateCoupon(String id, Map<String, dynamic> data) => apiService.updateCoupon(id, data);
  Future<void> deleteCoupon(String id) => apiService.deleteCoupon(id);

  Future<List<OrderModel>> getOrders() => apiService.getOrders();
  Future<OrderModel> updateOrderStatus(String id, String status) => apiService.updateOrderStatus(id, status);
  Future<DashboardStats> getDashboardStats() => apiService.getDashboardStats();
  Future<String> uploadImage({required List<int> bytes, required String filename, String folder = 'categories'}) =>
      apiService.uploadImage(bytes: bytes, filename: filename, folder: folder);
}

