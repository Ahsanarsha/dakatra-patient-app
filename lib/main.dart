import 'dart:developer';

import 'package:doctro/AddLocation.dart';
import 'package:doctro/Addtocart.dart';
import 'package:doctro/AllPharamacy.dart';
import 'package:doctro/Book_success.dart';
import 'package:doctro/Bookappointment.dart';
import 'package:doctro/Favoritedoctor.dart';
import 'package:doctro/HealthTips.dart';
import 'package:doctro/HealthTipsDetail.dart';
import 'package:doctro/Home.dart';
import 'package:doctro/MedicineDescription.dart';
import 'package:doctro/Offer.dart';
import 'package:doctro/PharamacyDetail.dart';
import 'package:doctro/Review_Appointment.dart';
import 'package:doctro/Setting.dart';
import 'package:doctro/SignIn.dart';
import 'package:doctro/Specialist.dart';
import 'package:doctro/Treatment.dart';
import 'package:doctro/TreatmentSpecialist.dart';
import 'package:doctro/firebase_options.dart';
import 'package:doctro/localization/preference.dart';
import 'package:doctro/core/signing%20in%20manager/google_sign_in.dart';
import 'package:doctro/doctordetail.dart';
import 'package:doctro/forgotpassword.dart';
import 'package:doctro/Showlocation.dart';
import 'package:doctro/phoneverification.dart';
import 'package:doctro/profile.dart';
import 'package:doctro/signup.dart';
import 'package:doctro/Myprescription.dart';
import 'package:doctro/Appointment.dart';
import 'package:doctro/ChangeLanguage.dart';
import 'package:doctro/videocallhistory.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doctro/ChangePassword.dart';
import 'package:doctro/MedicineOrder.dart';
import 'package:doctro/MedicineOrderDetail.dart';
import 'package:doctro/MedicinePayment.dart';
import 'package:doctro/StripePaymentScreen.dart';
import 'package:doctro/StripePaymentScreenMedicine.dart';
import 'package:doctro/notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';


// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'AboutUs.dart';
import 'PrivacyPolicy.dart';
import 'VideoCall/overlay_handler.dart';
import 'api/Retrofit_Api.dart';
import 'api/base_model.dart';
import 'api/network_api.dart';
import 'api/server_error.dart';
import 'const/Palette.dart';
import 'const/prefConstatnt.dart';
import 'localization/language_localization.dart';
import 'localization/localization_constant.dart';
import 'model/DetailSetting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform).then((value) => setFcmToken());
  await MySharedPreferenceHelper.init();

  await checkForUpdate().then((value) {
    runApp(
      MyApp(),
    );
  });
}
setFcmToken()async{
  FirebaseMessaging _firebaseMessaging = await FirebaseMessaging.instance;
  log('this is fcm token');
  try{

    _firebaseMessaging.getToken().then((value) async {
      log('this is fcm token $value');
    });
  }catch(e){
    log('this is fcm token gettt $e');
  }

}
//flexible update
checkForUpdate() async {
  InAppUpdate.checkForUpdate().then((info) {
    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.startFlexibleUpdate().catchError((e) {});
    }
  }).catchError((e) {});
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  String? deviceToken = "";

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    // getPermission();
    callApiSetting();
  }

  @override
  void didChangeDependencies() {
    getLocale().then((local) => {
          setState(() {
            this._locale = local;
          })
        });
    super.didChangeDependencies();
  }

  /* getPermission() async {
    if (await Permission.location.isRestricted) {
      Permission.location.request();
      if (await Permission.location.isRestricted ||
          await Permission.location.isDenied) {
        Permission.location.request();
      }
    }
    if (await Permission.storage.isDenied) {
      Permission.storage.request();
      if (await Permission.storage.isDenied ||
          await Permission.storage.isDenied) {
        Permission.storage.request();
      }
    }
  }
 */

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    if (_locale == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return ChangeNotifierProvider<OverlayHandlerProvider>(
        create: (_) => OverlayHandlerProvider(),
        child: ChangeNotifierProvider(
          create: (context) => GoogleSignInProvider(),
          child: MaterialApp(
            title: 'Dakatra',
            locale: _locale,
            supportedLocales: [
              Locale(ARABIC, 'AE'),
              Locale(ENGLISH, 'US'),
              Locale(SPANISH, 'ES'),

            ],
            localizationsDelegates: [
              LanguageLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (deviceLocal, supportedLocales) {
              for (var local in supportedLocales) {
                if (local.languageCode == deviceLocal!.languageCode &&
                    local.countryCode == deviceLocal.countryCode) {
                  return deviceLocal;
                }
              }
              return supportedLocales.last;
            },

            debugShowCheckedModeBanner: false,
            // home: Home(),
            initialRoute: "/",
            theme: ThemeData(
              splashColor: Palette.transparent,
              highlightColor: Palette.transparent,
            ),
            routes: {
              '/': (context) => Home(),
              'SignIn': (context) => SignIn(),
              'SignUp': (context) => SignUp(),
              'ForgotPasswordScreen': (context) => ForgotPasswordScreen(),
              'PhoneVerification': (context) => PhoneVerification(),
              'Home': (context) => Home(),
              'Treatment': (context) => Treatment(),
              'FavoriteDoctorScreen': (context) => FavoriteDoctorScreen(),
              'Specialist': (context) => Specialist(),
              'DoctorDetail': (context) => DoctorDetail(),
              'BookAppointment': (context) => BookAppointment(),
              'Appointment': (context) => Appointment(),
              'Myprescription': (context) => Myprescription(),
              'HealthTips': (context) => HealthTips(),
              'HealthTipsDetail': (context) => HealthTipsDetail(),
              'Setting': (context) => Setting(),
              'AddToCart': (context) => AddToCart(),
              'Offer': (context) => Offer(),
              'Profile': (context) => Profile(),
              'ShowLocation': (context) => ShowLocation(),
              'AddLocation': (context) => AddLocation(),
              'BookSuccess': (context) => BookSuccess(),
              'Review': (context) => Review(),
              'MedicineDescription': (context) => MedicineDescription(),
              'AllPharamacy': (context) => AllPharamacy(),
              'PharamacyDetail': (context) => PharamacyDetail(),
              'MedicinePayment': (context) => MedicinePayment(),
              'MedicineOrder': (context) => MedicineOrder(),
              'MedicineOrderDetail': (context) => MedicineOrderDetail(),
              'TreatmentSpecialist': (context) => TreatmentSpecialist(),
              'Notifications': (context) => Notifications(),
              'StripePaymentScreen': (context) => StripePaymentScreen(),
              'StripePaymentScreenMedicine': (context) =>
                  StripePaymentScreenMedicine(),
              'ChangePassword': (context) => ChangePassword(),
              'PrivacyPolicy': (context) => PrivacyPolicy(),
              'AboutUs': (context) => AboutUs(),
              'ChangeLanguage': (context) => ChangeLanguage(),
              'VideoCallHistory': (context) => VideoCallHistory(),
            },
          ),
        ),
      );
    }
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
    // OneSignal.shared.promptLocationPermission();
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
