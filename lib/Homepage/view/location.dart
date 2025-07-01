import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locationtracker/Homepage/bloc/locationbloc.dart';
import 'package:locationtracker/Homepage/view/mobile/location_mobileview.dart';
import 'package:locationtracker/Homepage/view/tab/location_Tabletview.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Location extends StatelessWidget {
  const Location({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocationBloc(),
      child: ResponsiveValue<Widget>(
        context,
        defaultValue: LocationMobileview(),
        conditionalValues: [
          Condition.equals(name: TABLET, value: LocationTabview()),
          Condition.smallerThan(name: MOBILE, value: LocationMobileview()),
        ],
      ).value,
    );
  }
}
