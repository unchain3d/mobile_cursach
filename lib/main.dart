import 'package:mobile_cursach/core/theme.dart';
import 'package:mobile_cursach/data/repositories/restaurants_repository.dart';
import 'package:mobile_cursach/navigation/app_routes.dart';
import 'package:mobile_cursach/navigation/route_generator.dart';
import 'package:mobile_cursach/presentation/home/cubit/restaurants_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(

  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(initSettings);

  final bool? granted = await notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();

  debugPrint('Notification permission granted: $granted');

  runApp(const BlueBiteApp());
}

class BlueBiteApp extends StatelessWidget {
  const BlueBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              RestaurantsCubit(RestaurantsRepository())..loadRestaurants(),
        ),
      ],
      child: MaterialApp(
        title: 'BlueBite',
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
