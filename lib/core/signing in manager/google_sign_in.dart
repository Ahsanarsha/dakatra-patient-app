import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future<GoogleSignInAccount?> googleLogin() async {
    try {
      log('Google sign up started 1');
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        // serverClientId: '108088647271-psjicvpo9cunh5num8ihnon11k6tg6ke.apps.googleusercontent.com'
        ).signIn();
      print("googleUser!.displayName "+googleUser!.displayName.toString());
      // Obtain the auth details from the request
      log('Google sign up started 2');
      final GoogleSignInAuthentication? googleAuth =
      await googleUser.authentication;
      log('Google sign up started 3');
      // Create a new credential

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      log('Google sign up started 4');
      log( googleAuth!.accessToken.toString());
      var result = await FirebaseAuth.instance.signInWithCredential(credential);
      log('Google sign up started 5');
      if (result.user == null) return null;
      _user = googleUser;

      print(user.email);
      // final googleAuth = await googleUser.authentication;
      // print(user.displayName);
      // final credential = GoogleAuthProvider.credential(
      //     accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      // await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();
      return googleUser;
    } on Exception catch (e) {
      print('Google sign up exception detected');
      print(e.toString());
    }
  }

  Future logout() async {
    try {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      FirebaseAuth.instance.signOut();
    } on Exception catch (e) {}
  }
}
