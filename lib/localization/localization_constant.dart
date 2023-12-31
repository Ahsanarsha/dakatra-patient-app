import 'dart:developer';

import 'package:doctro/const/prefConstatnt.dart';
import 'package:doctro/localization/preference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'language_localization.dart';

String? getTranslated(BuildContext context, String key) {
  return LanguageLocalization.of(context)!.getTranslateValue(key);
}

const String ENGLISH = "en";
const String SPANISH = "es";
const String ARABIC = "ar";

Future<Locale> setLocale(String languageCode) async {
  MySharedPreferenceHelper.setString(
      Preferences.current_language_code, languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case ENGLISH:
      _temp = Locale(languageCode, 'US');
      break;
    case SPANISH:
      _temp = Locale(languageCode, 'ES');
      break;
    case ARABIC:
      _temp = Locale(languageCode, 'AE');
      break;
    default:
      _temp = Locale(ENGLISH, 'US');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  String? languageCode =
  MySharedPreferenceHelper.getString(Preferences.current_language_code);
  if(languageCode == null || languageCode == 'N/A'){
    log('printtings the language code $languageCode');
    languageCode = ARABIC;
    return _locale(languageCode);
  }else{
    log('printtings the language code $languageCode');
    return _locale(languageCode);
  }

}
