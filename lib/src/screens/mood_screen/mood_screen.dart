import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/behaviour_controller.dart';
import '../../helpers/helpers.dart';
import '../../widgets/behaviour_template.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BehaviourTemplate(
      title: "How is it going ? 🧐 ",
      behaviourList: dummyMoods,
      behaviourScreen: BehaviourScreen.mood,
      key: key,
    );
  }
}
