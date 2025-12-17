import 'package:flutter/material.dart';
import 'package:mobile_cursach/data/models/subscription_plan.dart';
import 'package:mobile_cursach/data/repositories/client_repository.dart';
import 'package:mobile_cursach/core/app_colors.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  final ClientRepository _repo = ClientRepository();
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = true;
  int? _buyingId;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      final plans = await _repo.getSubscriptions();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _buy(int id) async {
    setState(() => _buyingId = id);
    try {
      await _repo.buySubscription(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Абонемент придбано!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Помилка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _buyingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Text(
              "Магазин абонементів",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
                : _plans.isEmpty
                ? const Center(
              child: Text(
                "Немає доступних тарифів",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              itemCount: _plans.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildSubscriptionCard(_plans[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionPlan plan) {
    final isBuying = _buyingId == plan.id;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (plan.durationDays == 30)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "ХІТ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            plan.description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                "${plan.price.toStringAsFixed(0)} грн",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed:
                    isBuying ? null : () => _buy(plan.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isBuying
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Купити",
                      style:
                      TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
