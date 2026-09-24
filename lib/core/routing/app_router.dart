import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../models/product_model.dart';
import '../../presentation/widgets/app_shell.dart';
import '../../presentation/views/login_view.dart';
// import '../../presentation/views/dashboard_view.dart';
import '../../presentation/views/products_view.dart';
import '../../presentation/views/product_details_view.dart';
import '../../presentation/views/product_edit_view.dart';
// import '../../presentation/views/categories_view.dart';
// import '../../presentation/views/banners_view.dart';
// import '../../presentation/views/coupons_view.dart';
// import '../../presentation/views/orders_view.dart';
// import '../../presentation/views/customization_view.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: RoutePaths.login,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggingIn = state.matchedLocation == RoutePaths.login;

        final isAuthenticated = authState.isAuthenticated;

        if (!isAuthenticated && !isLoggingIn) {
          return RoutePaths.login;
        }

        if (isAuthenticated && (isLoggingIn || state.matchedLocation == RoutePaths.dashboard || state.matchedLocation == '/')) {
          return RoutePaths.products;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RoutePaths.login,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoginView(),
          ),
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return AppShell(
              currentPath: state.matchedLocation,
              child: child,
            );
          },
          routes: [
            // GoRoute(
            //   path: RoutePaths.dashboard,
            //   pageBuilder: (context, state) => const NoTransitionPage(
            //     child: DashboardView(),
            //   ),
            // ),
            GoRoute(
              path: RoutePaths.products,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProductsView(),
              ),
            ),
            GoRoute(
              path: RoutePaths.productNew,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProductEditView(),
              ),
            ),
            GoRoute(
              path: RoutePaths.productDetails,
              pageBuilder: (context, state) {
                final productId = state.pathParameters['id'] ?? '';
                final productExtra = state.extra as ProductModel?;
                return NoTransitionPage(
                  child: ProductDetailsView(
                    productId: productId,
                    initialProduct: productExtra,
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.productEdit,
              pageBuilder: (context, state) {
                final productId = state.pathParameters['id'] ?? '';
                final productExtra = state.extra as ProductModel?;
                return NoTransitionPage(
                  child: ProductEditView(
                    productId: productId,
                    initialProduct: productExtra,
                  ),
                );
              },
            ),
            // GoRoute(
            //   path: RoutePaths.categories,
            //   pageBuilder: (context, state) => const NoTransitionPage(
            //     child: CategoriesView(),
            //   ),
            // ),
            // GoRoute(
            //   path: RoutePaths.banners,
            //   pageBuilder: (context, state) => const NoTransitionPage(
            //     child: BannersView(),
            //   ),
            // ),
            // GoRoute(
            //   path: RoutePaths.coupons,
            //   pageBuilder: (context, state) => const NoTransitionPage(
            //     child: CouponsView(),
            //   ),
            // ),
            // GoRoute(
            //   path: RoutePaths.orders,
            //   pageBuilder: (context, state) => const NoTransitionPage(
            //     child: OrdersView(),
            //   ),
            // ),
            // GoRoute(
            //   path: RoutePaths.settings,
            //   pageBuilder: (context, state) => const NoTransitionPage(
            //     child: CustomizationView(),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}
