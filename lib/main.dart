import 'package:flutter/material.dart';
import 'package:weatherapp/screens/HomeScreen.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
    MaterialApp(
      home: HomeScreen(),
      navigatorObservers: [routeObserver],  // Add this line to observe route changes
    ),
  );
}