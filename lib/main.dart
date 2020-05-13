import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //zarejestrowanie dostawcy
import 'package:flutter_localizations/flutter_localizations.dart';

import './screens/tabs_screen.dart';
import './screens/detail_meal_screen.dart';
import './screens/favorites_screen.dart';
import './screens/tabs_detail_screen.dart';
import './models/rests.dart'; //zaimportowanie klasy dostawcy
import './models/meals.dart'; //zaimportowanie klasy dostawcy
import './models/podkat.dart'; //zaimportowanie klasy dostawcy
import 'screens/languages.dart';
//import 'application.dart';
import 'all_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized ();
    // Initializes the translation module
    await allTranslations.init();
    // then start the application
    return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

   @override
    void initState(){
        super.initState();

        // Inicjuje wywołanie, jeśli coś będzie potrzebne do zrobienia po zmianie języka
        allTranslations.onLocaleChangedCallback = _onLocaleChanged;
    }
    // Jeśli jest coś specjalnego do zrobienia, gdy użytkownik zmieni język
    _onLocaleChanged() async {
        // rób wszystko, co musisz zrobić, jeśli język się zmieni
        print('Language has been changed to: ${allTranslations.currentLanguage}');
    }



  // główna konstrukcja aplikacji
  @override
  Widget build(BuildContext context) { 
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value( //zarejestrowanie dostawcy danych (bez kontekstu)
          value: Meals(), //dla Meals
        ),
        ChangeNotifierProvider.value( //zarejestrowanie dostawcy danych (bez kontekstu)
          value: Rests(), //dla Rests
        ),
        ChangeNotifierProvider.value( //zarejestrowanie dostawcy danych (bez kontekstu)
          value: Podkategorie(), //dla Podkatergorie
        ),
      ],
       child: MaterialApp(
        //title: 'DeliMeals', //tytuł ekranu na pasku u góry ekranu ???
        
        theme: ThemeData( //definiowanie danych decydujących o wyglądzie (kolory, style, czcionki)
          primaryColor: Color.fromRGBO(195, 79, 87, 1), //kolor podstawowy
          primaryColorLight: Color.fromRGBO(255, 118, 122, 1),
          primaryColorDark: Color.fromRGBO(160, 0, 38, 1),
          accentColor: Color.fromRGBO(0, 0, 0, 1), //kolor wyrózniający
          canvasColor: Color.fromRGBO(255, 255, 255, 1), //kolor płótna 255, 254, 229, 1
          fontFamily: 'Raleway', //domyślna czcionka
          textTheme: ThemeData.light().textTheme.copyWith( //domyślny motyw tektu
            body1: TextStyle(
              color: Color.fromRGBO(20, 51, 51, 1),
            ),
            body2: TextStyle(
              color: Color.fromRGBO(20, 51, 51, 1),
            ),
            title: TextStyle(
              fontSize: 20,
              fontFamily: 'RobotoCondensed',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
            ],
        // Tells the system which are the supported languages
        supportedLocales: allTranslations.supportedLocales(),


     /*   
        supportedLocales:[
          Locale('en','US'),
          Locale('pl','PL'),
        ],
        localizationsDelegates: [
         // _localeOverrideDelegate,
          AppLocalizations.delegate, //ładowanie tłumaczeń z plików JSON
          GlobalMaterialLocalizations.delegate, //tłumaczenia tekstów podstawowych
          GlobalWidgetsLocalizations.delegate, //kierunek tekstów
        ],
        //supportedLocales: applic.supportedLocales(),
        
        localeResolutionCallback: (locale, supportedLocales){ //wybór locale które ma uzyć appka
          for (var supportedLocale in supportedLocales){
            if(supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode){
              return supportedLocale;
            }
          }
          return supportedLocales.first; //jezeli urządzenie nie wspiera locale to wybiez pierwszy z listy
        },

        */
        //home: CategoriesScreen(), //MyHomePage(), //ekran startowy apki
        initialRoute: '/', //default is '/'  - dodatkowe określenie domyśnej trasy (inicjującej aplikację)
        routes: { //tabela tras (kurs 161)
          //rejestrowanie trasy/drogi do poszczególnych ekranów
          '/': (ctx) => TabsScreen(),  //zastępuje home: (kurs 162)
          DetailMealScreen.routeName: (ctx) => DetailMealScreen(),
          FavoritesScreen.routeName: (ctx) => FavoritesScreen(),
          TabsDetailScreen.routeName: (ctx) => TabsDetailScreen(),
          LanguagesScreen.routeName: (ctx) => LanguagesScreen(),
          //FiltersScreen.routeName: (ctx) => FiltersScreen(_filters, _setFilters),
        },
        //onGenerateRoute:  - (kure 168) - jezeli brak zdefiniowanej trasy, wyświetla argumenty, dynamiczne trasy
        onUnknownRoute: (settings) {//trasa awaryjna jezeli zawiodą wszystkie inne
          return MaterialPageRoute(
            builder: (ctx) => TabsScreen(),
          );
        },
      ),
    );
  }
}
