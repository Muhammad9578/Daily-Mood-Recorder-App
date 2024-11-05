import 'dart:ui';
import 'helpers.dart';
import 'package:flutter/material.dart';

class MyTextStyle {
  static var boldBlack = const TextStyle(
      color: AppColors.purpleColor,
      // fontFamily: "Baloo2",
      fontWeight: FontWeight.w700);
  static var semiBoldDarkBlack = const TextStyle(
      color: AppColors.black,
      // fontFamily: "Baloo2",
      fontWeight: FontWeight.w600);

  static var mediumBlack = const TextStyle(
      color: AppColors.purpleColor,
      // fontFamily: "Baloo2",
      fontSize: 16,
      fontWeight: FontWeight.w500);
  static var mediumWhite = const TextStyle(
      color: AppColors.white,
      // fontFamily: "Baloo2",
      fontSize: 18,
      fontWeight: FontWeight.w500);
  static var regularBlack = const TextStyle(
      color: AppColors.purpleColor,
      // fontFamily: "Baloo2",
      fontSize: 18,
      fontWeight: FontWeight.w400);
  static var regularWhite = const TextStyle(
      color: AppColors.white,
      // fontFamily: "Baloo2",
      fontSize: 12,
      fontWeight: FontWeight.w400);
  static var regularLightBlack = const TextStyle(
      color: AppColors.purpleColor,
      // fontFamily: "Baloo2",
      fontSize: 16,
      fontWeight: FontWeight.w400);

  static var regularHintBlack = const TextStyle(
      color: AppColors.lightBlackHint,
      // fontFamily: "Baloo2",
      fontSize: 18,
      fontWeight: FontWeight.w400);
}
