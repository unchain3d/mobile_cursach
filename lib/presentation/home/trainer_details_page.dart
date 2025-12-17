import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cursach/data/models/trainer.dart';
import 'package:mobile_cursach/data/repositories/client_repository.dart';

import 'package:mobile_cursach/core/theme.dart';

class TrainerDetailsPage extends StatefulWidget {
  final Trainer trainer;

  const TrainerDetailsPage({required this.trainer, super.key});

  @override
  State<TrainerDetailsPage> createState() => _TrainerDetailsPageState();
}

class _TrainerDetailsPageState extends State<TrainerDetailsPage> {
  final ClientRepository _repo = ClientRepository();

  DateTime _selectedDate = DateTime.now();
  List<String> _availableSlots = [];
  String? _selectedSlot;
  bool _isLoadingSlots = false;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadSlots(_selectedDate);
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
      _selectedSlot = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final slots = await _repo.getTrainerSlots(widget.trainer.id, dateStr);

      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSlots = false;
          _availableSlots = ['10:00', '12:00', '14:30', '16:00', '18:30'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не вдалося завантажити розклад: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _bookSession() async {
    if (_selectedSlot == null) return;

    setState(() => _isBooking = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      await _repo.bookSession(
        trainerId: widget.trainer.id,
        date: dateStr,
        time: _selectedSlot!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Успішно записано!'), backgroundColor: AppColors.primary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      String message = 'Помилка бронювання: $e';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['detail'] != null && data['detail'].toString().isNotEmpty) {
          message = data['detail'].toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.trainer.photoUrl.isNotEmpty
                    ? widget.trainer.photoUrl
                    : 'https://picsum.photos/400/600?random=${widget.trainer.id}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.trainer.name,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.trainer.specialization,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Досвід: ${widget.trainer.experienceYears} років • Рейтинг: ${widget.trainer.rating}",
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  const Text("Опис", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    widget.trainer.description.isNotEmpty
                        ? widget.trainer.description
                        : "Досвідчений тренер, який допоможе вам досягти ваших цілей швидко та ефективно. Індивідуальний підхід до кожного клієнта.",
                    style: TextStyle(color: Colors.grey[400], height: 1.5),
                  ),

                  const SizedBox(height: 30),
                  const Text("Оберіть дату", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14,
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                            DateFormat('yyyy-MM-dd').format(_selectedDate);

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = date);
                            _loadSlots(date);
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected ? null : Border.all(color: Colors.grey[800]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('EEE').format(date),
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text("Вільний час", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  if (_isLoadingSlots)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else if (_availableSlots.isEmpty)
                    const Text("На цю дату немає вільних місць", style: TextStyle(color: Colors.grey))
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableSlots.map((slot) {
                        final isSelected = slot == _selectedSlot;
                        return ChoiceChip(
                          label: Text(slot),
                          selected: isSelected,
                          onSelected: (selected) => setState(() => _selectedSlot = selected ? slot : null),
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey[800]!),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.surface,
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: (_selectedSlot != null && !_isBooking) ? _bookSession : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[800],
                disabledForegroundColor: Colors.grey,
              ),
              child: _isBooking
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text("ЗАПИСАТИСЬ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}