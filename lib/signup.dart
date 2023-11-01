import 'package:doctro/api/Retrofit_Api.dart';
import 'package:doctro/api/network_api.dart';
import 'package:doctro/localization/preference.dart';
import 'package:doctro/core/signing%20in%20manager/google_sign_in.dart';
import 'package:doctro/phoneverification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Bookappointment.dart';
import 'api/base_model.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/app_string.dart';
import 'const/prefConstatnt.dart';
import 'localization/localization_constant.dart';
import 'model/login.dart';
import 'model/register.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _phoneCode = TextEditingController();
  // TextEditingController _dob = TextEditingController();
  TextEditingController _password = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  bool _isHidden = true;

  DateTime? _selectedDate;
  List<String> gender = [];
  String? _selectGender = "ذكر";
  int? id;
  int? verify;

  String newDateApiPass = "";
  var temp;

  @override
  void initState() {
    // TODO: implement initState
    _phoneCode.text = "+2";
    super.initState();
    Future.delayed(Duration.zero, () {
      gender = [
        getTranslated(context, signUp_male).toString(),
        getTranslated(context, signUp_female).toString()
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(width, height * 0.05),
        child: SafeArea(
          child: Container(
            alignment: AlignmentDirectional.topStart,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(Icons.arrow_back_ios),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Center(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                // Container(
                //   margin: EdgeInsets.only(
                //       top: size.height * 0.04,
                //       left: width * 0.073,
                //       right: width * 0.073),
                //   child: Text(
                //     getTranslated(context, signUp_title).toString(),
                //     style: TextStyle(
                //         fontSize: width * 0.07,
                //         fontWeight: FontWeight.bold,
                //         color: Palette.dark_blue),
                //   ),
                // ),
                // Container(
                //   margin: EdgeInsets.only(
                //       left: width * 0.020,
                //       right: width * 0.020,
                //       top: size.height * 0.027),
                //   child: Column(
                //     children: [
                //       Container(
                //         margin: EdgeInsets.only(
                //             top: size.height * 0.01,
                //             left: width * 0.05,
                //             right: width * 0.05),
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                //         decoration: BoxDecoration(
                //             color: Palette.dark_white,
                //             borderRadius: BorderRadius.circular(10)),
                //         child: TextFormField(
                //           controller: _name,
                //           keyboardType: TextInputType.text,
                //           // inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))],
                //           textCapitalization: TextCapitalization.words,
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Palette.dark_blue,
                //           ),
                //           decoration: InputDecoration(
                //             border: InputBorder.none,
                //             hintText:
                //                 getTranslated(context, signUp_userName_hint)
                //                     .toString(),
                //             hintStyle: TextStyle(
                //               fontSize: width * 0.04,
                //               color: Palette.dark_grey,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //           validator: (String? value) {
                //             value!.trim();
                //             if (value.isEmpty) {
                //               return getTranslated(
                //                       context, signUp_userName_validator1)
                //                   .toString();
                //             } else if (value.trim().length < 1) {
                //               return getTranslated(
                //                       context, signUp_userName_validator2)
                //                   .toString();
                //             }
                //             return null;
                //           },
                //           onSaved: (String? name) {},
                //         ),
                //       ),
                //
                //       Container(
                //         margin: EdgeInsets.only(
                //             top: size.height * 0.01,
                //             left: width * 0.05,
                //             right: width * 0.05),
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                //         decoration: BoxDecoration(
                //             color: Palette.dark_white,
                //             borderRadius: BorderRadius.circular(10)),
                //         child: TextFormField(
                //           controller: _email,
                //           keyboardType: TextInputType.text,
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Palette.dark_blue,
                //           ),
                //           decoration: InputDecoration(
                //             border: InputBorder.none,
                //             hintText:
                //                 getTranslated(context, signUp_email_hint)
                //                     .toString(),
                //             hintStyle: TextStyle(
                //                 fontSize: width * 0.04,
                //                 color: Palette.dark_grey,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //           // validator: (String? value) {
                //           //   if (value!.isEmpty) {
                //           //     return getTranslated(
                //           //             context, signUp_email_validator1)
                //           //         .toString();
                //           //   }
                //           //   if (!RegExp(
                //           //           r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                //           //       .hasMatch(value)) {
                //           //     return getTranslated(
                //           //             context, signUp_email_validator1)
                //           //         .toString();
                //           //   }
                //           //   return null;
                //           // },
                //           onSaved: (String? name) {},
                //         ),
                //       ),
                //
                //       Container(
                //         child: Container(
                //           width: width * 0.9,
                //           margin: EdgeInsets.only(
                //             top: size.height * 0.01,
                //             left: width * 0.05,
                //             right: width * 0.05,
                //           ),
                //           padding: EdgeInsets.symmetric(
                //               horizontal: 15, vertical: 2),
                //           decoration: BoxDecoration(
                //               color: Palette.dark_white,
                //               borderRadius: BorderRadius.circular(10)),
                //           child: TextFormField(
                //             controller: _phone,
                //             keyboardType: TextInputType.number,
                //             inputFormatters: [
                //               FilteringTextInputFormatter.allow(
                //                   RegExp('[0-9]')),
                //               LengthLimitingTextInputFormatter(11)
                //             ],
                //             style: TextStyle(
                //               fontSize: 16,
                //               color: Palette.dark_blue,
                //             ),
                //             decoration: InputDecoration(
                //               border: InputBorder.none,
                //               hintText:
                //                   getTranslated(context, signUp_phoneNo_hint)
                //                       .toString(),
                //               hintStyle: TextStyle(
                //                 fontSize: width * 0.04,
                //                 color: Palette.dark_grey,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //             validator: (String? value) {
                //               String patttern = r'(01)(0|1|2|5)[0-9]{8}';
                //               RegExp regExp = new RegExp(patttern);
                //               if (value!.length == 0 || value.length > 11) {
                //                 return getTranslated(context,
                //                         bookAppointment_phoneNo_Validator1)
                //                     .toString();
                //               } else if (!regExp.hasMatch(value)) {
                //                 return getTranslated(context,
                //                         bookAppointment_phoneNo_Validator2)
                //                     .toString();
                //               }
                //               return null;
                //             },
                //             onSaved: (String? name) {},
                //           ),
                //         ),
                //       ),
                //       Container(
                //         margin: EdgeInsets.only(
                //             top: size.height * 0.01,
                //             left: width * 0.05,
                //             right: width * 0.05),
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                //         decoration: BoxDecoration(
                //             color: Palette.dark_white,
                //             borderRadius: BorderRadius.circular(10)),
                //         child: TextFormField(
                //           readOnly: true,
                //           textCapitalization: TextCapitalization.words,
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Palette.dark_blue,
                //           ),
                //           // controller: _dob,
                //           decoration: InputDecoration(
                //             hintText:
                //                 getTranslated(context, signUp_birthDate_hint)
                //                     .toString(),
                //             border: InputBorder.none,
                //             hintStyle: TextStyle(
                //                 fontSize: width * 0.04,
                //                 color: Palette.dark_grey,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //           validator: (String? value) {
                //             if (value!.isEmpty) {
                //               return getTranslated(
                //                       context, signUp_birthDate_validator1)
                //                   .toString();
                //             }
                //             return null;
                //           },
                //           onTap: () {
                //             _selectDate(context);
                //           },
                //         ),
                //       ),

                      // Container(
                      //   margin: EdgeInsets.only(
                      //       top: size.height * 0.01,
                      //       left: width * 0.05,
                      //       right: width * 0.05),
                      //   padding:
                      //       EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                      //   decoration: BoxDecoration(
                      //       color: Palette.dark_white,
                      //       borderRadius: BorderRadius.circular(10)),
                      //   child: DropdownButtonFormField(
                      //     style: TextStyle(
                      //       fontSize: 16,
                      //       color: Palette.dark_blue,
                      //     ),
                      //     decoration: InputDecoration(
                      //       border: InputBorder.none,
                      //       hintText: getTranslated(
                      //               context, signUp_selectGender_hint)
                      //           .toString(),
                      //       hintStyle: TextStyle(
                      //           fontSize: width * 0.04,
                      //           color: Palette.dark_grey,
                      //           fontWeight: FontWeight.bold),
                      //     ),
                      //     value: _selectGender,
                      //     isExpanded: true,
                      //     iconSize: 25,
                      //     onSaved: (dynamic value) {
                      //       setState(
                      //         () {
                      //           _selectGender = value;
                      //         },
                      //       );
                      //     },
                      //     onChanged: (dynamic newValue) {
                      //       setState(
                      //         () {
                      //           _selectGender = newValue;
                      //         },
                      //       );
                      //     },
                      //     validator: (dynamic value) => value == null
                      //         ? getTranslated(
                      //                 context, signUp_selectGender_validator)
                      //             .toString()
                      //         : null,
                      //     items: gender.map(
                      //       (location) {
                      //         return DropdownMenuItem<String>(
                      //           child: new Text(
                      //             location,
                      //             style: TextStyle(
                      //               fontSize: width * 0.04,
                      //               color: Palette.dark_blue,
                      //             ),
                      //           ),
                      //           value: location,
                      //         );
                      //       },
                      //     ).toList(),
                      //   ),
                      // ),
                //
                //       Container(
                //         margin: EdgeInsets.only(
                //             top: size.height * 0.01,
                //             left: width * 0.05,
                //             right: width * 0.05),
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                //         decoration: BoxDecoration(
                //             color: Palette.dark_white,
                //             borderRadius: BorderRadius.circular(10)),
                //         child: TextFormField(
                //           controller: _password,
                //           keyboardType: TextInputType.text,
                //           inputFormatters: [
                //             FilteringTextInputFormatter.allow(
                //                 RegExp('[a-zA-Z0-9]'))
                //           ],
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Palette.dark_blue,
                //           ),
                //           decoration: InputDecoration(
                //             border: InputBorder.none,
                //             hintText:
                //                 getTranslated(context, signUp_password_hint)
                //                     .toString(),
                //             hintStyle: TextStyle(
                //               fontSize: width * 0.04,
                //               color: Palette.dark_grey,
                //               fontWeight: FontWeight.bold,
                //             ),
                //             suffixIcon: IconButton(
                //               icon: Icon(
                //                 _isHidden
                //                     ? Icons.visibility
                //                     : Icons.visibility_off,
                //                 color: Palette.grey,
                //               ),
                //               onPressed: () {
                //                 setState(() {
                //                   _isHidden = !_isHidden;
                //                 });
                //               },
                //             ),
                //           ),
                //           obscureText: _isHidden,
                //           validator: (String? value) {
                //             if (value!.isEmpty) {
                //               return getTranslated(
                //                       context, signUp_password_validator1)
                //                   .toString();
                //             }
                //             if (value.length < 6) {
                //               return getTranslated(
                //                       context, signUp_password_validator2)
                //                   .toString();
                //             }
                //             return null;
                //           },
                //           onSaved: (String? name) {},
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                //
                // Container(
                //   width: width * 1,
                //   height: 40,
                //   margin: EdgeInsets.all(20),
                //   padding: EdgeInsets.symmetric(
                //       horizontal: width * 0.04, vertical: 2),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: ElevatedButton(
                //     child: Text(
                //       getTranslated(context, signUp_signUp_button).toString(),
                //       style: TextStyle(fontSize: width * 0.045),
                //       textAlign: TextAlign.center,
                //     ),
                //     onPressed: () async {
                //       BaseModel<bool> hasSignedUp = await callApiRegister()
                //         ..boolian;
                //       if (_formkey.currentState!.validate()) {
                //         BaseModel<bool> hasSignedUp = await callApiRegister()
                //           ..boolian;
                //         if (hasSignedUp.boolian!) {
                //           callForLogin();
                //         }
                //       } else {
                //         print("Unsuccessful");
                //       }
                //     },
                //   ),
                // ),
                SizedBox(
                  width: width,
                  height: height * 0.6,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /* Consumer<GoogleSignInProvider>(
                            builder: (context, googleProvider, child) =>
                                ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  minimumSize:
                                      Size(width * 0.8, height * 0.08)),
                              onPressed: () async {
                                var user = await FaceBookSignInProvider
                                    .facebookLogin();
                                if (user != null) {
                                  _email.text = user.email;
                                  _name.text = user.name;
                                  BaseModel<bool> hasSignedUp =
                                      await callApiRegister()
                                        ..boolian;

                                  if (hasSignedUp.boolian!) {
                                    callForLogin();
                                  }
                                } else {
                                  print("Unsuccessful");
                                }
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.facebook,
                                color: Colors.blue,
                              ),
                              label: FittedBox(
                                child: Text(
                                  getTranslated(context, signUp_with_facebook)
                                      .toString(),
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.1,
                          ), */
                          Consumer<GoogleSignInProvider>(
                            builder: (context, googleProvider, child) =>
                                ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                  minimumSize:
                                      Size(width * 0.8, height * 0.08)),
                              onPressed: () async {
                                GoogleSignInAccount? googleUser =
                                    await googleProvider.googleLogin();
                                if (googleUser != null) {
                                  _email.text = googleUser.email;
                                  _name.text = googleUser.displayName ??
                                      googleUser.email;
                                  BaseModel<bool> hasSignedUp =
                                      await callApiRegister()
                                        ..boolian;

                                  if (hasSignedUp.boolian!) {
                                    callForLogin();
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
                                        signUp_with_google)
                                        .toString(),

                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  child: Text(
                    getTranslated(context, signUp_text).toString(),
                    style: TextStyle(
                        fontSize: width * 0.03, color: Palette.dark_blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.040),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            getTranslated(context, signUp_alreadyAccount)
                                .toString(),
                            style: TextStyle(
                                fontSize: width * 0.035,
                                color: Palette.dark_blue),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: width * 0.009),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, 'SignIn');
                              },
                              child: Text(
                                getTranslated(context, signUp_signIn_button)
                                    .toString(),
                                style: TextStyle(
                                    color: Palette.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.035),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<BaseModel<bool>> callApiRegister() async {
    Register response;
    newDateApiPass = DateUtilforpass().formattedDate(DateTime.now());
    Map<String, dynamic> body = {
      "name": _name.text,
      "email": _email.text,
      // "phone": _phone.text,
      //phone number isn't used now but we take the user phone number on each reservation.
      "phone": " 00000000000",
      "dob": newDateApiPass,
      // "dob": "",
      "gender": _selectGender,
      // "password": _password.text,
      "password": 'NOPASSWORD',
      "phone_code": _phoneCode.text,
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
  final _dob = TextEditingController();
  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Palette.blue,
              onPrimary: Palette.white,
              surface: Palette.blue,
              onSurface: Palette.light_black,
            ),
            dialogBackgroundColor: Palette.white,
          ),
          child: child!,
        );
      },
    );
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _dob
        ..text = DateFormat('dd-MM-yyyy').format(_selectedDate!)
        ..selection = TextSelection.fromPosition(
          TextPosition(
              offset: _dob.text.length, affinity: TextAffinity.upstream),
        );
    }
  }

  Future<BaseModel<bool>> callForLogin() async {
    Login response;
    Map<String, dynamic> body = {
      "email": _email.text.toString(),
      "password": "NOPASSWORD",
      // "password": _password.text.toString(),
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

          verify = response.data!.verify;
          id = response.data!.id;

          verify != 0
              ? Navigator.pushReplacementNamed(context, "Home")
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneVerification(id: id),
                  ),
                );
          // msg = response.msg;
          _email.clear();
          _password.clear();
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
      }
    } catch (error, stacktrace) {
      print("Exception occur: $error stackTrace: $stacktrace");
      BaseModel()..setException(ServerError.withError(error: error));
      return BaseModel()..boolian = false;
    }
    BaseModel()..data = response;
    return BaseModel()..boolian = true;
  }
}
