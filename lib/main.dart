import 'package:crimity_map/app/ui/routes/pages.dart';
import 'package:crimity_map/app/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'app/ui/pages/home/home_page.dart';

void main() => runApp(MyApp());

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Crimity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      initialRoute: Routes.SPLASH,
      routes: appRoutes(),
    );
  }
}