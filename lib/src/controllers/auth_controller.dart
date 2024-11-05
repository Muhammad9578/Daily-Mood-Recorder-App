import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mood_maker_kp/src/controllers/trends_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helpers.dart';
import '../models/models.dart';

class AuthController extends ChangeNotifier with WidgetsBindingObserver {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  final FirebaseStorage firebaseStorage;
  bool loggedInUser = false;

  AuthController({
    required this.firebaseAuth,
    required this.prefs,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  String? getUserFirebaseId() {
    debugLog(
        "prefs.getString(FirestoreConstants.id); = ${prefs.getString(FirestoreConstants.id)}");

    return prefs.getString(FirestoreConstants.id);
  }

  handleLoginMovement(context) async {
    debugLog("inside handleLoginMovement");
    bool isLogged = await isLoggedIn();
    if (isLogged) {
      await addLaunchCount();
      Provider.of<TrendController>(context, listen: false).loadData(context);
      // subscription.

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, Routes.homeScreen,
            arguments: {PrefsKeys.fromStart: true});
      });
      // Navigator.pushReplacementNamed(context, Homepage.route);
      // return;
    } else {
      Navigator.pushReplacementNamed(context, Routes.loginScreen);
    }
  }

  addLaunchCount() {
    print("addLaunchCount:addLaunchCount");
    String userId = prefs.getString(FirestoreConstants.id)!;

    firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(userId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> value) {
      debugLog("value: $value");
      int count = value.get(FirestoreConstants.launchCount);
      debugLog("count: $count");

      count += 1;
      firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(userId)
          .update(
        {FirestoreConstants.launchCount: count++},
      ).then((value) {
        debugLog("count added:");
      });
    });
  }

  Future<bool> isLoggedIn() async {
    // bool isLoggedIn = await GoogleSignIn().isSignedIn();
    // return true;
    if (prefs.getString(FirestoreConstants.id)?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> emailPasswordSignIn(email, password, context) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final QuerySnapshot result = await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.id, isEqualTo: credential.user!.uid)
          .get();

      final List<DocumentSnapshot> documents = result.docs;

      // Already sign up, just get data from firestore
      DocumentSnapshot documentSnapshot = documents[0];
      UserModel user = UserModel.fromDocument(documentSnapshot);

      // Write data to shared_preferences
      await addToLocal(
          user.id, user.email, user.username, user.photoUrl, password);

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw 'No Internet Connection';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password';
      } else if (e.code == 'user-not-found') {
        print('Invalid email');
        throw 'Email does not exist';
      } else {
        throw e.code.toString();
      }
    }
    return false;
  }

  Future<String> addUserImage(File image) async {
    try {
      // Extract image name from image cache url
      var pathimage = image.toString();
      var temp = pathimage.lastIndexOf('/');
      var result = pathimage.substring(temp + 1);
      debugLog("pathimage final = $result");
      debugLog("simple image path= ${image.path}");

      // Saving image in firebase storage
      final ref = firebaseStorage.ref().child('UserImages').child(result);
      var response1 = await ref.putFile(image);
      print("Updated $response1");
      var imageUrl = await ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> emailPasswordSignUp(
      UserModel userDetails, imageFile, context) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: userDetails.email,
        password: userDetails.password!,
      );

      String imgUrl = '';
      // if it is not null. it means user have selected image, so we first add it in firestore
      if (imageFile != null) {
        imgUrl = await addUserImage(imageFile);
      }

      userDetails.photoUrl = imgUrl;
      var firebaseUser = credential.user;

      // Writing data to fire-store because here is a new user
      firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .doc(firebaseUser!.uid)
          .set({
        FirestoreConstants.username: userDetails.username,
        FirestoreConstants.photoUrl: userDetails.photoUrl,
        FirestoreConstants.id: firebaseUser.uid,
        FirestoreConstants.email: firebaseUser.email,
        // FirestoreConstants.password: userDetails.password,
        FirestoreConstants.launchCount: 0,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      // Write data to local storage
      User? currentUser = firebaseUser;
      addToLocal(currentUser.uid, currentUser.email, userDetails.username,
          userDetails.photoUrl, userDetails.password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'Email already exist.';
      } else if (e.code == 'network-request-failed')
        throw 'No Internet Connection';
      else {
        throw 'Network error. Try again later';
      }
    } catch (e) {
      throw 'Network error. Try again later';
    }

    return false;
  }

  addToLocal(id, email, username, photoUrl, password) async {
    await prefs.setString(FirestoreConstants.id, id);
    await prefs.setString(FirestoreConstants.username, username ?? "");
    await prefs.setString(FirestoreConstants.password, password);
    await prefs.setString(FirestoreConstants.email, email);
    await prefs.setString(FirestoreConstants.photoUrl, photoUrl ?? '');

    debugLog("Firebase data added to shared pref");
  }

  updateUserProfile(email, imageFile, password, username) async {
    try {
      await firebaseAuth.currentUser?.updatePassword(password);
      // await firebaseAuth.currentUser?.updateEmail(email);

      String imgUrl = '';
      // if it is not null. it means user have selected image, so we first add it in firestore
      if (imageFile != null) {
        imgUrl = await addUserImage(imageFile);
      }

      if (imgUrl.isNotEmpty) {
        await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(prefs.getString(FirestoreConstants.id))
            .update({
          // FirestoreConstants.password: password,
          FirestoreConstants.photoUrl: imgUrl,
          FirestoreConstants.username: username,

          FirestoreConstants.email: email
        });
      } else {
        await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .doc(prefs.getString(FirestoreConstants.id))
            .update({
          // FirestoreConstants.password: password,
          FirestoreConstants.email: email,
          FirestoreConstants.username: username
        });
      }
      await prefs.setString(FirestoreConstants.password, password);
      await prefs.setString(FirestoreConstants.email, email);
      await prefs.setString(FirestoreConstants.username, username);

      if (imgUrl.isNotEmpty) {
        await prefs.setString(FirestoreConstants.photoUrl, imgUrl ?? '');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw "This is sensitive operation. Please login again and retry.";
      } else {
        throw 'Error updating. Please login again and retry.';
      }
    } catch (e) {
      debugLog("Exception updating password: $e");
      throw 'Error updating. Please login again and retry.';
    }
  }

  updatePassword(docId, password, code) async {
    try {
      // firebaseAuth.verifyPasswordResetCode(password);

      await firebaseAuth.verifyPasswordResetCode(code);

      // await firebaseAuth.currentUser?.updatePassword(password);

      // await firebaseFirestore
      //     .collection(FirestoreConstants.pathUserCollection)
      //     .doc(docId)
      //     .update({FirestoreConstants.password: password});

      return true;
    } catch (e) {
      debugLog("Exception updating password: $e");
      throw 'Network error. Try again later';
    }
  }

  Future<UserModel> checkUserExist(email) async {
    try {
      final QuerySnapshot result = await firebaseFirestore
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.email, isEqualTo: email)
          .get();

      await firebaseAuth.sendPasswordResetEmail(email: email);

      debugLog("result: ${result.size}");

      final List<DocumentSnapshot> documents = result.docs;
      debugLog("docs: ${documents}");

      if (documents.isNotEmpty) {
        debugLog("documents[0]: ${documents[0]}");
        DocumentSnapshot documentSnapshot = documents[0];
        UserModel user = UserModel.fromDocument(documentSnapshot);
        debugLog("user: ${user.email}");
        return user;
      } else {
        throw "Email doesn't exist";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw 'No Internet Connection';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password';
      } else if (e.code == 'user-not-found') {
        print('Invalid email');
        throw 'Email does not exist';
      } else {
        throw e.code.toString();
      }
    } catch (e) {
      if (e == "Email doesn't exist") throw "${e.toString()}";
      debugLog("Exception in verifying email: $e");
      throw "Something went wrong. Try again later";
    }
    // Already sign up, just get data from firestore
    // DocumentSnapshot documentSnapshot = documents[0];
    // UserModel user = UserModel.fromDocument(documentSnapshot);
  }

  Future<void> handleSignOut() async {
    print("handle signout called");
    // changeOnlineStatus(false);
    // _status = Status.uninitialized;
    await firebaseAuth.signOut();
    loggedInUser = false;
    await prefs.setString(FirestoreConstants.id, '');
    // await googleSignIn.disconnect();
    // await googleSignIn.signOut();
  }
}
