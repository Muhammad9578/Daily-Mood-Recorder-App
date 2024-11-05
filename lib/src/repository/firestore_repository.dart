import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helpers.dart';
import '../models/behaviour_history.dart';

class FireStoreRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  final FirebaseStorage firebaseStorage;

  FireStoreRepository({
    required this.firebaseAuth,
    required this.prefs,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  Future<bool> insertBehaviourHistory(
      BehaviourHistory behaviourHistory, context) async {
    try {
      String userId = prefs.getString(FirestoreConstants.id)!;
      await firebaseFirestore
          .collection(FirestoreConstants.pathBehaviourCollection)
          .doc(userId)
          .collection(FirestoreConstants.pathUserBehaviourCollection)
          .add(behaviourHistory.toJson());

      return true;
    } catch (e) {
      debugLog("Exception adding new behaviour: $e");
      throw 'Network error. Try again later';
    }

    return false;
  }

  Future<bool> insertAllBehaviours(behaviourHistory, context, userId) async {
    try {
      await firebaseFirestore
          .collection(FirestoreConstants.pathBehaviourCollection)
          .doc(userId)
          .collection(FirestoreConstants.pathUserBehaviourCollection)
          .add(behaviourHistory);

      return true;
    } catch (e) {
      debugLog("Exception adding new behaviour: $e");
      throw 'Network error. Try again later';
    }

    return false;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllBehaviours() async {
    try {
      debugLog("inside fetchAllBehaviours");
      String userId = prefs.getString(FirestoreConstants.id)!;

      QuerySnapshot<Map<String, dynamic>> data = await firebaseFirestore
          .collection(FirestoreConstants.pathBehaviourCollection)
          .doc(userId)
          .collection(FirestoreConstants.pathUserBehaviourCollection)
          .get();
      // debugLog("data: $data");
      return data;
    } catch (e) {
      debugLog("fetchAllBehaviours error: $e");
      throw e.toString();
    }
  }

  Future<int> getLaunchCount() async {
    String userId = prefs.getString(FirestoreConstants.id)!;

    DocumentSnapshot<Map<String, dynamic>> value = await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(userId)
        .get();

    if (value.exists) {
      return value.get(FirestoreConstants.launchCount);
    } else {
      return 0;
    }
  }

  Future<Map<String, dynamic>> checkUserSubscription() async {
    try {
      String userId = prefs.getString(FirestoreConstants.id)!;
      Map<String, dynamic> map = {
        FirestoreConstants.isSubscribed: false,
        FirestoreConstants.subscriptionDate: 0
      };
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await firebaseFirestore
              .collection(FirestoreConstants.pathSubscriptionCollection)
              .doc(userId)
              .get();

      if (documentSnapshot.exists &&
          documentSnapshot
              .data()!
              .containsKey(FirestoreConstants.isSubscribed)) {
        bool isSubscribed =
            documentSnapshot.get(FirestoreConstants.isSubscribed);
        if (isSubscribed) {
          map[FirestoreConstants.isSubscribed] = isSubscribed;
          map[FirestoreConstants.subscriptionDate] =
              documentSnapshot.get(FirestoreConstants.subscriptionDate);
        }
        return map;
      } else {
        debugLog("doc not exist");
        return map;
      }
    } catch (e) {
      debugLog('Error checking key: $e');
      throw "Some error occurred";
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> subscriptionStream() {
    try {
      String userId = prefs.getString(FirestoreConstants.id)!;

      return firebaseFirestore
          .collection(FirestoreConstants.pathSubscriptionCollection)
          .doc(userId)
          .snapshots();
    } catch (e) {
      debugLog('Error checking key: $e');
      throw "Some error occurred";
    }
  }

  Future<bool> updateUserSubscription(bool isSubscribed, int date) async {
    try {
      String userId = prefs.getString(FirestoreConstants.id)!;

      await firebaseFirestore
          .collection(FirestoreConstants.pathSubscriptionCollection)
          .doc(userId)
          .set({
        FirestoreConstants.isSubscribed: isSubscribed,
        FirestoreConstants.subscriptionDate: date
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugLog('Error checking key: $e');
      throw "Some error occurred";
    }
  }

  clearLaunchCount() async {
    String userId = prefs.getString(FirestoreConstants.id)!;

    await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(userId)
        .update({FirestoreConstants.launchCount: 0});
  }

  deleteCollection() async {
    try {
      String userId = prefs.getString(FirestoreConstants.id)!;
      debugLog("userId: $userId");
      final CollectionReference collectionReference = firebaseFirestore
          .collection(FirestoreConstants.pathBehaviourCollection)
          .doc(userId)
          .collection(FirestoreConstants.pathUserBehaviourCollection);

      var querySnapshot = await collectionReference.get();
      for (DocumentSnapshot docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.delete();
      }

      // After all documents are deleted, delete the collection itself
      // await collectionReference.parent!.(collectionReference.id).delete();
    } catch (e) {
      throw e.toString();
    }
  }
}
