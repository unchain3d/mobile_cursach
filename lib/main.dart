import 'package:flutter/material.dart';
import 'package:mobile_cursach/navigation/app_routes.dart';
import 'package:mobile_cursach/navigation/route_generator.dart';
import 'package:mobile_cursach/data/services/local_storage.dart';

import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final rememberMe = await LocalStorage.getRememberMe();
  if (!rememberMe) {
    await LocalStorage.clear();
  }

  runApp(const SportLifeApp());
}

class SportLifeApp extends StatelessWidget {
  const SportLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SportLife',
      theme: appTheme,
      initialRoute: AppRoutes.login,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}