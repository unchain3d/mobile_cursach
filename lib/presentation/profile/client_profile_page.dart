import 'package:flutter/material.dart';
import 'package:mobile_cursach/data/repositories/client_repository.dart';
import 'package:mobile_cursach/data/services/local_storage.dart';
import 'package:mobile_cursach/navigation/app_routes.dart';
import 'package:mobile_cursach/core/app_colors.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final ClientRepository _repo = ClientRepository();

  bool _isLoading = true;
  String _username = "Користувач";
  Map<String, dynamic>? _activeSubscription;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _repo.getProfile();
      debugPrint("Отримані дані профілю: $data");

      if (!mounted) return;

      setState(() {
        _username = data['username'] ?? 'User';

        if (data['subscription_active'] == true) {
          _activeSubscription = {
            'plan_name': _mapPlanName(data['subscription_type']),
            'end_date': data['subscription_expires_at'],
          };
        } else {
          _activeSubscription = null;
        }

        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapPlanName(String? type) {
    switch (type) {
      case 'single':
        return 'Разове тренування';
      case 'month_classic':
        return 'Місяць Classic';
      case 'year_gold':
        return 'Рік Gold';
      default:
        return 'Абонемент';
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
  }

  Future<void> _logout() async {
    await LocalStorage.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 40),

            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.surface,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Привіт,",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Text(
                      _username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "Мій абонемент",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (_activeSubscription != null)
              _buildActiveSubCard()
            else
              _buildNoSubCard(),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Вийти з акаунту",
                  style: TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubCard() {
    final name = _activeSubscription!['plan_name'] ?? 'Абонемент';
    final rawDate = _activeSubscription!['end_date'];
    final endDate = rawDate != null ? _formatDate(rawDate) : '---';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFA8C83E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "АКТИВНИЙ",
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Діє до:",
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              Text(
                endDate,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNoSubCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: const [
          Icon(Icons.sentiment_dissatisfied, color: Colors.grey, size: 50),
          SizedBox(height: 16),
          Text(
            "Немає активного абонемента",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            "Перейдіть у магазин, щоб почати тренування!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
