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
              pageBuilder: (context, state) {
                final tabStr = state.uri.queryParameters['tab'];
                final tabIndex = int.tryParse(tabStr ?? '') ?? 0;
                return NoTransitionPage(
                  child: ProductsView(
                    key: ValueKey('products_tab_$tabIndex'),
                    initialTabIndex: tabIndex,
                  ),
                );
              },
            ),
            GoRoute(
              path: RoutePaths.categories,
              redirect: (context, state) => '${RoutePaths.products}?tab=1',
            ),
            GoRoute(
              path: '/collections',
              redirect: (context, state) => '${RoutePaths.products}?tab=2',
            ),
            GoRoute(
              path: RoutePaths.banners,
              redirect: (context, state) => '${RoutePaths.products}?tab=3',
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
          ],
        ),
      ],
    );
  }
}
