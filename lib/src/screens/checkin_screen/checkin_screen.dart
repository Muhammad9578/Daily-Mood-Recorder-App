import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/behaviour_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../helpers/helpers.dart';
import '../../helpers/notification_handler.dart';
import '../../widgets/widgets.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<SubscriptionController>(
                builder: (context, controller, child) {
                  return controller.isSubscribed
                      ? const SizedBox.shrink()
                      : InkWell(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.homeScreen,
                          arguments: {PrefsKeys.pageNumber: 2},
                              (route) => false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 30),
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColors.drawerColor)),
                      child: Text(
                        "Buy subscription to access premier features, i.e. sharing quotes, save your data on cloud to access it from any where at any time.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: Fonts.medium),
                      ),
                    ),
                  );
                }),
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SecondaryButton(
                        index: 2,
                        icon: MyImage.logo,
                        emoji: Emoji.logo,
                        // textAlign: TextAlign.center,
                        height: 35,
                        width: 35,
                        fontSize: 25,
                        // 24, 4040
                        onTap: () async {
                          getIt
                              .get<NotificationsHandler>()
                              .scheduleNewNotification(
                            title: "MeMood",
                            description:
                            "Long time no see, Open me and tell me how do you feel today.",
                            hours: 13,
                            minutes: 0,
                            repeats: true,
                          );
                          BehaviourController controller =
                          Provider.of<BehaviourController>(context,
                              listen: false);
                          controller.setEmotion(null);
                          controller.setActivity(null);
                          controller.setMood(null);

                          Navigator.pushNamed(context, Routes.moodScreen);
                        },
                        text: "Check In",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
