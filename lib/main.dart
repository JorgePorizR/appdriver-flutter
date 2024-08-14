import 'package:appdriver/pages/form_driver_page.dart';
import 'package:appdriver/pages/home_page.dart';
import 'package:appdriver/pages/location_map.dart';
import 'package:appdriver/pages/login_page.dart';
import 'package:appdriver/pages/viajedetail_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      initialRoute: '/login',
      onGenerateRoute: (RouteSettings settings) {
        var arguments = settings.arguments;
        var routes = <String, WidgetBuilder>{
          '/': (context) => const MyHomePage(),
          '/viajedetail': (context) {
            if (arguments is int) {
              return ViajeDetailPage(viajeId: arguments);
            } else {
              return const ViajeDetailPage(viajeId: null);
            }
          },
          '/mapa': (context) => const LocationMap(),
          '/login': (context) => const LoginPage(),
          '/formdriver': (context) => const FormDriverPage(),
        };
        WidgetBuilder? builder = routes[settings.name];
        return MaterialPageRoute(builder: (ctx) => builder!(ctx));
      },
    );
  }
}
