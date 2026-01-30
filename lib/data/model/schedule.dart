class Schedule {
  final String id;
  final String name;
  final dynamic parameters;
  final DateTime nextRunTime;
  final DateTime startDate;
  final String dayOfWeek;
  final String day;

  Schedule({
    required this.id,
    required this.name,
    required this.nextRunTime,
    this.parameters,
    required this.startDate,
    required this.dayOfWeek,
    required this.day,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as String,
      name: json['name'] as String,
      nextRunTime: DateTime.parse(json['next_run_time']).toLocal(),
      parameters: json['parameters'] as dynamic,
      startDate: DateTime.parse(json['start_date']).toLocal(),
      dayOfWeek: json['day_of_week'] as String,
      day: json['day'] as String,
    );
  }
}
