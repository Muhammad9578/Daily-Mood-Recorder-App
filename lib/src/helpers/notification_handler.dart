import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers.dart';

class NotificationsHandler {
  Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        // 'null',
        null,
        [
          NotificationChannel(
              channelGroupKey: 'scheduled_channel_group',
              channelKey: 'scheduled_channel',
              channelName: 'Scheduled Notifications',
              channelDescription: 'Notifications scheduled for 9 PM',
              defaultColor: Color(0xFF9D50DD),
              ledColor: Colors.white)
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'scheduled_channel_group',
              channelGroupName: 'Scheduled group')
        ],
        debug: true);
  }

  // static Future<List<NotificationPermission>> requestUserPermissions(
  //     BuildContext context,
  //     {
  //     // if you only intends to request the permissions until app level, set the channelKey value to null
  //     required String? channelKey,
  //     required List<NotificationPermission> permissionList}) async {
  //   // Check if the basic permission was granted by the user
  //   if (!await requestBasicPermissionToSendNotifications(context)) return [];
  //
  //   // Check which of the permissions you need are allowed at this time
  //   List<NotificationPermission> permissionsAllowed =
  //       await AwesomeNotifications().checkPermissionList(
  //           channelKey: channelKey, permissions: permissionList);
  //
  //   // If all permissions are allowed, there is nothing to do
  //   if (permissionsAllowed.length == permissionList.length)
  //     return permissionsAllowed;
  //
  //   // Refresh the permission list with only the disallowed permissions
  //   List<NotificationPermission> permissionsNeeded =
  //       permissionList.toSet().difference(permissionsAllowed.toSet()).toList();
  //
  //   // Check if some of the permissions needed request user's intervention to be enabled
  //   List<NotificationPermission> lockedPermissions =
  //       await AwesomeNotifications().shouldShowRationaleToRequest(
  //           channelKey: channelKey, permissions: permissionsNeeded);
  //
  //   // If there is no permissions depending on user's intervention, so request it directly
  //   if (lockedPermissions.isEmpty) {
  //     // Request the permission through native resources.
  //     await AwesomeNotifications().requestPermissionToSendNotifications(
  //         channelKey: channelKey, permissions: permissionsNeeded);
  //
  //     // After the user come back, check if the permissions has successfully enabled
  //     permissionsAllowed = await AwesomeNotifications().checkPermissionList(
  //         channelKey: channelKey, permissions: permissionsNeeded);
  //   } else {
  //     // If you need to show a rationale to educate the user to conceived the permission, show it
  //     await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //               backgroundColor: Color(0xfffbfbfb),
  //               title: Text(
  //                 'Awesome Notifications needs your permission',
  //                 textAlign: TextAlign.center,
  //                 maxLines: 2,
  //                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
  //               ),
  //               content: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Image.asset(
  //                     'assets/images/animated-clock.gif',
  //                     height: MediaQuery.of(context).size.height * 0.3,
  //                     fit: BoxFit.fitWidth,
  //                   ),
  //                   Text(
  //                     'To proceed, you need to enable the permissions above' +
  //                         (channelKey?.isEmpty ?? true
  //                             ? ''
  //                             : ' on channel $channelKey') +
  //                         ':',
  //                     maxLines: 2,
  //                     textAlign: TextAlign.center,
  //                   ),
  //                   SizedBox(height: 5),
  //                   Text(
  //                     lockedPermissions
  //                         .join(', ')
  //                         .replaceAll('NotificationPermission.', ''),
  //                     maxLines: 2,
  //                     textAlign: TextAlign.center,
  //                     style:
  //                         TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  //                   ),
  //                 ],
  //               ),
  //               actions: [
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text(
  //                       'Deny',
  //                       style: TextStyle(color: Colors.red, fontSize: 18),
  //                     )),
  //                 TextButton(
  //                   onPressed: () async {
  //                     // Request the permission through native resources. Only one page redirection is done at this point.
  //                     await AwesomeNotifications()
  //                         .requestPermissionToSendNotifications(
  //                             channelKey: channelKey,
  //                             permissions: lockedPermissions);
  //
  //                     // After the user come back, check if the permissions has successfully enabled
  //                     permissionsAllowed = await AwesomeNotifications()
  //                         .checkPermissionList(
  //                             channelKey: channelKey,
  //                             permissions: lockedPermissions);
  //
  //                     Navigator.pop(context);
  //                   },
  //                   child: Text(
  //                     'Allow',
  //                     style: TextStyle(
  //                         color: Colors.deepPurple,
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold),
  //                   ),
  //                 ),
  //               ],
  //             ));
  //   }
  //
  //   // Return the updated list of allowed permissions
  //   return permissionsAllowed;
  // }

  Future<void> scheduleNewNotification(
      {required String title,
      required String description,
      required int hours,
      required int minutes,
      bool repeats = true}) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (isAllowed) {
      await getIt
          .get<SharedPreferences>()
          .setBool(PrefsKeys.showNotificationAgain, true);
    }

    debugLog("isAllowed1: $isAllowed");
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    debugLog("isAllowed2: $isAllowed");
    if (!isAllowed) return;
    debugLog("isAllowed3: $isAllowed");

    // await scheduleNewNotification(
    //     title: 'test',
    //     msg: 'test message',
    //     heroThumbUrl:
    //         'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
    //     hoursFromNow: 5,
    //     username: 'test user',
    //     repeatNotif: false);
    await scheduleDailyNotification(
      title: title,
      description: description,
      hours: hours,
      minutes: minutes,
      repeats: repeats,
    );
  }

  Future<void> scheduleDailyNotification(
      {String? title,
      String? description,
      int? hours,
      int? minutes,
      bool repeats = true}) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'scheduled_channel',
          title: '$title',
          body: '$description',
        ),
        schedule:
            // NotificationInterval(
            //   interval: 60, //1 minute
            //   repeats: true,
            //   timeZone: 'UTC',
            // ),
            NotificationCalendar(
          // timeZone: ,
          hour: hours,
          minute: minutes,
          second: 0,
          repeats: repeats,
        ),
      );
    } catch (e) {
      debugLog("Notification schedule error: $e");
    }
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    bool per = false;
    BuildContext context = mainNavigationKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Text('Notify Permission!',
                style: TextStyle(fontSize: 18, fontWeight: Fonts.medium)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        AppIcons.notification,
                        height: 70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Do you want MeMood to remind you for setting moods.',
                  style: TextStyle(
                      fontSize: 15, fontWeight: Fonts.light, wordSpacing: 1.2),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    await getIt
                        .get<SharedPreferences>()
                        .setBool(PrefsKeys.showNotificationAgain, false);
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    "Don't show again",
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                        fontWeight: Fonts.medium,
                        fontFamily: FontFamily.courgette),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.red,
                        fontWeight: Fonts.medium,
                        fontFamily: FontFamily.courgette),
                  )),
              TextButton(
                onPressed: () async {
                  userAuthorized = true;
                  //  log("notification per = $per");
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Allow',
                  style: TextStyle(
                      fontSize: 17,
                      color: AppColors.appColor,
                      fontWeight: Fonts.medium,
                      fontFamily: FontFamily.courgette),
                ),
              ),
            ],
          );
        });

    log("after btn press");
    // per =
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  stopNotification() async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  // Define the method to handle notification actions
  @pragma('vm:entry-point')
  static Future<void> onActionNotificationMethod(
      ReceivedAction receivedAction) async {
    // Handle the received action from the notification
    // Your implementation goes here
  }

  static ReceivePort? receivePort;
  Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // if (receivedAction.actionType == ActionType.SilentAction ||
    //     receivedAction.actionType == ActionType.SilentBackgroundAction) {
    //   // For background actions, you must hold the execution until the end
    //   print(
    //       'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
    //   // await executeLongTaskInBackground();
    // } else {
    //   // this process is only necessary when you need to redirect the user
    //   // to a new page or use a valid context, since parallel isolates do not
    //   // have valid context, so you need redirect the execution to main isolate
    //   // if (receivePort == null) {
    //   //   print(
    //   //       'onActionReceivedMethod was called inside a parallel dart isolate.');
    //   //   SendPort? sendPort =
    //   //       IsolateNameServer.lookupPortByName('notification_action_port');

    //   //   if (sendPort != null) {
    //   //     print('Redirecting the execution to main isolate process.');
    //   //     sendPort.send(receivedAction);
    //   //     return;
    //   //   }
    //   // }

    //   return onActionReceivedImplementationMethod(receivedAction);
    // }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
    //     '/notification-page',
    //     (route) =>
    //         (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }
}
