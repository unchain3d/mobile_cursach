import 'package:flutter/material.dart';
import 'package:mobile_cursach/data/models/trainer.dart';
import 'package:mobile_cursach/navigation/app_routes.dart';
import 'package:mobile_cursach/presentation/auth/login_page.dart';
import 'package:mobile_cursach/presentation/auth/register_page.dart';
import 'package:mobile_cursach/presentation/home/client_home_page.dart';
import 'package:mobile_cursach/presentation/home/subscriptions_page.dart';
import 'package:mobile_cursach/presentation/home/trainer_details_page.dart';
import 'package:mobile_cursach/presentation/profile/client_profile_page.dart';
import 'package:mobile_cursach/presentation/admin/admin_home_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case AppRoutes.clientHome:
        return MaterialPageRoute(builder: (_) => const ClientHomePage());

      case AppRoutes.adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());

      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ClientProfilePage());

      case AppRoutes.subscriptions:
        return MaterialPageRoute(builder: (_) => const SubscriptionsPage());

      case AppRoutes.trainerDetails:
        if (settings.arguments is Trainer) {
          return MaterialPageRoute(
            builder: (_) =>
                TrainerDetailsPage(trainer: settings.arguments as Trainer),
          );
        }
        return _errorRoute();

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Route not found')),
      ),
    );
  }
}
