import 'package:flutter/material.dart';

import '../screens/activity_screen/activity_screen.dart';
import '../screens/edit_profile_screen/edit_profile_screen.dart';
import '../screens/email_verification_screen/email_verification_screen.dart';
import '../screens/emotion_screen/emotion_screen.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/login_screen/login_screen.dart';
import '../screens/mood_screen/mood_screen.dart';
import '../screens/signup_screen/signup_screen.dart';
import '../screens/splash_screen/splash_screen.dart';
import '../screens/trends_screen/trends_screen.dart';
import 'app_constants.dart';

class Routes {
  static const String splashScreen = "splashScreen";
  static const String homeScreen = "homeScreen";
  static const String loginScreen = "loginScreen";
  static const String emailVerificationScreen = "emailVerificationScreen";
  static const String signupScreen = "signupScreen";
  static const String activityScreen = "activityScreen";
  static const String emotionScreen = "emotionScreen";
  static const String moodScreen = "moodScreen";
  static const String editProfileScreen = "editProfileScreen";
  static const String trendsScreen = "trendsScreen";
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) {
            final args = settings.arguments as Map?;
            return HomeScreen(
              fromStart: args?[PrefsKeys.fromStart] ?? false,
              newIndex: args?[PrefsKeys.pageNumber] ?? 0,

            );
          },
        );
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case Routes.emailVerificationScreen:
        return MaterialPageRoute(
          builder: (_) => const EmailVerificationScreen(),
        );
      case Routes.signupScreen:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
        );
      case Routes.moodScreen:
        return MaterialPageRoute(
          builder: (_) => const MoodScreen(),
        );
      case Routes.activityScreen:
        return MaterialPageRoute(
          builder: (_) => const ActivityScreen(),
        );
      case Routes.emotionScreen:
        return MaterialPageRoute(
          builder: (_) => const EmotionScreen(),
        );
      case Routes.editProfileScreen:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );
      case Routes.trendsScreen:
        return MaterialPageRoute(
          builder: (_) => const TrendsScreen(),
        );

    // case subCategoryListScreen:
    //   List<dynamic> confirmLocationArguments =
    //   settings.arguments as List<dynamic>;
    //   return CupertinoPageRoute(
    //     builder: (_) => ChangeNotifierProvider<CategoryListProvider>(
    //       create: (context) => CategoryListProvider(),
    //       child: SubCategoryListScreen(
    //         categoryName: confirmLocationArguments[0] as String,
    //         categoryId: confirmLocationArguments[1] as String,
    //       ),
    //     ),
    //   );

      default:
      // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
