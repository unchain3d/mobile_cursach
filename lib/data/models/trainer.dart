class Trainer {
  final int id;
  final String name;
  final String description;
  final String photoUrl;
  final double rating;
  final String specialization;
  final int experienceYears;

  Trainer({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.rating,
    required this.specialization,
    this.experienceYears = 3,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? 'Unknown Trainer') as String,
      description: (json['description'] ?? '') as String,
      photoUrl: (json['photo_url'] ?? '') as String,
      rating: _toDouble(json['rating']),
      specialization: (json['specialization'] ?? 'Fitness') as String,
      experienceYears: (json['experience'] ?? 3) as int,
    );
  }
}

class TimeSlot {
  final String time;
  final String datetime;
  final bool available;

  TimeSlot({
    required this.time,
    required this.datetime,
    required this.available,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: (json['time'] ?? '') as String,
      datetime: (json['datetime'] ?? '') as String,
      available: (json['available'] ?? false) as bool,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}