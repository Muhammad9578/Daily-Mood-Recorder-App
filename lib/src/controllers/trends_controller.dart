import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mood_maker_kp/src/controllers/subscription_controller.dart';
import 'package:mood_maker_kp/src/helpers/helpers.dart';
import 'package:mood_maker_kp/src/models/behaviour_history.dart';
import 'package:mood_maker_kp/src/repository/local_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/firestore_repository.dart';

enum TrendsState { loading, loaded, error }

class TrendController extends ChangeNotifier {
  final SharedPreferences prefs;

  TrendsState controllerState = TrendsState.loading;
  List<BehaviourHistory>? behaviourHistory;

  TrendController({required this.prefs});

  setBehaviourHistory(List<BehaviourHistory> history) {
    behaviourHistory = history;
    notifyListeners();
  }

  void setControllerState(state) {
    controllerState = state;
    notifyListeners();
  }

  Future<List<BehaviourHistory>> getBehaviourHistory(
      SubscriptionController subscriptionController) async {
    // if(settingsRefreshIndicatorKey.)
    try {
      DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
      DateTime end = DateTime.now(); //format.parse('2023-1-5 15:30:00');
      DateTime start = getDateOfPrevious7Days(end);
      List<BehaviourHistory> hs;

      List<Map<String, dynamic>> aa =
          await DatabaseHelper().getBehaviourHistoryByTime(start, end);
      hs = filterListByDate(aa, start, end);

      return hs;
    } catch (e) {
      debugLog("Error getBehaviourHistory: $e");
      throw ("There is some problem is fetching record");
    }
  }

  Future<void> fetchAllBehaviourFromFirestore() async {
    try {
      debugLog("inside fetchAllBehaviourFromFirestore");
      // load data from firestore and save in localDb
      QuerySnapshot<Map<String, dynamic>> data =
          await getIt.get<FireStoreRepository>().fetchAllBehaviours();
      // debugLog("fetchAllBehaviourFromFirestore data: $data");
      // filterListByDate(lst, start, end);
      if (data.size > 0) {
        if (data.docs.length > 0) {
          for (QueryDocumentSnapshot<Map<String, dynamic>> dt in data.docs) {
            BehaviourHistory history = BehaviourHistory.fromJson(dt.data());

            await DatabaseHelper()
                .insertBehaviourHistoryInMap(history.toJson());
          }
        }
      }
    } catch (e) {
      debugLog("fetchAllBehaviourFromFirestore error: $e");
    }
  }

  List<BehaviourHistory> filterListByDate(
      List<Map<String, dynamic>> myList, DateTime startDate, DateTime endDate) {
    List<BehaviourHistory> dummy = [];

    for (Map<String, dynamic> dt in myList) {
      // Convert the data from the document into a BehaviourHistory object
      BehaviourHistory history = BehaviourHistory.fromJson(dt);

      // Convert the timestamp to DateTime to compare with startDate and endDate
      DateTime historyDate =
          DateTime.fromMillisecondsSinceEpoch(history.timestamp);

      // Check if historyDate is between startDate and endDate (inclusive)
      if (historyDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          historyDate.isBefore(endDate.add(Duration(days: 1)))) {
        dummy.add(history);
      }
    }
    return dummy;
  }

  loadData(context) async {
    SubscriptionController subscriptionController =
        Provider.of<SubscriptionController>(context, listen: false);
    subscriptionController.subSubscriptionStream();
    bool isSub = await subscriptionController.checkIsSubscribed();
    debugLog("User subscripton status: $isSub");

    if (isSub) {
      debugLog("User has subscribed");

      bool exist = await DatabaseHelper().doesTableExist();
      print("table exist: $exist");
      if (exist == false) {
        await fetchAllBehaviourFromFirestore();
      }
    }
  }

  saveBehaviourFromLocalToFirestore(context) async {
    try {
      List<Map<String, dynamic>> result =
          await DatabaseHelper().getAllBehaviours();

      String userId = prefs.getString(FirestoreConstants.id)!;

      List<BehaviourHistory> behaviourHistoryList = [];
      for (Map<String, dynamic> item in result) {
        // behaviourHistoryList.add(BehaviourHistory.fromJson(item));
        bool result = await getIt
            .get<FireStoreRepository>()
            .insertAllBehaviours(item, context, userId);
      }

      // await DatabaseHelper().deleteAllFromTable();
    } catch (e) {
      debugLog("Error caching data: $e");
    }
  }
}
