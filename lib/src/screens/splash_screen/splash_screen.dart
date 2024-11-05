import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

import '../../helpers/helpers.dart';

class SplashScreen extends StatefulWidget {
  static const String route = "splashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AuthController authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthController>();
    authProvider.handleLoginMovement(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              image: true,
              label: "Logo",
              child: Image.asset(
                MyImage.logo,
                height: 140,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
