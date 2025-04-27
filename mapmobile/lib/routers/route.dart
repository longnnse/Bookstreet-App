import 'package:go_router/go_router.dart';
import 'package:mapmobile/pages/KiosPicking/kiospicking.dart';
import 'package:mapmobile/pages/Map/fullmap.dart';
import 'package:mapmobile/pages/MapPicking/mapPicking.dart';
import 'package:mapmobile/pages/ProductDetail/bookdetail.dart';
import 'package:mapmobile/pages/ProductDetail/productdetail.dart';
import 'package:mapmobile/pages/ProductDetail/souvernirdetail.dart';
import 'package:mapmobile/pages/Welcome/Welcome.dart';
import 'package:mapmobile/pages/souvenir/souvenir_widget.dart';

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/product/:id',
      builder: (context, state) =>
          ProductDetail(pid: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/book/:id',
      builder: (context, state) => BookDetail(pid: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/souvernir/:id',
      builder: (context, state) =>
          SouvernirDetail(pid: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/souvenir',
      builder: (context, state) => const Souvenir(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const FullMap(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const Welcome(),
    ),
    GoRoute(
      path: '/kiosPicking',
      builder: (context, state) => const KiosPicking(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MapPicking(),
    ),
  ],
);
