import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mood_maker_kp/src/helpers/helpers.dart';
import 'package:mood_maker_kp/src/repository/firestore_repository.dart';

class SubscriptionController extends ChangeNotifier {
  bool isSubscribed = false;
  int subscriptionTimestamp = 0;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      streamSubscription;

  Future<bool> setIsSubscribed(bool sub, int timestamp) async {
    try {
      await getIt
          .get<FireStoreRepository>()
          .updateUserSubscription(sub, timestamp);
      isSubscribed = sub;
      subscriptionTimestamp = timestamp;
      notifyListeners();
      return isSubscribed;
    } catch (e) {
      debugLog(e);
      debugLog("Some error occurred");
      return false;
    }
  }

  Future<bool> checkIsSubscribed() async {
    try {
      Map<String, dynamic> map =
          await getIt.get<FireStoreRepository>().checkUserSubscription();
      isSubscribed = map[FirestoreConstants.isSubscribed];
      if (isSubscribed) {
        bool isExpired =
            isSubscriptionExpire(map[FirestoreConstants.subscriptionDate]);
        if (isExpired) {
          // Set false
          isSubscribed = false;
          await setIsSubscribed(false, DateTime.now().millisecondsSinceEpoch);

          return isSubscribed;
        } else {
          return isSubscribed;
        }
      } else {
        notifyListeners();
        return isSubscribed;
      }
    } catch (e) {
      debugLog("error: $e");
      isSubscribed = false;
      notifyListeners();
      return isSubscribed;
    }
  }

  void subSubscriptionStream() {
    try {
      Stream<DocumentSnapshot<Map<String, dynamic>>> subscriptionStream =
          getIt.get<FireStoreRepository>().subscriptionStream();
      streamSubscription = subscriptionStream
          .listen((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
        if (documentSnapshot.exists &&
            documentSnapshot
                .data()!
                .containsKey(FirestoreConstants.isSubscribed)) {
          isSubscribed = documentSnapshot.get(FirestoreConstants.isSubscribed);
          subscriptionTimestamp =
              documentSnapshot.get(FirestoreConstants.subscriptionDate);
          notifyListeners();
        } else {
          isSubscribed = false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugLog("error: $e");
      // isSubscribed = false;
      // notifyListeners();
    }
  }

  isSubscriptionExpire(int timeStamp) {
    DateTime expiresOn = getNextDateAfter31Days(timeStamp);
    int daysLeft = getDaysLeft(expiresOn);
    debugLog("daysLeft: $daysLeft");
    if (daysLeft < 0) {
      // expires
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
  }
}
