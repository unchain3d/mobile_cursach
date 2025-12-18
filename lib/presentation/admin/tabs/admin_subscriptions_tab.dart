import 'package:flutter/material.dart';
import 'package:mobile_cursach/core/app_colors.dart';
import 'package:mobile_cursach/data/repositories/admin_repository.dart';
import '../widgets/admin_text_field.dart';

class AdminSubscriptionsTab extends StatefulWidget {
  const AdminSubscriptionsTab({super.key});

  @override
  State<AdminSubscriptionsTab> createState() => _AdminSubscriptionsTabState();
}

class _AdminSubscriptionsTabState extends State<AdminSubscriptionsTab> {
  final _repo = AdminRepository();
  bool _loading = true;
  List<Map<String, dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.getSubscriptions();
      if (mounted) setState(() => _subs = data);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Не вдалося завантажити тарифи'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    try {
      await _repo.deleteSubscription(id);
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Не вдалося видалити тариф'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _openForm({Map<String, dynamic>? item}) async {
    final name = TextEditingController(text: item?['name']?.toString() ?? '');
    final type = TextEditingController(text: item?['subscription_type']?.toString() ?? '');
    final price = TextEditingController(text: item?['price']?.toString() ?? '0');
    final duration = TextEditingController(text: item?['duration_days']?.toString() ?? '30');
    final visitsLimit = TextEditingController(text: item?['visits_limit']?.toString() ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Додати тариф' : 'Редагувати тариф'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              buildAdminTextField('Назва', name),
              buildAdminTextField('Тип (single/month_classic/year_gold)', type),
              buildAdminTextField('Ціна', price, keyboardType: TextInputType.number),
              buildAdminTextField('Тривалість днів', duration, keyboardType: TextInputType.number),
              buildAdminTextField('Ліміт візитів (опційно)', visitsLimit, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Скасувати')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );

    if (result != true) return;

    final payload = {
      'name': name.text.trim(),
      'subscription_type': type.text.trim(),
      'price': double.tryParse(price.text) ?? 0,
      'duration_days': int.tryParse(duration.text) ?? 0,
      if (visitsLimit.text.trim().isNotEmpty)
        'visits_limit': int.tryParse(visitsLimit.text) ?? 0,
    };

    try {
      if (item == null) {
        await _repo.createSubscription(payload);
      } else {
        await _repo.updateSubscription(item['id'] as int, payload);
      }
      await _load();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Не вдалося зберегти тариф'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Тарифи'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _openForm)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: _subs.length,
          itemBuilder: (_, i) {
            final s = _subs[i];
            return Card(
              color: AppColors.surface,
              child: ListTile(
                title: Text(s['name']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${s['subscription_type'] ?? ''} • ${s['price'] ?? 0} грн • ${s['duration_days'] ?? 0} днів',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () => _openForm(item: s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _delete(s['id'] as int),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}