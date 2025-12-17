class SubscriptionPlan {
  final int id;
  final String name;
  final double price;
  final String description;
  final int durationDays;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.durationDays,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? 'Plan') as String,
      price: _toDouble(json['price']),
      description: (json['description'] ?? '') as String,
      durationDays: (json['duration_days'] ?? 30) as int,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}