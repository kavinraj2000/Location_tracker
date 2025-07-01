import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locationtracker/Homepage/view/location.dart';
import 'package:locationtracker/app/route_name.dart';

class Routes {
  GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        name: RouteNames.home,
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return Location();
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      return state.matchedLocation;
    },
    debugLogDiagnostics: true,
  );
}
