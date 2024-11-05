import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/subscription_controller.dart';
import 'package:mood_maker_kp/src/helpers/helpers.dart';
import 'package:mood_maker_kp/src/models/models.dart';
import 'package:provider/provider.dart';

import '../Repository/local_repository.dart';

enum BehaviourScreen { mood, activity, emotion }

class BehaviourController extends ChangeNotifier {
  Behaviour? mood;
  Behaviour? activity;
  Behaviour? emotion;

  setMood(Behaviour? behaviour) {
    mood = behaviour;
    notifyListeners();
  }

  setActivity(Behaviour? behaviour) {
    activity = behaviour;
    notifyListeners();
  }

  setEmotion(Behaviour? behaviour) {
    emotion = behaviour;
    notifyListeners();
  }

  Future<void> saveBehaviour(context) async {
    try {
      SubscriptionController subscriptionController =
      Provider.of<SubscriptionController>(context, listen: false);

      BehaviourHistory br = BehaviourHistory(
        mood: mood!,
        activity: activity!,
        emotion: emotion!,
        timestamp: DateTime
            .now()
            .millisecondsSinceEpoch,
        year: DateTime
            .now()
            .year,
        month: DateTime
            .now()
            .month,
        day: DateTime
            .now()
            .day,
      );


      int res = await DatabaseHelper().insertBehaviourHistory(br);
      debugLog("br: ${br.mood.text}");
      debugLog("res: $res");

      notifyListeners();
    } catch (e) {
      debugLog(e);
    }
  }
}
