import 'dart:ui';

class Behaviour {
  int? id;
  String? text;
  String? emoji;
  String? image;
  Color? moodGraphColor;

  Behaviour({this.id, this.text, this.image, this.emoji, this.moodGraphColor});

  factory Behaviour.fromJson(Map<dynamic, dynamic> json) {
    return Behaviour(
      id: json['id'],
      text: json['text'],
      emoji: json['emoji'],
      image: json['image'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'image': image,
      'emoji': emoji,
    };
  }
}
