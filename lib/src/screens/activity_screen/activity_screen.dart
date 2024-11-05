import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/behaviour_controller.dart';
import '../../helpers/helpers.dart';
import '../../models/behaviours.dart';
import '../../widgets/behaviour_template.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Behaviour> activityList;
    String title;
    BehaviourController controller =
        Provider.of<BehaviourController>(context, listen: false);
    Behaviour mood = controller.mood!;
    if (mood.text == 'Excellent' || mood.text == 'Good') {
      activityList = happyMoodsActivities;
      title = "What makes you happy?";
    } else if (mood.text == 'Bad' || mood.text == 'Terrible') {
      activityList = downMoodActivities;
      title = "What gets you down?";
    } else {
      activityList = okMoodActivities;
      title = "What have you been doing?";
    }

    return BehaviourTemplate(
      title: title,
      behaviourList: activityList,
      behaviourScreen: BehaviourScreen.activity,
      key: key,
    );
  }
}
