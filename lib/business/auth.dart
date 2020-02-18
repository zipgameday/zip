import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zip/models/user.dart';
import 'package:flutter/services.dart';

enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

class AuthService {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  Future<FirebaseUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      updateUserData(user);

      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    updateUserActivity(result.user.uid);
    return result.user.uid;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _auth.signOut();
  }

  void addUser(User user) async {
    checkUserExist(user.uid).then((value) {
      if (!value) {
        print("user ${user.firstName} ${user.email} added");
        Firestore.instance
            .document("users/${user.uid}")
            .setData(user.toJson());
      } else {
        print("user ${user.firstName} ${user.email} exists");
      }
    });
  }

  void updateUserActivity(String uid) {
    DocumentReference userRef = _db.collection('users').document(uid);
    userRef.setData({
      'lastActivity': DateTime.now(),
    }, merge: true);
  }

  Future<void> updateUserData(FirebaseUser user) async {
    DocumentReference userRef = _db.collection('users').document(user.uid);

    checkUserExist(user.uid).then((value) {
      if (!value) {
        return userRef.setData({
          'uid': user.uid,
          'lastActivity': DateTime.now(),
          'email': user.email,
          'firstName': (user.displayName.contains(" ")) ? user.displayName.substring(0, user.displayName.indexOf(' ')) : user.displayName,
          'lastName': (user.displayName.contains(" ")) ? user.displayName.substring(user.displayName.indexOf(' ') + 1, user.displayName.length) : '',
          'phone': user.phoneNumber,
          'profilePictureURL' : user.photoUrl
        }, merge: true);
      } else {
        return userRef.setData({
          'lastActivity': DateTime.now(),
        }, merge: true);
      }
    });
  }

  Future<bool> checkUserExist(String userID) async {
    bool exists = false;
    try {
      await _db.document("users/$userID").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }

  Stream<User> getUser(String userID) {
    return _db
        .collection("users")
        .where("userID", isEqualTo: userID)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.documents.map((doc) {
        return User.fromDocument(doc);
      }).first;
    });
  }

  String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'User with this e-mail not found.';
          break;
        case 'The password is invalid or the user does not have a password.':
          return 'Invalid password.';
          break;
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'No internet connection.';
          break;
        case 'The email address is already in use by another account.':
          return 'Email address is already taken.';
          break;
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }
}
