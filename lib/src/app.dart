import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/behaviour_controller.dart';
import 'package:mood_maker_kp/src/controllers/subscription_controller.dart';
import 'package:mood_maker_kp/src/controllers/trends_controller.dart';
import 'package:mood_maker_kp/src/helpers/helpers.dart';
import 'package:provider/provider.dart';

import 'controllers/auth_controller.dart';
import 'controllers/inspiration_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => getIt<AuthController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<BehaviourController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<TrendController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<SubscriptionController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<InspirationController>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: mainNavigationKey,
        title: "MeMood",
        initialRoute: Routes.splashScreen,
        onGenerateRoute: RouteGenerator.generateRoute,
        color: Colors.purple,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.appColor,
          appBarTheme: AppBarTheme(color: AppColors.appColor),
          progressIndicatorTheme:
              const ProgressIndicatorThemeData(color: AppColors.white),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              // backgroundColor: MaterialStateProperty.all(Colors.white),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              textStyle: MaterialStateProperty.all(
                const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
          fontFamily: FontFamily.courgette,

          // textTheme: TextTheme()
        ),
      ),
    );
  }
}
