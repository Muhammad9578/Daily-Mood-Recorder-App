import 'package:flutter/material.dart';

import '../../controllers/behaviour_controller.dart';
import '../../helpers/helpers.dart';
import '../../widgets/behaviour_template.dart';

class EmotionScreen extends StatelessWidget {
  const EmotionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BehaviourTemplate(
      title: "How did it make you feel? 😋 ",
      behaviourList: dummyEmotions,
      behaviourScreen: BehaviourScreen.emotion,
      key: key,
    );
  }
}
