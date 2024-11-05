import 'dart:convert';

import 'package:mood_maker_kp/src/models/behaviours.dart';

class BehaviourHistory {
  int? id;
  late Behaviour mood;
  late Behaviour activity;
  late Behaviour emotion;
  late int timestamp;
  late int year;
  late int month;
  late int day;

  BehaviourHistory(
      {this.id,
      required this.mood,
      required this.activity,
      required this.emotion,
      required this.timestamp,
      required this.year,
      required this.day,
      required this.month});

  // Convert a BehaviourHistory object into a JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': jsonEncode(mood.toJson()),
      'activity': jsonEncode(activity.toJson()),
      'emotion': jsonEncode(emotion.toJson()),
      'timestamp': timestamp,
      'day': day,
      'month': month,
      'year': year,
    };
  }

  // Create a BehaviourHistory object from a JSON format
  factory BehaviourHistory.fromJson(Map<String, dynamic> json) {
    return BehaviourHistory(
      // id: int.parse(json['id'].toString()),
      mood: Behaviour.fromJson(jsonDecode(json['mood'])),
      activity: Behaviour.fromJson(jsonDecode(json['activity'])),
      emotion: Behaviour.fromJson(jsonDecode(json['emotion'])),
      timestamp: json['timestamp'],
      day: json['day'],
      month: json['month'],
      year: json['year'],
    );
  }
}
