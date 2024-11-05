import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> mainNavigationKey = GlobalKey<NavigatorState>();
final GlobalKey<RefreshIndicatorState> settingsRefreshIndicatorKey =
    GlobalKey<RefreshIndicatorState>();

class PrefsKeys {
  static const fromStart = "fromStart";
  static const pageNumber = "pageNumber";

  static const showNotification = "showNotification";
  static const notificationTitle = "notificationTitle";
  static const notificationDescription = "notificationDescription";
  static const notificationHours = "notificationHours";
  static const notificationMinutes = "notificationMinutes";
  static const showNotificationAgain = "showNotificationAgain";


}

class AppConstants {
  static const String notificationTitle = "MeMood";
  static const String notificationDescription =
      "Long time no see, Open me and tell me how do you feel today.";
  static const int notificationHours = 21;
  static const int notificationMinutes = 0;
  static const String supportEmail = "support@memood.app";
  static const String purchasingProductId = "monthly_s";

  

  // todo change this below id
  static const String playStoreAppId =
      "com.elemed.app"; //"com.accessibilityx.memood";
  static const int appStoreAppId = 6451230141; //6475170246;
}
