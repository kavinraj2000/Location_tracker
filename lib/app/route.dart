import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locationtracker/Homepage/Location_tracker.dart';
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
      // GoRoute(
      //   name: RouteNames.workoutList,
      //   path: '/workout_list',
      //   builder: (BuildContext context, GoRouterState state) {
      //     final Map<String, dynamic>? data = state.extra as Map<String, dynamic>?;
      //     RouteHistory.push({'/workout_list': data});
      //     return WorkoutListPage(data: data ?? {});
      //   },
      // ),
      // GoRoute(
      //   name: RouteNames.workoutDetail,
      //   path: '/workout_detail',
      //   builder: (BuildContext context, GoRouterState state) {
      //     final Map<String, dynamic>? data = state.extra as Map<String, dynamic>?;
      //     RouteHistory.push({'/workout_detail': data});
      //     return WorkoutDetailPage(data: data ?? {});
      //   },
      // ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      return state.matchedLocation;
    },
    debugLogDiagnostics: true,
  );
}
