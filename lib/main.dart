import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/bhandar_repository.dart';
import 'services/bhandar_api_service.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/theme/theme_bloc.dart';
import 'logic/theme/theme_state.dart';
import 'logic/products/product_bloc.dart';
import 'logic/categories/category_bloc.dart';
import 'logic/collections/collection_bloc.dart';
import 'logic/orders/order_bloc.dart';
import 'logic/banners/banner_bloc.dart';
import 'logic/coupons/coupon_bloc.dart';
import 'logic/dashboard/dashboard_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final apiClient = ApiClient(baseUrl: AppConfig.defaultApiBaseUrl);
  final apiService = BhandarApiService(apiClient: apiClient);
  final repository = BhandarRepository(apiService: apiService);

  final authBloc = AuthBloc(repository: repository, prefs: prefs);
  final themeBloc = ThemeBloc(prefs: prefs);
  final router = AppRouter.createRouter(authBloc);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BhandarRepository>.value(value: repository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeBloc>.value(value: themeBloc),
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
}

class BhandarAdminApp extends StatelessWidget {
  final GoRouter router;

  const BhandarAdminApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final lightTheme = AppTheme.createTheme(
          palette: themeState.currentPalette,
          isDark: false,
          fontFamily: themeState.fontFamily,
          borderRadius: themeState.borderRadius,
          density: themeState.density,
        );
        final darkTheme = AppTheme.createTheme(
          palette: themeState.currentPalette,
          isDark: true,
          fontFamily: themeState.fontFamily,
          borderRadius: themeState.borderRadius,
          density: themeState.density,
        );

        return MaterialApp.router(
          title: themeState.brandName,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          themeMode: themeState.themeMode,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeAnimationDuration: const Duration(milliseconds: 350),
          themeAnimationCurve: Curves.easeInOutCubic,
        );
      },
    );
  }
}
