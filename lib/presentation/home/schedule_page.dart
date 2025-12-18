import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_cursach/core/app_colors.dart';
import 'package:mobile_cursach/data/repositories/client_repository.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ClientRepository _clientRepo = ClientRepository();
  
  List<dynamic> _activeSessions = [];
  List<dynamic> _visitHistory = [];
  bool _isLoading = true;
  Set<int> _completingSessions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _clientRepo.getMySessions(),
        _clientRepo.getProfile(),
      ]);

      if (mounted) {
        setState(() {
          _activeSessions = results[0] as List<dynamic>;
          final profile = results[1] as Map<String, dynamic>;
          _visitHistory = profile['visit_history'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка завантаження даних: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeSession(int sessionId) async {
    if (_completingSessions.contains(sessionId)) return;

    setState(() => _completingSessions.add(sessionId));

    try {
      await _clientRepo.completeSession(sessionId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сесію успішно завершено!'),
            backgroundColor: AppColors.primary,
          ),
        );
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Помилка завершення сесії';
        if (e.toString().contains('400')) {
          errorMessage = 'Сесія вже завершена';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Сесію не знайдено';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Недостатньо прав';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _completingSessions.remove(sessionId));
      }
    }
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '---';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  bool _isSessionUpcoming(Map<String, dynamic> session) {
    try {
      final dateTimeStr = session['session_time']?.toString() ?? session['date']?.toString();
      if (dateTimeStr == null) return false;
      final dateTime = DateTime.parse(dateTimeStr);
      return dateTime.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  bool _isSessionPast(Map<String, dynamic> session) {
    try {
      final dateTimeStr = session['session_time']?.toString() ?? session['date']?.toString();
      if (dateTimeStr == null) return false;
      final dateTime = DateTime.parse(dateTimeStr);
      return dateTime.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              title: const Text(
                'Мій розклад',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : _activeSessions.isEmpty && _visitHistory.isEmpty
                        ? _buildEmptyState()
                        : _buildSessionsList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 20),
          Text(
            'Немає запланованих сесій',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Запишіться на тренування, щоб вони з\'явились тут',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    final upcomingSessions = _activeSessions
        .where((s) => s is Map && _isSessionUpcoming(s as Map<String, dynamic>))
        .toList();
    final pastSessions = _activeSessions
        .where((s) => s is Map && _isSessionPast(s as Map<String, dynamic>))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pastSessions.isNotEmpty) ...[
          _buildSectionHeader('Можна завершити'),
          const SizedBox(height: 12),
          ...pastSessions.map((s) => _buildSessionCard(s as Map<String, dynamic>, canComplete: true)),
          const SizedBox(height: 24),
        ],
        if (upcomingSessions.isNotEmpty) ...[
          _buildSectionHeader('Майбутні сесії'),
          const SizedBox(height: 12),
          ...upcomingSessions.map((s) => _buildSessionCard(s as Map<String, dynamic>, canComplete: false)),
          const SizedBox(height: 24),
        ],
        if (_visitHistory.isNotEmpty) ...[
          _buildSectionHeader('Історія відвідувань'),
          const SizedBox(height: 12),
          ..._visitHistory.map((visit) => _buildVisitCard(visit as Map<String, dynamic>)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, {required bool canComplete}) {
    final sessionId = session['id'] as int?;
    final dateTimeStr = session['session_time']?.toString() ?? session['date']?.toString();
    final trainerName = session['trainer_name']?.toString() ?? 'Тренер';
    final status = session['status']?.toString() ?? '';
    final isCompleted = status.toLowerCase() == 'completed';
    final isCompleting = sessionId != null && _completingSessions.contains(sessionId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.grey[800]! : AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(dateTimeStr),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Завершено',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (canComplete && !isCompleted && sessionId != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCompleting ? null : () => _completeSession(sessionId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isCompleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Завершити сесію',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    final visitDateStr = visit['visit_date']?.toString();
    final trainerName = visit['trainer_name']?.toString() ?? 'Тренер';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(visitDateStr),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Завершено',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
