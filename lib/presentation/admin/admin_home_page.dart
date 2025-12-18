import 'package:flutter/material.dart';
import 'package:mobile_cursach/core/app_colors.dart';
import 'tabs/admin_trainers_tab.dart';
import 'tabs/admin_subscriptions_tab.dart';
import 'tabs/admin_reports_tab.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _index = 0;

  final _pages = const [
    AdminTrainersTab(),
    AdminSubscriptionsTab(),
    AdminReportsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Тренери',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions),
            label: 'Тарифи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Звіти',
          ),
        ],
      ),
    );
  }
}