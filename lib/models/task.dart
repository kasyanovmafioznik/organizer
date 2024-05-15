
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
final formatter = DateFormat('yyyy-MM-dd HH:mm');

class Task{// модель задачи
  Task({required this.title, required this.description, required this.date}) : id = Uuid().v4();

  final String id;
  String title;
  String description;
  DateTime date;
  bool isCompleted = false;

 String get formattedDate {
    return formatter.format(date);
  }

  factory Task.fromJson(Map<String, dynamic> json) {
  return Task(
    title: json['title'],
    description: json['description'],
    date: DateTime.parse(json['date']),
  );
}

Map<String, dynamic> toJson() {
  return {
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
  };
}
}