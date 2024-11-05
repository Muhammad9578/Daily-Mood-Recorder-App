import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/widgets/primary_button.dart';
import 'package:mood_maker_kp/src/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/notification_handler.dart';
import '../../../widgets/primary_text_field.dart';

class InputNotificationDetails extends StatefulWidget {
  const InputNotificationDetails({super.key});

  @override
  State<InputNotificationDetails> createState() =>
      _InputNotificationDetailsState();
}

class _InputNotificationDetailsState extends State<InputNotificationDetails> {
  int selectedHour = 1;
  final title = TextEditingController();
  final description = TextEditingController();
  bool isLoading = false;
  String scheduledAt = "";
  int selectedMinute = 0;
  late SharedPreferences prefs;

  @override
  void initState() {
    prefs = getIt.get<SharedPreferences>();

    title.text = prefs.getString(PrefsKeys.notificationTitle) ??
        AppConstants.notificationTitle;
    description.text = prefs.getString(PrefsKeys.notificationDescription) ??
        AppConstants.notificationDescription;
    selectedHour = prefs.getInt(PrefsKeys.notificationHours) ??
        AppConstants.notificationHours;
    selectedMinute = prefs.getInt(PrefsKeys.notificationMinutes) ??
        AppConstants.notificationMinutes;

    scheduledAt = "${selectedHour}:${selectedMinute}";

    super.initState();
  }

  save() async {
    try {
      debugLog(prefs.getBool(PrefsKeys.showNotificationAgain));
      bool showAgain = prefs.getBool(PrefsKeys.showNotificationAgain) ?? false;
      if (!showAgain) {
        Dialogs.showErrorDialog(
            title: "Notification",
            description:
                "Show notification is disabled. Please enable it and try again.",
            context: context);
      } else {
        {
          Dialogs.showLoadingDialog(context: context, title: "Scheduling");
          await getIt.get<NotificationsHandler>().scheduleNewNotification(
                title: title.text,
                description: description.text,
                hours: selectedHour,
                minutes: selectedMinute,
                repeats: true,
              );

          await prefs.setString(PrefsKeys.notificationTitle, title.text);
          await prefs.setString(
              PrefsKeys.notificationDescription, description.text);
          await prefs.setInt(PrefsKeys.notificationHours, selectedHour);
          await prefs.setInt(PrefsKeys.notificationMinutes, selectedMinute);

          Navigator.pop(context);
          Navigator.pop(context);
          Toasty.success("Notification scheduled successfully");
        }
      }
    } catch (e) {
      Navigator.pop(context);
      Toasty.error("Try again later");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text("Notification is currenlty scheduled at ${scheduledAt}"),
        // 20.spaceY,
        MergeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hour: ',
                semanticsLabel: "Hour",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: Fonts.medium,
                    color: AppColors.appColor),
              ),
              SizedBox(
                width: 150,
                child: dateTimeDropdown(
                  items: List.generate(
                      24,
                      (item) => DropdownMenuItem<int>(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2.0, top: 0),
                              child: Text(
                                '$item',
                                style: TextStyle(
                                    fontSize: 16, color: AppColors.appColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )).toList(),
                  onChange: (value) {
                    setState(() {
                      selectedHour = value!;
                    });
                  },
                  initialValue: selectedHour,
                ),
              )
            ],
          ),
        ),
        20.spaceY,
        MergeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minute: ',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: Fonts.medium,
                    color: AppColors.appColor),
              ),
              SizedBox(
                width: 150,
                child: dateTimeDropdown(
                    items: List.generate(
                        60,
                        (item) => DropdownMenuItem<int>(
                              value: item,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 2.0, top: 0),
                                child: Text(
                                  '$item',
                                  style: TextStyle(
                                      fontSize: 16, color: AppColors.appColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )).toList(),
                    onChange: (value) {
                      setState(() {
                        selectedMinute = value!;
                      });
                    },
                    initialValue: selectedMinute),
              )
            ],
          ),
        ),
        20.spaceY,
        Semantics(
          label: "Input field for notification title",
          child: PrimaryTextField(
            controller: title,
            textCapitalization: TextCapitalization.none,
            'Title',
            labelText: "Notification title",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter Notification title';
              }
              return null;
            },
          ),
        ),
        15.spaceY,
        Semantics(
          label: "Input field for notification description",
          child: PrimaryTextField(
            controller: description,
            textCapitalization: TextCapitalization.none,
            lines: 2,
            'description',
            labelText: "Notification description",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter Notification description';
              }
              return null;
            },
          ),
        ),
        20.spaceY,
        isLoading
            ? Center(
                child: Semantics(
                    label: "Loading",
                    child: CircularProgressIndicator(
                        color: AppColors.purpleColor)),
              )
            : PrimaryButton(
                onPress: () {
                  save();
                },
                text: 'Schedule',
              ),
      ],
    );
  }

  Widget decoratedContainer(child) {
    return Container(
      child: child,
    );
  }

  pcikDateTime() {
    return CupertinoDatePicker(onDateTimeChanged: (dateTIme) {
      debugLog("dateTIme: $dateTIme");
    });
  }

  dateTimeDropdown({items, onChange, initialValue}) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        items: items,
        value: initialValue,
        // style: TextStyle(fontSize: 20),
        onChanged: onChange,
        buttonStyleData: ButtonStyleData(
          height: 27,
          width: MediaQuery.of(context).size.width * 0.18,
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppColors.mediumBlackBorder, width: 1),
            // color: Colors.redAccent,
          ),
          // elevation: 2,
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(Icons.keyboard_arrow_down_sharp),
          iconSize: 15,
          iconEnabledColor: AppColors.appColor,
          iconDisabledColor: AppColors.appColor,
        ),
        dropdownStyleData: DropdownStyleData(
          padding: null,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: AppColors.white,
            border: Border.all(color: AppColors.mediumBlackBorder, width: 1),
            // color: Colors.redAccent,
          ),
          elevation: 5,
          offset: const Offset(0, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(5),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 20,
          padding: EdgeInsets.only(left: 5, right: 5),
        ),
      ),
    );
  }
}
