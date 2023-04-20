import 'package:crimity_map/app/ui/pages/home/home_page.dart';
import 'package:crimity_map/app/ui/pages/request_permission/request_permission_page.dart';
import 'package:crimity_map/app/ui/routes/routes.dart';
import 'package:crimity_map/app/ui/splash/splash_page.dart';
import 'package:flutter/cupertino.dart';

Map<String, Widget Function(BuildContext)> appRoutes() {
  return {
    Routes.SPLASH:(_) => const SplashPage(),
    Routes.PERMISSIONS:(_) => const RequestPermissionPage(),
    Routes.HOME:(_) => const HomePage(),
  };
}