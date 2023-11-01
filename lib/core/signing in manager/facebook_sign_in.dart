import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FaceBookSignInProvider extends ChangeNotifier {
  static Future<UserModel?> facebookLogin() async {
    try {
      final facebookLoginResult = await FacebookAuth.instance.login();
      final userData = await FacebookAuth.instance.getUserData();
      print(userData.entries);
      return UserModel(userData["name"], userData["email"]);
    } on Exception catch (e) {
      return null;
    }
  }
}

class UserModel {
  late final String name;
  late final String email;
  UserModel(this.name, this.email);
}
