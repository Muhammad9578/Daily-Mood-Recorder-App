import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mood_maker_kp/src/helpers/app_images.dart';
import 'package:mood_maker_kp/src/models/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'app_colors.dart';

final getIt = GetIt.instance;

void debugLog(Object? data) {
  if (kDebugMode) {
    print(data);
  }
}

void closeKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

Future<File> getImageFileFromAssets(String path) async {
  try {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  } catch (e) {
    throw e.toString();
  }
}

Future<File> createAndSharePdf(Map<String, List<BehaviourHistory>> finalList,
    Uint8List? capturedImage) async {
  try {
    final PdfDocument document = PdfDocument();
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final PdfFont heading = PdfStandardFont(PdfFontFamily.helvetica, 14,
        multiStyle: [PdfFontStyle.bold]);

    // Add first page with background color and image if available
    PdfPage firstPage = document.pages.add();
    firstPage.graphics.drawRectangle(
      brush: PdfSolidBrush(PdfColor(
        Colors.purple[500]!.red,
        Colors.purple[500]!.green,
        Colors.purple[500]!.blue,
      )),
      bounds: Rect.fromLTWH(0, 0, firstPage.getClientSize().width,
          firstPage.getClientSize().height),
    );

    if (capturedImage != null) {
      final PdfBitmap image = PdfBitmap(capturedImage);
      firstPage.graphics.drawImage(
        image,
        Rect.fromLTWH(0, 0, firstPage.getClientSize().width / 1.5, 500),
      );
    }

    // Add new pages for each entry in finalList from the 2nd page onward
    for (var entry in finalList.entries) {
      PdfPage page = document.pages.add();

      page.graphics.drawString("On ${entry.key}:", heading,
          brush: PdfBrushes.black,
          bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 20));

      double yOffset = 20; // Initial offset after heading
      entry.value.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      for (BehaviourHistory history in entry.value) {
        DateTime dt = DateTime.fromMillisecondsSinceEpoch(history.timestamp);
        String timee = DateFormat('hh:mm a').format(dt);
        String historyString = "Mood: ${history.mood.text}  at  ${timee}";

        page.graphics.drawString(historyString, font,
            brush: PdfBrushes.black,
            bounds: Rect.fromLTWH(
                20, yOffset, page.getClientSize().width - 40, 20));
        yOffset += 20;
      }
    }

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/Moods_history.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(document.saveSync());

    document.dispose();

    return file;
  } catch (e) {
    throw e.toString();
  }
}

Map<String, List<BehaviourHistory>> getBehaviourHistoryGroupedByDate(
    List<BehaviourHistory> historyList) {
  Map<String, List<BehaviourHistory>> groupedData = {};

  // Grouping the data as before
  for (var history in historyList) {
    String dateKey = "${history.day}/${history.month}";
    if (groupedData.containsKey(dateKey)) {
      groupedData[dateKey]!.add(history);
    } else {
      groupedData[dateKey] = [history];
    }
  }

  // Sorting the map based on keys
  var sortedKeys = groupedData.keys.toList()..sort((a, b) => a.compareTo(b));

  // Creating a new LinkedHashMap to maintain the order of insertion
  var sortedMap = <String, List<BehaviourHistory>>{};

  for (var key in sortedKeys) {
    sortedMap[key] = groupedData[key]!;
  }

  return sortedMap;
}

DateTime getDateOfPrevious7Days(DateTime dateTime) {
  return dateTime.subtract(const Duration(days: 7));
}

DateTime getNextMonthSameDay(DateTime dateTime) {
  // Add one month to the given date
  DateTime nextMonth =
      DateTime(dateTime.year, dateTime.month + 1, dateTime.day);

  // If the next month has fewer days than the current month's day, adjust
  while (
      nextMonth.month == dateTime.month + 1 && nextMonth.day != dateTime.day) {
    nextMonth = nextMonth.subtract(Duration(days: 1));
  }

  return nextMonth;
}

DateTime subtractOneDay(DateTime dateTime) {
  // Add one day to the given DateTime
  return dateTime.subtract(Duration(days: 1));
}

DateTime getNextDateAfter31Days(int timestamp) {
  // Convert the timestamp string to DateTime object
  DateTime subscribedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
  String formattedDate = DateFormat('yyyy-MM-dd').format(subscribedDate);
  subscribedDate = DateTime.parse(formattedDate);
  // subscribedDate = DateTime.parse("2024-01-05");
  debugLog("subscribedDate: $subscribedDate");
  // subscribedDate = subtractOneDay(subscribedDate);

  DateTime nextMonthSameDay = getNextMonthSameDay(subscribedDate);
  debugLog("nextMonthSameDay: $nextMonthSameDay");

  nextMonthSameDay = subtractOneDay(nextMonthSameDay);
  return nextMonthSameDay;

  debugLog("subscribedDate: $subscribedDate");
  // Add 31 days to the initial date
  return subscribedDate.add(Duration(days: 32));
}

int getDaysLeft(DateTime nextDate) {
  // Get the current date
  DateTime dt = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dt);
  DateTime currentDate = DateTime.parse(formattedDate);
  currentDate = DateTime.parse('2024-02-04');

  debugLog("expiresOn: $nextDate");
  debugLog("currentDate: $currentDate");
  // Calculate the difference between nextDate and currentDate
  Duration difference = nextDate.difference(currentDate);

  // Convert the duration into days
  int daysLeft = difference.inDays;

  return daysLeft;
}

String getExpirationMessage(DateTime expiresOn) {
  // Get the current date
  DateTime dt = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(dt);
  DateTime currentDate = DateTime.parse(formattedDate);
  currentDate = DateTime.parse('2024-02-04');

  // Calculate the difference between expiresOn and currentDate
  Duration difference = expiresOn.difference(currentDate);
  debugLog("difference: ${difference.inDays}");
  if (difference.inDays == 0) {
    return 'Expires today';
  } else if (difference.inDays == 1) {
    return 'Expires tomorrow';
  } else {
    String formattedDate = DateFormat('dd-MM-yyyy').format(expiresOn.toLocal());
    return 'Expires on $formattedDate';
  }
}

// bool is31DaysBefore(int timestamp) {
//   // Get the current date
//   DateTime subscribedDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
//
//   DateTime currentDate = DateTime.now();
//
//   // Calculate the difference between the given dateTime and the currentDate
//   Duration difference = currentDate.difference(dateTime);
//
//   // Check if the difference is exactly 31 days
//   return difference.inDays == 31;
// }
// keymapRowBuild(
// text: "Excellent", color: AppColors.excellentMoodColor),
// keymapRowBuild(text: "Good", color: AppColors.goodMoodColor),
// keymapRowBuild(text: "Ok", color: AppColors.okMoodColor),
// keymapRowBuild(text: "Bad", color: AppColors.badMoodColor),
// keymapRowBuild(text: "Terrible", color: AppColors.terribleMoodColor),

List<Behaviour> dummyMoods = [
  Behaviour(
      id: 0,
      emoji: "👌",
      text: "Excellent",
      image: BehaviourImage.excellent,
      moodGraphColor: AppColors.excellentMoodColor),
  Behaviour(
      id: 1,
      emoji: "🤗",
      text: "Good",
      image: BehaviourImage.good,
      moodGraphColor: AppColors.goodMoodColor),
  Behaviour(
      id: 2,
      emoji: "👍",
      text: "Ok",
      image: BehaviourImage.ok,
      moodGraphColor: AppColors.okMoodColor),
  Behaviour(
      id: 3,
      emoji: "😨",
      text: "Bad",
      image: BehaviourImage.bad,
      moodGraphColor: AppColors.badMoodColor),
  Behaviour(
      id: 4,
      emoji: "😱",
      text: "Terrible",
      image: BehaviourImage.terrible,
      moodGraphColor: AppColors.terribleMoodColor),

  // Behaviour(id: 4, text: "Others", image: BehaviourImage.other),
];

// List<Behaviour> dummyActivities = [
//   Behaviour(
//       id: 0, emoji: "🏋️‍♀️", text: "Exercise", image: BehaviourImage.exercise),
//   Behaviour(
//       id: 1, emoji: "🚶‍♀️", text: "Walking", image: BehaviourImage.walking),
//   Behaviour(
//       id: 2,
//       emoji: "👨‍👩‍👧‍👦",
//       text: "Family",
//       image: BehaviourImage.family),
//   Behaviour(
//       id: 3,
//       emoji: "👩‍❤️‍👨",
//       text: "Relationship",
//       image: BehaviourImage.relationship),
//   Behaviour(id: 4, emoji: "🤝", text: "Friends", image: BehaviourImage.friends),
//   Behaviour(id: 4, emoji: "🧑🏻‍💻", text: "Work", image: BehaviourImage.work),
//   Behaviour(id: 4, emoji: "♫", text: "Music", image: BehaviourImage.music),
//   Behaviour(id: 4, emoji: "👩🏻‍🎨", text: "Art", image: BehaviourImage.art),
//   Behaviour(id: 4, emoji: "✈️", text: "Travel", image: BehaviourImage.travel),
//   Behaviour(
//       id: 4, emoji: "🧘", text: "Meditation", image: BehaviourImage.meditation),
//   Behaviour(id: 4, emoji: "🪐", text: "Others", image: BehaviourImage.other),
// ];

List<Behaviour> okMoodActivities = [
  Behaviour(
      id: 2,
      emoji: "👨‍👩‍👧‍👦",
      text: "Family",
      image: BehaviourImage.family),
  Behaviour(
      id: 3,
      emoji: "👩‍❤️‍👨",
      text: "Relationship",
      image: BehaviourImage.relationship),
  Behaviour(id: 4, emoji: "♫", text: "Music", image: BehaviourImage.music),
  Behaviour(id: 4, emoji: "👩🏻‍🎨", text: "Art", image: BehaviourImage.art),
  Behaviour(id: 4, emoji: "✈️", text: "Travel", image: BehaviourImage.travel),
  Behaviour(
      id: 4, emoji: "🧘", text: "Meditation", image: BehaviourImage.meditation),
  Behaviour(id: 4, emoji: "🪐", text: "Others", image: BehaviourImage.other),
];

List<Behaviour> downMoodActivities = [
  Behaviour(
      id: 4, emoji: "🖥️", text: "Watching Tv", image: BehaviourImage.work),
  Behaviour(
      id: 4,
      emoji: "🍔",
      text: "Eating Fast Food",
      image: BehaviourImage.music),
];

List<Behaviour> happyMoodsActivities = [
  Behaviour(
      id: 0, emoji: "🏋️‍♀️", text: "Exercise", image: BehaviourImage.exercise),
  Behaviour(
      id: 1, emoji: "🚶‍♀️", text: "Walking", image: BehaviourImage.walking),
  Behaviour(id: 4, emoji: "🤝", text: "Friends", image: BehaviourImage.friends),
  Behaviour(id: 4, emoji: "👩🏻‍💻", text: "Work", image: BehaviourImage.work),
  Behaviour(id: 4, emoji: "🪐", text: "Others", image: BehaviourImage.other),
];

List<Behaviour> dummyEmotions = [
  Behaviour(id: 0, emoji: "🤩", text: "Excited", image: BehaviourImage.excited),
  Behaviour(id: 1, emoji: "😊", text: "Happy", image: BehaviourImage.happy),
  Behaviour(
      id: 2, emoji: "🥰", text: "Grateful", image: BehaviourImage.grateful),
  Behaviour(id: 3, emoji: "😒", text: "Bored", image: BehaviourImage.bored),
  Behaviour(
      id: 4, emoji: "🤕", text: "Stressed", image: BehaviourImage.stressed),
  Behaviour(id: 4, emoji: "😱", text: "Afraid", image: BehaviourImage.afraid),
  Behaviour(id: 4, emoji: "😡", text: "Angry", image: BehaviourImage.angry),
  Behaviour(id: 4, emoji: "🥺", text: "Sad", image: BehaviourImage.sad),
  Behaviour(id: 4, emoji: "🪐", text: "Others", image: BehaviourImage.other),
];

List<BehaviourHistory> dummyHistory = [];

List<Quote> dummyQuotes = [];

final List<Map<String, String>> inspirationalQuotes = [
  {
    "quote":
        "Knowledge without action is madness and action without knowledge is void.",
    "author": "Imam Ghazali"
  },
  {
    "quote": "The cure for ignorance is to question.",
    "author": "Ibn Rushd (Averroes)"
  },
  {
    "quote":
        "The universe is not outside of you. Look inside yourself; everything that you want, you already are.",
    "author": "Rumi"
  },
  {"quote": "Knowledge is the life of the mind.", "author": "Ibn Khaldun"},
  {
    "quote":
        "I fear the day when the disbelievers are proud of their falsehood, and the Muslims are shy of their faith.",
    "author": "Umar ibn al-Khattab"
  },
  {
    "quote":
        "Acquire knowledge; it enables its possessor to distinguish right from wrong.",
    "author": "Al-Biruni"
  },
  {
    "quote": "The way to get started is to quit talking and begin doing.",
    "author": "Walt Disney"
  },
  {
    "quote": "Don't let yesterday take up too much of today.",
    "author": "Will Rogers"
  },
  {
    "quote": "It's not whether you get knocked down, it's whether you get up.",
    "author": "Vince Lombardi"
  },
  {
    "quote": "The only way to do great work is to love what you do.",
    "author": "Steve Jobs"
  },
  {"quote": "If you can dream it, you can achieve it.", "author": "Zig Ziglar"},
  {
    "quote": "Don't watch the clock; do what it does. Keep going.",
    "author": "Sam Levenson"
  },
  {
    "quote": "Believe you can and you're halfway there.",
    "author": "Theodore Roosevelt"
  },
  {
    "quote":
        "The future belongs to those who believe in the beauty of their dreams.",
    "author": "Eleanor Roosevelt"
  },
  {
    "quote":
        "The only limit to our realization of tomorrow is our doubts of today.",
    "author": "Franklin D. Roosevelt"
  },
  {
    "quote": "The way to get started is to quit talking and begin doing.",
    "author": "Walt Disney"
  },
  {
    "quote": "Don't let yesterday take up too much of today.",
    "author": "Will Rogers"
  },
  {
    "quote": "It's not whether you get knocked down, it's whether you get up.",
    "author": "Vince Lombardi"
  },
  {
    "quote": "The only way to do great work is to love what you do.",
    "author": "Steve Jobs"
  },
  {"quote": "If you can dream it, you can achieve it.", "author": "Zig Ziglar"},
  {
    "quote": "Don't watch the clock; do what it does. Keep going.",
    "author": "Sam Levenson"
  },
  {
    "quote": "Believe you can and you're halfway there.",
    "author": "Theodore Roosevelt"
  },
  {
    "quote":
        "The future belongs to those who believe in the beauty of their dreams.",
    "author": "Eleanor Roosevelt"
  },
  {
    "quote":
        "The only limit to our realization of tomorrow is our doubts of today.",
    "author": "Franklin D. Roosevelt"
  },
  {
    "quote": "Creativity is intelligence having fun.",
    "author": "Albert Einstein"
  },
  {
    "quote":
        "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "author": "Zig Ziglar"
  },
  {
    "quote":
        "The best time to plant a tree was 20 years ago. The second best time is now.",
    "author": "Chinese Proverb"
  },
  {
    "quote": "The journey of a thousand miles begins with one step.",
    "author": "Lao Tzu"
  },
  {
    "quote":
        "Success is not final, failure is not fatal: It is the courage to continue that counts.",
    "author": "Winston Churchill"
  },
  {
    "quote": "It does not matter how slowly you go as long as you do not stop.",
    "author": "Confucius"
  },
  {
    "quote":
        "Our greatest fear should not be of failure but of succeeding at things in life that don't really matter.",
    "author": "Francis Chan"
  },
  {
    "quote": "You miss 100% of the shots you don’t take.",
    "author": "Wayne Gretzky"
  },
  {
    "quote":
        "The only person you are destined to become is the person you decide to be.",
    "author": "Ralph Waldo Emerson"
  },
  {
    "quote":
        "The road to success and the road to failure are almost exactly the same.",
    "author": "Colin R. Davis"
  },
  {
    "quote":
        "Motivation comes from within. No one can hand it to you, but no one can take it away, either.",
    "author": "Zig Ziglar"
  },
];
