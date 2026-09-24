import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhandar_pannel/main.dart';
import 'package:bhandar_pannel/core/config/app_config.dart';
import 'package:bhandar_pannel/core/network/api_client.dart';
import 'package:bhandar_pannel/core/routing/app_router.dart';
import 'package:bhandar_pannel/services/bhandar_api_service.dart';
import 'package:bhandar_pannel/data/repositories/bhandar_repository.dart';
import 'package:bhandar_pannel/data/models/user_model.dart';
import 'package:bhandar_pannel/logic/auth/auth_bloc.dart';
import 'package:bhandar_pannel/logic/auth/auth_state.dart';
import 'package:bhandar_pannel/logic/theme/theme_bloc.dart';
import 'package:bhandar_pannel/logic/products/product_bloc.dart';
import 'package:bhandar_pannel/logic/categories/category_bloc.dart';
import 'package:bhandar_pannel/logic/collections/collection_bloc.dart';
import 'package:bhandar_pannel/logic/orders/order_bloc.dart';
import 'package:bhandar_pannel/logic/banners/banner_bloc.dart';
import 'package:bhandar_pannel/logic/coupons/coupon_bloc.dart';
import 'package:bhandar_pannel/logic/dashboard/dashboard_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BhandarAdminApp Login & Admin Smoke Test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      AuthBloc.prefUserKey: '{"id":"admin_1","name":"Bhandar Admin","email":"admin@krishibhandar.in","phone":"+919876543210","userType":"admin"}',
      AuthBloc.prefTokenKey: 'mock_admin_jwt_token',
      AuthBloc.prefRememberMeKey: true,
    });

    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final apiClient = ApiClient(baseUrl: AppConfig.defaultApiBaseUrl);
    final apiService = BhandarApiService(apiClient: apiClient);
    final repository = BhandarRepository(apiService: apiService);

    final authBloc = AuthBloc(repository: repository);
    final router = AppRouter.createRouter(authBloc);

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BhandarRepository>.value(value: repository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
            BlocProvider<ProductBloc>(create: (_) => ProductBloc(repository: repository)),
            BlocProvider<CategoryBloc>(create: (_) => CategoryBloc(repository: repository)),
            BlocProvider<CollectionBloc>(create: (_) => CollectionBloc(repository: repository)),
            BlocProvider<OrderBloc>(create: (_) => OrderBloc(repository: repository)),
            BlocProvider<BannerBloc>(create: (_) => BannerBloc(repository: repository)),
            BlocProvider<CouponBloc>(create: (_) => CouponBloc(repository: repository)),
            BlocProvider<DashboardBloc>(create: (_) => DashboardBloc(repository: repository)),
          ],
          child: BhandarAdminApp(router: router),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    router.refresh();
    await tester.pump(const Duration(milliseconds: 300));

    expect(authBloc.state.status, AuthStatus.authenticated);
    expect(authBloc.state.currentUser?.isAdmin, isTrue);

    // Once authenticated, redirected to Products Catalog operations
    expect(find.text('Products'), findsWidgets);
    expect(find.textContaining('Krishi Bhandar'), findsWidgets);
  });

  test('UserModel userType validation test', () {
    const adminUser = UserModel(
      id: '1',
      name: 'Admin',
      phone: '123',
      userType: UserType.admin,
    );
    expect(adminUser.isAdmin, isTrue);

    const customerUser = UserModel(
      id: '2',
      name: 'Farmer',
      phone: '456',
      userType: UserType.customer,
    );
    expect(customerUser.isAdmin, isFalse);
  });
}
