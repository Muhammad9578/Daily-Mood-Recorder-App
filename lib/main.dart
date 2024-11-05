import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/controllers/auth_controller.dart';
import 'src/controllers/behaviour_controller.dart';
import 'src/controllers/inspiration_controller.dart';
import 'src/controllers/subscription_controller.dart';
import 'src/controllers/trends_controller.dart';
import 'src/helpers/notification_handler.dart';
import 'src/helpers/utils.dart';
import 'src/models/models.dart';
import 'src/repository/firestore_repository.dart';

void setupLocator(SharedPreferences prefs, NotificationsHandler handler) {
  // Registering your dependencies
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Registering the AuthController
  getIt.registerFactory<AuthController>(() =>
      AuthController(
        firebaseAuth: getIt<FirebaseAuth>(),
        prefs: getIt<SharedPreferences>(),
        firebaseFirestore: getIt<FirebaseFirestore>(),
        firebaseStorage: getIt<FirebaseStorage>(),
      ));
  getIt.registerFactory<FireStoreRepository>(() =>
      FireStoreRepository(
        firebaseAuth: getIt<FirebaseAuth>(),
        prefs: getIt<SharedPreferences>(),
        firebaseFirestore: getIt<FirebaseFirestore>(),
        firebaseStorage: getIt<FirebaseStorage>(),
      ));

  // Registering the BehaviourController
  getIt.registerFactory<BehaviourController>(() => BehaviourController());
  getIt.registerFactory<TrendController>(
          () => TrendController(prefs: getIt<SharedPreferences>()));
  getIt.registerFactory<SubscriptionController>(() => SubscriptionController());
  getIt.registerFactory<InspirationController>(() => InspirationController());
  getIt.registerFactory<NotificationsHandler>(() => handler);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  for (Map q in inspirationalQuotes) {
    dummyQuotes.add(Quote.fromJson(q));
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  NotificationsHandler notificationsHandler = NotificationsHandler();
  setupLocator(prefs, notificationsHandler);

  // ********** initialize awesome notification plugin *********

  await notificationsHandler.initializeLocalNotifications();
  await notificationsHandler.initializeIsolateReceivePort();

  runApp(const MyApp());
}

//we will wait for it to install on simulator.
// i just forget password , it was 123456
//we will allow notification

