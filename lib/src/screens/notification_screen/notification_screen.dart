import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/helpers/app_colors.dart';
import 'package:mood_maker_kp/src/helpers/app_extensions.dart';
import 'package:mood_maker_kp/src/screens/notification_screen/components/notification_switch.dart';

import 'components/input_notification_details.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.95,
        initialChildSize: 0.8,
        builder: (context, scrollController) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / 1.03,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  30.spaceY,
                  NotificationSwitch(),
                  20.spaceY,
                  InputNotificationDetails()
                ],
              ),
            ),
          );
        });
  }
}
