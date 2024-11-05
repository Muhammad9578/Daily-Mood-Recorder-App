import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/helpers/notification_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/helpers.dart';

class NotificationSwitch extends StatefulWidget {
  const NotificationSwitch({super.key});

  @override
  State<NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<NotificationSwitch> {
  bool fingerprint = true;

  showNotification(bool show) async {
    SharedPreferences prefs = getIt.get<SharedPreferences>();
    if (show) {
      await getIt.get<NotificationsHandler>().scheduleNewNotification(
            title: prefs.getString(PrefsKeys.notificationTitle) ??
                AppConstants.notificationTitle,
            description: prefs.getString(PrefsKeys.notificationDescription) ??
                AppConstants.notificationDescription,
            hours: prefs.getInt(PrefsKeys.notificationHours) ??
                AppConstants.notificationHours,
            minutes: prefs.getInt(PrefsKeys.notificationMinutes) ??
                AppConstants.notificationMinutes,
            repeats: true,
          );
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

      await prefs.setBool(PrefsKeys.showNotificationAgain, isAllowed);
      fingerprint = isAllowed;
    } else {
      await prefs.setBool(PrefsKeys.showNotificationAgain, show);
      await getIt.get<NotificationsHandler>().stopNotification();
      fingerprint = show;
    }

    setState(() {});
  }

  getNotificationStatus() {
    SharedPreferences prefs = getIt.get<SharedPreferences>();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      fingerprint = isAllowed;
      if (prefs.getBool(PrefsKeys.showNotificationAgain) != null) {
        fingerprint = prefs.getBool(PrefsKeys.showNotificationAgain)!;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    getNotificationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(width: 1, color: Color(0xFF919191)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Show Notification',
            semanticsLabel: 'Show Notification',
            style: TextStyle(fontSize: 16, fontWeight: Fonts.semiBold),
          ),
          Semantics(
            label: fingerprint ? "Notification are on" : "Notification are off",
            child: Switch.adaptive(
              activeColor: AppColors.appColor,
              value: fingerprint,
              onChanged: (value) {
                showNotification(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
