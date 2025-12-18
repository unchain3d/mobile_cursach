import 'package:flutter/material.dart';
import 'package:mobile_cursach/core/app_colors.dart';
import 'package:mobile_cursach/data/repositories/admin_repository.dart';
import '../widgets/admin_text_field.dart';

class AdminTrainersTab extends StatefulWidget {
  const AdminTrainersTab({super.key});

  @override
  State<AdminTrainersTab> createState() => _AdminTrainersTabState();
}

class _AdminTrainersTabState extends State<AdminTrainersTab> {
  final _repo = AdminRepository();
  bool _loading = true;
  List<Map<String, dynamic>> _trainers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.getTrainers();
      if (mounted) setState(() => _trainers = data);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Не вдалося завантажити тренерів'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    try {
      await _repo.deleteTrainer(id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Не вдалося видалити'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _openForm({Map<String, dynamic>? item}) async {
    final name = TextEditingController(text: item?['name']?.toString() ?? '');
    final specialization = TextEditingController(text: item?['specialization']?.toString() ?? '');
    final photoUrl = TextEditingController(text: item?['photo_url']?.toString() ?? '');
    final rating = TextEditingController(text: item?['rating']?.toString() ?? '0');
    final description = TextEditingController(text: item?['description']?.toString() ?? '');
    final experience = TextEditingController(text: item?['experience_years']?.toString() ?? '0');
    final price = TextEditingController(text: item?['price_per_session']?.toString() ?? '0');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item == null ? 'Додати тренера' : 'Редагувати тренера',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildAdminTextField('Ім\'я', name),
                      const SizedBox(height: 12),
                      buildAdminTextField('Спеціалізація', specialization),
                      const SizedBox(height: 12),
                      buildAdminTextField('Photo URL', photoUrl),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: buildAdminTextField(
                                'Рейтинг',
                                rating,
                                keyboardType: TextInputType.number
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildAdminTextField(
                                'Стаж (роки)',
                                experience,
                                keyboardType: TextInputType.number
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      buildAdminTextField(
                          'Ціна за сесію',
                          price,
                          keyboardType: TextInputType.number
                      ),
                      const SizedBox(height: 12),
                      buildAdminTextField('Опис', description, maxLines: 3),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Скасувати',
                        style: TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Зберегти',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != true) return;

    final payload = {
      'name': name.text.trim(),
      'specialization': specialization.text.trim(),
      'photo_url': photoUrl.text.trim().isEmpty ? null : photoUrl.text.trim(),
      'rating': double.tryParse(rating.text) ?? 0,
      'description': description.text.trim().isEmpty ? null : description.text.trim(),
      'experience_years': int.tryParse(experience.text) ?? 0,
      'price_per_session': double.tryParse(price.text) ?? 0,
    };

    try {
      if (item == null) {
        await _repo.createTrainer(payload);
      } else {
        await _repo.updateTrainer(item['id'] as int, payload);
      }
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Не вдалося зберегти тренера'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Тренери'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          )
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
          itemCount: _trainers.length,
          itemBuilder: (_, i) {
            final t = _trainers[i];
            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                    t['name']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '${t['specialization'] ?? ''} • ⭐ ${t['rating'] ?? 0}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () => _openForm(item: t),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _delete(t['id'] as int),
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