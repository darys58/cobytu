import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './globals.dart' as globals;

///
/// Preferences related
///
//const String _storageKey = "MyApplication_";
const List<String> _supportedLanguages = [
  'pl',
  'en',
  'cs',
  'de',
  'es',
  'fr',
  'ru',
  'sv',
  'ja',
  'zh'
];
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class GlobalTranslations {
  Locale _locale;
  Map<dynamic, dynamic> _localizedValues;
  VoidCallback _onLocaleChangedCallback;

  /// Zwraca listę obsługiwanych ustawień regionalnych
  Iterable<Locale> supportedLocales() =>
      _supportedLanguages.map<Locale>((lang) => new Locale(lang, ''));

  // Zwraca tłumaczenie, które odpowiada [key]
  String text(String key) {
    // Return the requested string
    return (_localizedValues == null || _localizedValues[key] == null)
        ? '** $key not found'
        : _localizedValues[key];
  }

  // Zwraca bieżący kod języka
  get currentLanguage => _locale == null ? '' : _locale.languageCode;

  //Zwraca bieżące ustawienia regionalne - Locale
  get locale => _locale;

  // Jednorazowa inicjalizacja !!!
  Future<Null> init([String language]) async {
    if (_locale == null) {
      await setNewLanguage(language);
    }
    return null;
  }

  /// ----------------------------------------------------------
  /// Method that saves/restores the preferred language
  /// ----------------------------------------------------------
  getPreferredLanguage() async {
    return _getApplicationSavedInformation('language');
  }

  setPreferredLanguage(String lang) async {
    return _setApplicationSavedInformation('language', lang);
  }

  // Rutynowa zmiana języka
  Future<Null> setNewLanguage(
      [String newLanguage, bool saveInPrefs = true]) async {
    String language = newLanguage;
    print('language w allTranslations.setNewLanguage = $language');
    if (language == null) {
      language = await getPreferredLanguage();
    }

    // Set the locale
    if (language == "") {
      language = "en";
    }
    _locale = Locale(language, "");

    //zapisanie do zmiennej globalnej
    globals.language = language;
    if (language == 'en' || language == 'ja' || language == 'zh') globals.separator = '.';
    else globals.separator = ',';
    
    // Załaduj ciągi językowe
    String jsonContent =
        await rootBundle.loadString("lang/${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);

    // Jeśli zostaniemy poproszeni o zapisanie nowego języka w preferencjach aplikacji
    if (saveInPrefs) {
      await setPreferredLanguage(language);
    }

    // Jeśli istnieje wywołanie zwrotne, które należy wywołać w celu powiadomienia o zmianie języka
    if (_onLocaleChangedCallback != null) {
      _onLocaleChangedCallback();
    }

    return null;
  }

  // Wywołanie zwrotne, które ma zostać wywołane, gdy użytkownik zmieni język
  set onLocaleChangedCallback(VoidCallback callback) {
    _onLocaleChangedCallback = callback;
  }

  ///  Preferences aplikacji (zapisywane w pliku)
  /// ----------------------------------------------------------
  /// Ogólna procedura pobierania preferencji aplikacji
  Future<String> _getApplicationSavedInformation(String name) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getString(name) ?? '';
  }

  /// Ogólna procedura zapisywania preferencji aplikacji
  /// ----------------------------------------------------------
  Future<bool> _setApplicationSavedInformation(
      String name, String value) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString(name, value);
  }

  ///
  /// Singleton Factory
  ///
  static final GlobalTranslations _translations =
      new GlobalTranslations._internal();
  factory GlobalTranslations() {
    return _translations;
  }
  GlobalTranslations._internal();
}

GlobalTranslations allTranslations = new GlobalTranslations();
