import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mood_maker_kp/src/helpers/helpers.dart';

class UserModel {
  String? id;
  String photoUrl;
  String username;
  String email;

  // String? pushToken;
  String? password;

  UserModel({
    this.id,
    required this.photoUrl,
    this.password,
    required this.email,
    // this.pushToken,
    required this.username,
    // required this.aboutMe,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.username: username ?? '',
      FirestoreConstants.photoUrl: photoUrl ?? '',
      FirestoreConstants.email: email ?? '',
      FirestoreConstants.password: password ?? '',
    };
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    // String aboutMe = "";
    String photoUrl = "";
    debugLog("doc.get(FirestoreConstants.occupation) : ${doc.data()}");
    String username = "";
    String email = "";
    // String password = "";
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
      username = doc.get(FirestoreConstants.username);
      email = doc.get(FirestoreConstants.email);
      // password = doc.get(FirestoreConstants.password);
    } catch (e) {
      throw Exception('Error transfering data in chat model');
    }

    return UserModel(
      id: doc.id,
      photoUrl: photoUrl,
      username: username,
      email: email,
      // password: password,
    );
  }
}
