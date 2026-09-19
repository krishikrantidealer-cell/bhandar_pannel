import '../datasources/bhandar_remote_datasource.dart';
import '../models/user_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/banner_model.dart';
import '../../models/coupon_model.dart';
import '../../models/order_model.dart';
import '../../models/dashboard_stats.dart';

class BhandarRepository {
  final BhandarRemoteDataSource remoteDataSource;

  BhandarRepository({required this.remoteDataSource});

  Future<UserModel> login({required String identifier, required String password}) async {
    final user = await remoteDataSource.login(identifier: identifier, password: password);
    if (user.token != null) {
      remoteDataSource.setAuthToken(user.token);
    }
    return user;
  }

  void logout() {
    remoteDataSource.setAuthToken(null);
  }

  void setAuthToken(String? token) {
    remoteDataSource.setAuthToken(token);
  }

  Future<List<CategoryModel>> getCategories() => remoteDataSource.fetchCategories();
  Future<CategoryModel> addCategory(Map<String, dynamic> data) => remoteDataSource.createCategory(data);
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data) => remoteDataSource.updateCategory(id, data);
  Future<void> deleteCategory(String id) => remoteDataSource.deleteCategory(id);

  Future<List<ProductModel>> getProducts({String? category, String? search}) =>
      remoteDataSource.fetchProducts(category: category, search: search);
  Future<ProductModel> addProduct(Map<String, dynamic> data) => remoteDataSource.createProduct(data);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> data) => remoteDataSource.updateProduct(id, data);
  Future<void> deleteProduct(String id) => remoteDataSource.deleteProduct(id);

  Future<List<BannerModel>> getBanners() => remoteDataSource.fetchBanners();
  Future<List<CouponModel>> getCoupons() => remoteDataSource.fetchCoupons();
  Future<List<OrderModel>> getOrders() => remoteDataSource.fetchOrders();
  Future<DashboardStats> getDashboardStats() => remoteDataSource.fetchDashboardStats();
}
