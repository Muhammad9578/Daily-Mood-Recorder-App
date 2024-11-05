import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'helpers.dart';

class Dialogs {
  static Future<void> showErrorDialog({title, description, context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Padding(
            padding: const EdgeInsets.all(0.0),
            child: MergeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${title}",
                    semanticsLabel: "${title}",
                    style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      "${description}",
                      semanticsLabel: "${description}",
                      style: const TextStyle(
                          color: AppColors.purpleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          padding: EdgeInsets.only(left: 50, right: 50)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Okay",
                        semanticsLabel: "Okay button",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showRatingDialog({title, description, context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${title}",
                  style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    "${description}",
                    style: const TextStyle(
                        color: AppColors.purpleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                // Center(
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //         backgroundColor: AppColors.white,
                //         padding: EdgeInsets.only(left: 50, right: 50)),
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //     child: Text("Okay"),
                //   ),
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final String url = Platform.isAndroid
                      ? 'https://play.google.com/store/apps/details?id=${AppConstants.playStoreAppId}'
                      : 'https://apps.apple.com/us/app/memood/id${AppConstants.appStoreAppId}';

                  if (!await launchUrl(Uri.parse(url))) {
                    throw Exception('Could not launch $url');
                  }
                },
                child: Text(
                  "Rate",
                  style: TextStyle(color: AppColors.purpleColor),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.purpleColor),
                )),
          ],
        );
      },
    );
  }

  static Future<void> showSubscriptionDialog(
      {String? title = "Subscribe",
      String? description =
          "Subscribe and save your data on cloud and access it from any where at any time.",
      context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${title}",
                  style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    "${description}",
                    style: const TextStyle(
                        color: AppColors.purpleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // Center(
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //         backgroundColor: AppColors.white,
                //         padding: EdgeInsets.only(left: 50, right: 50)),
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //     child: Text("Okay"),
                //   ),
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.homeScreen,
                      arguments: {PrefsKeys.pageNumber: 2},
                      (route) => false);
                },
                child: Text(
                  "Go to subscription page",
                  style: TextStyle(
                      color: AppColors.purpleColor,
                      fontFamily: FontFamily.courgette,
                      fontWeight: Fonts.semiBold),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: AppColors.purpleColor,
                      fontFamily: FontFamily.courgette,
                      fontSize: 16),
                )),
          ],
        );
      },
    );
  }

  static Future<void> showExitDialog(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            clipBehavior: Clip.hardEdge,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                color: AppColors.lightOrange.withOpacity(0.5),
                padding: EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30,
                        color: AppColors.lightGreen,
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(
                          color: AppColors.lightGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to logout?',
                      style:
                          TextStyle(color: AppColors.lightGreen, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Cancel',
                      style: MyTextStyle.regularLightBlack,
                      // style: TextStyle(
                      //     color: ColorConstants.primaryColor,
                      //     fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  var userAuthenticate =
                      Provider.of<AuthController>(context, listen: false);
                  userAuthenticate.handleSignOut();
                  // closing dialog
                  Navigator.pop(context);

                  Navigator.pushNamedAndRemoveUntil(
                      context, Routes.loginScreen, (route) => false);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        // color: ColorConstants.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      'Yes',
                      style: MyTextStyle.regularLightBlack,
                      // style: TextStyle(
                      //     color: ColorConstants.primaryColor,
                      //     fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  static Future<void> showLoadingDialog({title, context}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: 60,
              child: Semantics(
                label: "Loading please wait",
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Center(
                      child: CircularProgressIndicator.adaptive(
                        // valueColor: AlwaysStoppedAnimation(AppColors.lightOrange),
                        backgroundColor: AppColors.purpleColor,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        "${title}",
                        style: MyTextStyle.regularBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showSaveDialog(
      {title, description, context, onTap}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Padding(
            padding: const EdgeInsets.all(0.0),
            child: MergeSemantics(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${title}",
                    semanticsLabel: "${title}",
                    style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      "${description}",
                      semanticsLabel: "${description}",
                      style: const TextStyle(
                          color: AppColors.purpleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appColor,
                          padding: EdgeInsets.only(left: 50, right: 50)),
                      onPressed: onTap,
                      child: Text(
                        "Okay",
                        semanticsLabel: "Okay button",
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: Fonts.medium),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
