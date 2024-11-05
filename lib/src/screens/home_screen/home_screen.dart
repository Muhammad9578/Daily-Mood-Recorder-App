import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/helpers.dart';
import '../../helpers/notification_handler.dart';
import '../../repository/firestore_repository.dart';
import '../checkin_screen/checkin_screen.dart';
import '../inspiration_screen/inspiration_screen.dart';
import '../settings_screen/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  bool? fromStart;
  int newIndex;

  HomeScreen({super.key, this.newIndex = 0, this.fromStart = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    _currentIndex = widget.newIndex;

    _tabController =
        TabController(length: 3, vsync: this, initialIndex: _currentIndex);

    super.initState();
    initiate();
  }

  initiate() async {
    if (widget.fromStart!) {
      Future.delayed(const Duration(seconds: 5)).then((value) async {
        final prefs = getIt.get<SharedPreferences>();
        bool showAgain = prefs.getBool(PrefsKeys.showNotificationAgain) ?? true;
        if (showAgain) {
          await initializeNotification(prefs);
        }
        checkLaunchCount();
      });
    }
  }

  initializeNotification(prefs) async {
    NotificationsHandler notificationsHandler =
        getIt.get<NotificationsHandler>();
    NotificationsHandler.startListeningNotificationEvents();

    await notificationsHandler.scheduleNewNotification(
      title: prefs.getString(PrefsKeys.notificationTitle) ??
          AppConstants.notificationTitle,
      description: prefs.getString(PrefsKeys.notificationDescription) ??
          AppConstants.notificationDescription,
      hours: prefs.getInt(PrefsKeys.notificationHours) ??
          AppConstants.notificationHours,
      minutes: prefs.getInt(PrefsKeys.notificationMinutes) ??
          AppConstants.notificationMinutes,
      repeats: true,
    );
  }

  checkLaunchCount() async {
    try {
      int count = await getIt.get<FireStoreRepository>().getLaunchCount();
      if (count >= 15) {
        if (mounted) {
          await Dialogs.showRatingDialog(
              title: "Rate app",
              description: "Do you want to rate your experience?",
              context: context);
        }

        await getIt.get<FireStoreRepository>().clearLaunchCount();
      }
    } catch (e) {
      debugLog("error launching rating dialog: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        controller: _tabController,
        style: TabStyle.react,
        backgroundColor: AppColors.bottomBarColor,
        elevation: 5,
        items: const [
          TabItem(
            icon: Icons.mood,
            title: 'CheckIn',
          ),
          TabItem(icon: Icons.text_snippet_outlined, title: 'Inspiration'),
          TabItem(icon: Icons.settings_outlined, title: 'Settings'),
        ],
        initialActiveIndex: 1,
        onTap: onTabTapped,
      ),
      body: Column(
        children: [
          Expanded(child: _getBody(_currentIndex)),
        ],
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return const CheckInScreen();
      case 1:
        return const InspirationScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const CheckInScreen();
    }
  }
}
