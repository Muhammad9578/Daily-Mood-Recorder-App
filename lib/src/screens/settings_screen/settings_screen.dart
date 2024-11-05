import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/screens/in_app/in_app.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../controllers/trends_controller.dart';
import '../../helpers/helpers.dart';
import '../../repository/firestore_repository.dart';
import '../../widgets/widgets.dart';
import '../notification_screen/notification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController =
        Provider.of<AuthController>(context, listen: false);
    TrendController trendController =
        Provider.of<TrendController>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvoked: (val) {
        debugLog("pop value: $val");
        Navigator.pushReplacementNamed(context, Routes.homeScreen);
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text("Settings"),
        // ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Consumer<SubscriptionController>(
                        builder: (context, subscriptionController, child) {
                      return SecondaryButton(
                        text: "Trends",
                        icon: AppIcons.trend,
                        index: 0,
                        onTap: () {
                          if (subscriptionController.isSubscribed) {
                            Navigator.pushNamed(context, Routes.trendsScreen);
                          } else {
                            Dialogs.showSubscriptionDialog(context: context);
                          }
                        },
                      );
                    }),
                    SecondaryButton(
                      text: "Edit Profile",
                      icon: AppIcons.edit,
                      index: 1,
                      onTap: () {
                        Navigator.pushNamed(context, Routes.editProfileScreen);
                      },
                    ),
                    Consumer<SubscriptionController>(
                        builder: (context, controller, child) {
                      String? timer;
                      if (controller.isSubscribed == true) {
                        int timeStamp = controller.subscriptionTimestamp;
                        DateTime expiresOn = getNextDateAfter31Days(timeStamp);

                        int daysLeft = getDaysLeft(expiresOn);
                        timer = getExpirationMessage(expiresOn);
                        debugLog("days left: $daysLeft");
                      }
                      return SecondaryButton(
                        index: 2,
                        expireTime: timer,
                        text: controller.isSubscribed
                            ? "Subscribed"
                            : "Make Subscription",
                        icon: AppIcons.subscribe,
                        onTap: () {
                          // Navigator.push(context,
                          //     MaterialPageRoute(builder: (context) => inApp()));
                          if (controller.isSubscribed == false) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const inApp()));

                            // makeSubscription(
                            //     controller, context, trendController);
                          }
                        },
                      );
                    }),
                    SecondaryButton(
                      index: 3,
                      text: "Notifications",
                      icon: AppIcons.notification,
                      onTap: () {
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(40),
                            )),
                            context: context,
                            builder: (context) {
                              return const NotificationScreen();
                            },
                            isScrollControlled: true);
                      },
                    ),
                    SecondaryButton(
                      index: 4,
                      text: "Rate me",
                      icon: AppIcons.rate,
                      onTap: () async {
                        await Dialogs.showRatingDialog(
                            title: "Rate me",
                            description: "Enjoying the app? please rate me.",
                            context: context);

                        await getIt
                            .get<FireStoreRepository>()
                            .clearLaunchCount();
                      },
                    ),
                    SecondaryButton(
                      index: 5,
                      text: "Share app",
                      icon: AppIcons.share,
                      onTap: () async {
                        try {
                          Dialogs.showLoadingDialog(
                              context: context, title: "Generating image link");
                          final String assetImage;
                          final String appUrl;
                          if (Platform.isAndroid) {
                            appUrl =
                                'https://play.google.com/store/apps/details?id=${AppConstants.playStoreAppId}';
                            assetImage = MyImage.androidQrCode;
                          } else {
                            appUrl =
                                'https://apps.apple.com/us/app/memood/id${AppConstants.appStoreAppId}';
                            assetImage = MyImage.iosQrCode;
                          }

                          File filee = await getImageFileFromAssets(assetImage);
                          XFile xFile = XFile(filee.path);
                          Navigator.pop(context); // closing dialog
                          await Share.shareXFiles([xFile],
                              subject:
                                  "Download app by scanning QrCode or using below link \n$appUrl",
                              text:
                                  "Download app by scanning QrCode or using below link \n$appUrl");
                        } catch (e) {
                          debugLog("error in sharing: $e");
                          Toasty.error(
                              "There is some problem in sharing, please try again later. Or email us the problem.");
                        }
                      },
                    ),
                    SecondaryButton(
                      index: 4,
                      text: "Have Question?",
                      icon: AppIcons.customerService,
                      onTap: () async {
                        String subject = "MeMood Queries from user";
                        String url =
                            'mailto:${AppConstants.supportEmail}?subject=${Uri.encodeFull(subject)}&body=${""}';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                          );
                        } else {
                          if (!context.mounted) return;
                          Dialogs.showErrorDialog(
                              title: "Failed",
                              description:
                                  "Email app is not installed on this device. Kindle install it and try again.",
                              context: context);
                        }
                      },
                    ),
                    SecondaryButton(
                      index: 6,
                      text: "Logout",
                      icon: AppIcons.logout,
                      onTap: () async {
                        Scaffold.of(context).closeDrawer();
                        Dialogs.showLoadingDialog(
                            title: 'Logging out...', context: context);

                        await authController.handleSignOut();
                        if (!context.mounted) return;
                        Navigator.pop(context); // popping dialog
                        if (!context.mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                            context, Routes.loginScreen, (route) => false);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  headerButtonBuild(
      {required String text,
      required String icon,
      required Function()? onTap}) {
    return Row(
      children: [
        Image.asset(
          icon,
          height: 40,
          width: 40,
        ),
        TextButton(onPressed: onTap, child: Text(text)),
      ],
    );
  }

  makeSubscription(SubscriptionController controller, context,
      TrendController trendController) async {
    try {
      Dialogs.showLoadingDialog(title: "Subscribing...", context: context);
      bool makeSubscription = await controller.setIsSubscribed(
          true, DateTime.now().millisecondsSinceEpoch);
      if (makeSubscription) {
        // debugLog("Subscribed  now we will cache data from local db to firesto");
        // //   means subscribed, now we will cache data from local db to firestore
        // await trendController.saveBehaviourFromLocalToFirestore(context);
        Navigator.pop(context); // closing dialog
        Dialogs.showSaveDialog(
            title: "Successfully",
            description:
                "Successfully subscribed, Now you can enjoy all premier features.",
            context: context,
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushNamedAndRemoveUntil(
              //     context, Routes.homeScreen, (route) => false);
            });
        // Navigator.p(context, Routes.homeScreen);
      }
    } catch (e) {
      debugLog("error subscribing: $e");
      Navigator.pop(context);
    }
  }
}
