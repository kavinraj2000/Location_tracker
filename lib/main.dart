import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locationtracker/Homepage/bloc/locationbloc.dart';
import 'package:locationtracker/app/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(create: (_) => LocationBloc(), child: const App()),
    );
  }
}
