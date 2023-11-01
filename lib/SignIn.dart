import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/model/login.dart';
import 'package:doctro/phoneverification.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:doctro/const/prefConstatnt.dart';
import 'package:doctro/localization/preference.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Bookappointment.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'core/signing in manager/google_sign_in.dart';
import 'localization/localization_constant.dart';
import 'model/DetailSetting.dart';
import 'model/register.dart';

TextEditingController _name = TextEditingController();

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool _isHidden = true;

  String? msg = "";
  String? deviceToken = "";

  int? verify = 0;
  int? id = 0;

  @override
  void initState() {
    super.initState();
    getLocation();
    callApiSetting();
  }

  late LocationData _locationData;
  Location location = new Location();

  Future<void> getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _locationData = await location.getLocation();

    prefs.setString('lat', _locationData.latitude.toString());
    prefs.setString('lang', _locationData.longitude.toString());
  }

  @override
  Widget build(BuildContext context) {
    double width;
    width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: size.height * 1,
                  width: width * 1,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/images/confident-doctor-half.png",
                        height: size.height * 0.5,
                        width: width * 1,
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: size.height * 0.35,
                        child: Container(
                          width: width * 1,
                          height: size.height * 0.65,
                          decoration: BoxDecoration(
                            color: Palette.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(width * 0.1),
                              topRight: Radius.circular(width * 0.1),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: width * 0.08),
                                  child: Column(
                                    children: [
                                      Text(
                                        getTranslated(context, signIn_welcome)
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: width * 0.1,
                                            fontWeight: FontWeight.bold,
                                            color: Palette.light_black),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        getTranslated(context, signIn_title)
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: width * 0.04,
                                            color: Palette.dark_grey1),
                                      )
                                    ],
                                  ),
                                ),
                                // Container(
                                //   margin: EdgeInsets.only(
                                //       top: width * 0.1,
                                //       left: width * 0.07,
                                //       right: width * 0.07),
                                //   padding: EdgeInsets.symmetric(
                                //       horizontal: 15, vertical: 2),
                                //   decoration: BoxDecoration(
                                //       color: Palette.dark_white,
                                //       borderRadius: BorderRadius.circular(10)),
                                //   child: TextFormField(
                                //     controller: email,
                                //     keyboardType: TextInputType.text,
                                //     decoration: InputDecoration(
                                //       border: InputBorder.none,
                                //       hintText: getTranslated(
                                //               context, signIn_email_hint)
                                //           .toString(),
                                //       hintStyle: TextStyle(
                                //           fontSize: width * 0.038,
                                //           color: Palette.dark_blue),
                                //     ),
                                //     validator: (String? value) {
                                //       if (value!.isEmpty) {
                                //         return getTranslated(context,
                                //                 signIn_email_validator1)
                                //             .toString();
                                //       }
                                //       if (!RegExp(
                                //               r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                //           .hasMatch(value)) {
                                //         return getTranslated(context,
                                //                 signIn_email_validator2)
                                //             .toString();
                                //       }
                                //       return null;
                                //     },
                                //     onSaved: (String? name) {},
                                //   ),
                                // ),
                                // Container(
                                //   margin: EdgeInsets.only(
                                //       top: size.height * 0.02,
                                //       left: width * 0.07,
                                //       right: width * 0.07),
                                //   padding: EdgeInsets.symmetric(
                                //       horizontal: 15, vertical: 2),
                                //   decoration: BoxDecoration(
                                //       color: Palette.dark_white,
                                //       borderRadius: BorderRadius.circular(10)),
                                //   child: TextFormField(
                                //     controller: password,
                                //     keyboardType: TextInputType.text,
                                //     decoration: InputDecoration(
                                //       border: InputBorder.none,
                                //       hintText: getTranslated(
                                //               context, signIn_password_hint)
                                //           .toString(),
                                //       hintStyle: TextStyle(
                                //           fontSize: width * 0.038,
                                //           color: Palette.dark_blue),
                                //       suffixIcon: IconButton(
                                //         icon: Icon(
                                //           _isHidden
                                //               ? Icons.visibility
                                //               : Icons.visibility_off,
                                //           color: Palette.grey,
                                //         ),
                                //         onPressed: () {
                                //           setState(() {
                                //             _isHidden = !_isHidden;
                                //           });
                                //         },
                                //       ),
                                //     ),
                                //     obscureText: _isHidden,
                                //     validator: (String? value) {
                                //       if (value!.isEmpty) {
                                //         return getTranslated(context,
                                //                 signIn_password_validator)
                                //             .toString();
                                //       }
                                //       return null;
                                //     },
                                //     onSaved: (String? name) {},
                                //   ),
                                // ),
                                // Container(
                                //   width: width * 1,
                                //   height: 40,
                                //   margin: EdgeInsets.only(
                                //       top: size.height * 0.03,
                                //       left: 20,
                                //       right: 20),
                                //   padding: EdgeInsets.symmetric(
                                //       horizontal: width * 0.04, vertical: 0),
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(10),
                                //   ),
                                //   child: ElevatedButton(
                                //     child: Text(
                                //       getTranslated(
                                //               context, signIn_signIn_button)
                                //           .toString(),
                                //       style: TextStyle(fontSize: width * 0.045),
                                //       textAlign: TextAlign.center,
                                //     ),
                                //     onPressed: () {
                                //       if (formkey.currentState!.validate()) {
                                //         callForLogin();
                                //       } else {
                                //         print('Not Login');
                                //       }
                                //     },
                                //   ),
                                // ),
                                // Container(
                                //   height: size.height * 0.1,
                                //   width: width * 0.85,
                                //   margin: EdgeInsets.only(
                                //     left: width * 0.05,
                                //     right: width * 0.05,
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.stretch,
                                //     children: [
                                //       TextButton(
                                //         child: Text(
                                //           getTranslated(context,
                                //                   signIn_forgotPassword_button)
                                //               .toString(),
                                //           style: TextStyle(
                                //               fontSize: width * 0.042,
                                //               color: Palette.dark_grey),
                                //           textAlign: TextAlign.center,
                                //         ),
                                //         onPressed: () {
                                //           Navigator.pushNamed(
                                //               context, 'ForgotPasswordScreen');
                                //         },
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.only(bottom: 10),
                                //   child: Text(
                                //       getTranslated(context, or).toString()),
                                // ),
                                SizedBox(height: 150,),
                                SizedBox(
                                  width: width,
                                  height: height * 0.1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Column(
                                      children: [

                                        Expanded(
                                          child: Consumer<GoogleSignInProvider>(
                                            builder: (context, googleProvider,
                                                    child) =>
                                                ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.white,
                                                  minimumSize: Size(width * 0.8,
                                                      size.height * 0.08)),
                                              onPressed: () async {
                                                GoogleSignInAccount? googleUser =
                                                    await googleProvider
                                                        .googleLogin();
                                                if (googleUser != null) {
                                                  email.text = googleUser.email;

                                                  BaseModel<bool> hasLoggedIn =
                                                      await callForLogin();

                                                  if (hasLoggedIn.boolian ==
                                                      false) {
                                                    BaseModel<bool>
                                                        hasSignedUp =
                                                        await callApiRegister()
                                                          ..boolian;

                                                    if (hasSignedUp.boolian!) {
                                                      callForLogin();
                                                    }
                                                  }
                                                } else {
                                                  print("Unsuccessful");
                                                }
                                              },
                                              icon: FaIcon(
                                                FontAwesomeIcons.google,
                                                color: Colors.red,
                                              ),
                                              label: FittedBox(
                                                child: Text(
                                                    getTranslated(context,
                                                        signIn_with_google)
                                                        .toString(),
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ),
                                  // Container(
                                  //   margin:
                                  //       EdgeInsets.only(top: size.height * 0.03),
                                  //   alignment: AlignmentDirectional.topStart,
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: [
                                  //       Row(
                                  //         children: [
                                  //           Row(
                                  //             children: [
                                  //               Container(
                                  //                 child: Text(
                                  //                   getTranslated(context,
                                  //                           signIn_notAccount)
                                  //                       .toString(),
                                  //                   style: TextStyle(
                                  //                       fontSize: width * 0.04,
                                  //                       color: Palette.dark_grey),
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       Row(
                                  //         children: [
                                  //           Container(
                                  //             margin: EdgeInsets.only(
                                  //                 left: width * 0.03),
                                  //             child: GestureDetector(
                                  //               onTap: () {
                                  //                 Navigator.pushNamed(
                                  //                     context, 'SignUp');
                                  //               },
                                  //               child: Text(
                                  //                 getTranslated(context,
                                  //                         signIn_signUp_button)
                                  //                     .toString(),
                                  //                 style: TextStyle(
                                  //                     fontSize: width * 0.04,
                                  //                     color: Palette.blue,
                                  //                     fontWeight:
                                  //                         FontWeight.bold),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       )
                                  //     ],
                                  //   ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Text("ssss"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<bool>> callApiRegister() async {
    Register response;
    String _selectGender = "ذكر";
    String newDateApiPass = DateUtilforpass().formattedDate(DateTime.now());
    Map<String, dynamic> body = {
      "name": _name.text,
      "email": email.text,
      // "phone": _phone.text,
      //phone number isn't used now but we take the user phone number on each reservation.
      "phone": " 00000000000",
      "dob": newDateApiPass,
      // "dob": "",
      "gender": _selectGender,
      // "password": "123456",
      "password": "NOPASSWORD",
      "phone_code": "+2",
    };
    try {
      response = await RestClient(RetroApi2().dioData2()).registerRequest(body);
      setState(() {
        id = response.data!.id;
        if (response.data!.verify != 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneVerification(id: id),
            ),
          );
        }

        Fluttertoast.showToast(
          msg: getTranslated(context, signUp_successFully_toast).toString() +
              " " +
              '${response.data!.name}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Palette.blue,
          textColor: Palette.white,
        );
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      BaseModel()..setException(ServerError.withError(error: error));
      return BaseModel()..boolian = false;
    }
    BaseModel()..data = response;
    return BaseModel()..boolian = true;
  }

  Future<BaseModel<bool>> callForLogin() async {
    Login response;
    Map<String, dynamic> body = {
      "email": email.text.toString(),
      "password": "NOPASSWORD",
      "device_token":
          MySharedPreferenceHelper.getString(Preferences.device_token),
    };
    setState(() {
      Preferences.onLoading(context);
    });
    try {
      response = await RestClient(RetroApi2().dioData2()).loginRequest(body);

      if (response.success == true) {
        setState(() {
          Preferences.hideDialog(context);

          verify = int.parse(response.data!.verify.toString());
          id = int.parse(response.data!.id.toString());

          verify != 0
              ? Navigator.pushReplacementNamed(context, "Home")
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneVerification(id: id),
                  ),
                );
          msg = response.msg;
          email.clear();
          password.clear();
          MySharedPreferenceHelper.setBoolean(Preferences.is_logged_in, true);
          MySharedPreferenceHelper.setString(
              Preferences.auth_token, response.data!.token!);

          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });
      } else {
        setState(() {
          Preferences.hideDialog(context);
          Fluttertoast.showToast(
            msg: '${response.msg}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Palette.blue,
            textColor: Palette.white,
          );
        });

        // return BaseModel()..boolian = false;
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..boolian = false;
    }
    BaseModel()..data = response;
    return BaseModel()..boolian = true;
  }

  Future<BaseModel<DetailSetting>> callApiSetting() async {
    DetailSetting response;

    try {
      response = await RestClient(RetroApi2().dioData2()).settingRequest();
      setState(() {
        if (response.success == true) {
          MySharedPreferenceHelper.setString(
              Preferences.patientAppId, response.data!.patientAppId!);

          if (response.data!.patientAppId != null) {
            getOneSingleToken(
                MySharedPreferenceHelper.getString(Preferences.patientAppId));
          }
        }
      });
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      return BaseModel()..setException(ServerError.withError(error: error));
    }
    return BaseModel()..data = response;
  }

  Future<void> getOneSingleToken(appId) async {
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared
        .promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    Future.delayed(const Duration(milliseconds: 5000), () {
      OneSignal.shared.getDeviceState().then((value) {
        if (value!.userId != null) {
          print('token ${value.userId}');
          MySharedPreferenceHelper.setString(
              Preferences.device_token, value.userId!);
        }
      });
    });
    if (MySharedPreferenceHelper.getString(Preferences.device_token) != 'N/A') {
      await Future.delayed(Duration(seconds: 1));
      MySharedPreferenceHelper.getString(Preferences.device_token);
      setState(() {
        deviceToken =
            MySharedPreferenceHelper.getString(Preferences.device_token);
      });
    } else {
      getOneSingleToken(appId);
    }
  }
}
