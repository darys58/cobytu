//widget pojedynczego elementu listy dań (165)

import 'dart:io';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart'; //pakiet dostawcy
import 'package:connectivity/connectivity.dart'; //czy jest Internet

//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; //obsługa json'a
import 'package:http/http.dart' as http;
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../screens/tabs_detail_screen.dart';
import '../screens/meals_screen.dart';
import '../models/meal.dart';
import '../models/mems.dart';
import '../models/detailRest.dart';
import '../models/rests.dart';
import '../models/mem.dart';
import '../models/meals.dart';
import '../models/podkat.dart';
import '../all_translations.dart';
import '../globals.dart' as globals;

class MealItem extends StatelessWidget {
  final List<DetailRest> _mealRestsData = []; //szczegóły restauracji
  List<Mem> _memLok; //dane wybranej lokalizacji w tabeli memory - baza lokalna
  final String _currLang = allTranslations.currentLanguage; //aktualny język
  bool _internet = false;
  var contextx;
/*
//funkcja przejścia do ekranu ze szczegółami dania
  void selectMeal(BuildContext context) {
    Navigator.of(context).pushNamed(MealDetailScreen.routeName, arguments: id,).then((result) { //result - id usuwanego przepisu (ikoną kosza). Funkca then wykonywana jest po powrocie z opusczanej strony (po wykonaniu pop).
      print(result); 
      if(result != null){
        //removeItem(result); //funkcja usuwania przepisu z listy
      }
   });
  }
*/

  //pobranie (z serwera www) restauracji serwujących wybrane danie - dla szczegółów dania
  Future<List<DetailRest>> fetchDetailRestsFromSerwer(String idDania) async {
    var url =
        'https://cobytu.com/cbt.php?d=f_danie_resta&danie=$idDania&lang=$_currLang';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return [];
      }

      //final List<MealRest> loadedRests = [];
      extractedData.forEach((restId, restData) {
        _mealRestsData.add(DetailRest(
          id: restId,
          logo: restData['re_logo'],
          nazwa: restData['re_nazwa'],
          obiekt: restData['re_obiekt'],
          adres: restData['re_adres'],
          kod: restData['re_kod'],
          miasto: restData['re_miasto'],
          woj: restData['re_woj'],
          tel1: restData['re_tel1'],
          tel2: restData['re_tel2'],
          email: restData['re_email'],
          www: restData['re_www'],
          gps: restData['re_gps'],
          otwarteA: restData['re_otwarte_a'],
          otwarteB: restData['re_otwarte_b'],
          otwarteC: restData['re_otwarte_c'],
          cena: restData['cena'],
          dostawy: restData['re_tel_dos'],
          online: restData['re_online'],
          parking: restData['re_parking'],
          podjazd: restData['re_podjazd'],
          wynos: restData['re_na_wynos'],
          karta: restData['re_p_karta'],
          zabaw: restData['re_s_zabaw'],
          letni: restData['re_o_letni'],
          klima: restData['re_klima'],
          wifi: restData['re_wifi'],
          modMenu: restData['re_mod_menu'],
        ));
      });
      // _items = loadedRests;
      print('dane restauracji w MealRests = ${_mealRestsData[0].nazwa}');
      //notifyListeners();
      return _mealRestsData;
    } catch (error) {
      print('$error - Sieć jest niedostępna !!!!!!!!!!!!!!!!!!!!!!!');
      Scaffold.of(contextx).showSnackBar(snackBar);
      throw (error);
    }
  }

  final snackBar = SnackBar(content: Text('Sieć jest niedostępna'));

  /*
  //ustawienianie zmiennych globalnych
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }
*/
  void _showAlert(BuildContext context, String nazwa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nazwa),
        content: Column(
          //zeby tekst był wyśrodkowany w poziomie
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(allTranslations.text('L_AKTUALIZACJA_MENU')),
          ],
        ),
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      barrierDismissible:
          false, //zeby zaciemnione tło było zablokowane na kliknięcia
    );
  }

  void _showAlertAnuluj(BuildContext context, String nazwa, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nazwa),
        content: Column(
          //zeby tekst był wyśrodkowany w poziomie
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(allTranslations.text('L_ANULUJ')),
          ),
        ],
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      barrierDismissible:
          false, //zeby zaciemnione tło było zablokowane na kliknięcia
    );
  }

  //pobranie memory z bazy lokalnej
  Future<void> fetchMemoryLok() async {
    final data = await DBHelper.getMemory('memLok');
    _memLok = data
        .map(
          (item) => Mem(
            nazwa: item['nazwa'],
            a: item['a'],
            b: item['b'],
            c: item['c'],
            d: item['d'],
            e: item['e'],
            f: item['f'],
          ),
        )
        .toList();
    return _memLok;
  }

  //jak nie ma Internetu to komunikat
  /* _isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _internet = false;
      print('brak Internetu');
      return false;
    } else {
      _internet = true;
      print('jest Internet');
      return true;
    }
  }
*/
/*
  Future<bool> _isInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('result.isNotEmpty  - jest Internet');
        print(result);
        _internet = true;
        return true;
      } else {
        print('brak Internetu');
        _internet = false;
        return false;
      }
    } catch (_) {
      print('brak Internetu');
      _internet = false;
      return false;
    }
  }
*/
  Future<bool> _isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi");
      return true;
    } else {
      print("Unable to connect. Please Check Internet Connection");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = Provider.of<Meal>(context,
        listen:
            false); //dostawca danych dostarcza danie z słuchaczem zmian. Zmiana nastąpi jezeli naciśniemy serce polubienie dania. Z listen: false zmieniony na tylko dostawcę danych a słuchacz lokalny "Consumer" zainstalowany  nizej
    if (_currLang == 'en' || _currLang == 'ja' || _currLang == 'zh')
      globals.separator = '.'; //separator w cenie
    else
      globals.separator = ',';
    print('danie lubi !!!!!!!!!!!!! = ${meal.lubi}');
    return InkWell(
      //element klikalny
      onTap: () {
        //czy jest Internet?
        _isInternet().then((inter) {
          if (inter != null && inter) {
            //pobranie danych restauracji z serwera (potrzebne modMenu - info kiedy była modyfikacja menu)
            //print('pobranie danych restauracji z serwera');
            contextx = context;
            fetchDetailRestsFromSerwer(meal.id).then((_) {
              //print('pobranie mod_menu = ${_mealRestsData[0].modMenu}');
              //pobranie danych restauracji z bazy lokalnej
              DBHelper.getRestWithId(_mealRestsData[0].id).then((restaurant) {
                print(restaurant.asMap()[0]['modMenu']);
                //jezeli czasy modyfikacji menu dla restauracji (z serwera i bazy lokalnej) są równe to przejście do szczegółów dania
                if (_mealRestsData[0].modMenu ==
                    restaurant.asMap()[0]['modMenu']) {
                  //print('bez przeładowania');
                  Mems.insertMemory(
                    //zapisanie danych wybranego dania przed przejściem do jego szczegółów
                    'memDanie', //nazwa
                    meal.id, //a - daId
                    meal.foto, //b - foto
                    meal.alergeny, //c - alergeny
                    meal.nazwa, //d - nazwa dania
                    '0', //e - index wersji dania   (w iOS - index row)
                    meal.fav, //f - fav - polubienie
                  );
                  Navigator.of(context).pushNamed(
                    TabsDetailScreen.routeName,
                    arguments: meal.id,
                  );
                } else {
                  //jezeli nie to odświezenie menu
                  //print('przeładowanie!!!!!!!!!!!!!!!');
                  //_setPrefers('reload', 'true');  //dane nieaktualne - trzeba przeładować dane

                  //final snackBar = SnackBar(content: Text('Aktualizacja menu ${_mealRestsData[0].nazwa}'));
                  //Scaffold.of(context).showSnackBar(snackBar);
                  _showAlert(context, _mealRestsData[0].nazwa);

                  fetchMemoryLok().then((_) {
                    //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
                    Meals.deleteAllMeals().then((_) {
                      //kasowanie tabeli dań w bazie lokalnej
                      Rests.deleteAllRests().then((_) {
                        //kasowanie tabeli restauracji w bazie lokalnej
                        Podkategorie.deleteAllPodkategorie().then((_) {
                          //kasowanie tabeli podkategorii w bazie lokalnej
                          Meals.fetchMealsFromSerwer(
                                  'https://cobytu.com/cbt.php?d=f_dania&uz_id=&woj_id=${_memLok[0].a}&mia_id=${_memLok[0].c}&rest=${_memLok[0].e}&lang=$_currLang')
                              .then((_) {
                            Rests.fetchRestsFromSerwer().then((_) {
                              Podkategorie.fetchPodkategorieFromSerwer(
                                      'https://cobytu.com/cbt.php?d=f_podkategorie&uz_id=&woj_id=${_memLok[0].a}&mia_id=${_memLok[0].c}&rest=${_memLok[0].e}&lang=$_currLang')
                                  .then((_) {
                                Provider.of<Meals>(context, listen: false)
                                    .fetchAndSetMeals()
                                    .then((_) {
                                  //z bazy lokalnej
                                  Provider.of<Podkategorie>(context, listen: false)
                                      .fetchAndSetPodkategorie()
                                      .then((_) {
                                    //z bazy lokalnej

                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                        MealsScreen.routeName,
                                        ModalRoute.withName(MealsScreen
                                            .routeName)); //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
                                  });
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                }
              });
            });
          } else {
            print('braaaaaak');
            _showAlertAnuluj(context, allTranslations.text('L_BRAK_INTERNETU'),
                allTranslations.text('L_URUCHOM_INTERNETU'));
          } //if internet
        });
      },

      child: Card(
        //karta z daniem
        shape: RoundedRectangleBorder(
          //kształt karty
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4, //cień za kartą
        margin: EdgeInsets.all(7), //margines wokół karty
        child: Column(
          //zawartość karty - kolumna z widzetami
          children: <Widget>[
            Row(
              //całą zawatość kolmny stanowi wiersz
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem
              children: <Widget>[
                Expanded(
                  //rozszerzona kolumna z tekstami  - cała dostępna przestrzeń (poza zdjęciem)
                  child: Container(
                    //zeby zrobić margines wokół części tekstowej
                    padding:
                        EdgeInsets.all(8.00), //margines wokół części tekstowej
                    child: Column(
                      //ustawienie elementów jeden pod drugim - tytuł i opis
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          //nazwa dania
                          meal.nazwa,
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).primaryColor,
                          ),
                          softWrap: false, //zawijanie tekstu
                          overflow: TextOverflow
                              .fade, //skracanie tekstu zeby zmieścił sie
                        ),
                        Container(
                          //pojemnik na opis
                          padding: EdgeInsets.only(top: 2),
                          height: 38,
                          child: Text(
                            //opis dania
                            meal.opis,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                            softWrap: true, //zawijanie tekstu
                            maxLines: 2, //ilość wierszy opisu
                            overflow: TextOverflow
                                .ellipsis, //skracanie tekstu zeby zmieścił sie
                          ),
                        ),
                        Padding(
                          //odstępy dla wiersza z ikonami
                          padding: EdgeInsets.only(top: 5),
                          child: Row(
                            //rząd z informacjami o posiłku
                            mainAxisAlignment: MainAxisAlignment
                                .spaceAround, //główna oś wyrównywania
                            children: <Widget>[
                              //elementy rzędu które sa widzetami
                              Row(
                                //cena dania
                                children: <Widget>[
                                  Text(
                                    globals.separator == '.'
                                        ? meal.cena
                                        : meal.cena.replaceAll('.',
                                            ','), //meal.cena, //interpolacja ciągu znaków
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ), //odległość miedzy ceną a PLN
                                  Text(
                                    allTranslations.text(
                                        'L_PLN'), //interpolacja ciągu znaków
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              /*      Row(
          //polubienie - Kazdy element wiersz jest wierszemonym z ikony i tekstu
          children: <Widget>[
            Consumer<Meal>(
              // słuchacz na wybranym widzecie (kurs sklep  197)
              builder: (context, meal, child) =>
  
                Icon(
                  meal.stolik != '0' 
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Theme.of(context)
                      .primaryColor,
                ), //zmiana ikony
                
              ),
            
          ],
        ),
  */

                              /*                       if(meal.stolik !=
                                      '0') //jezeli danie dodano do koszyka
                                   Row(
                                      // ile- Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu
                                      children: <Widget>[
                                        Icon(
                                          Icons.add_shopping_cart,
                                          color: Theme.of(context)
                                              .primaryColor, //schedule
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ), //odległość miedzy ikoną i tekstem
                                        Text(
                                          meal.stolik + 'x',
                                        ), //interpolacja ciągu znaków
                                      ],
                                    ),
         */

                              /*           Row(
                                // czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu
                                children: <Widget>[
                                  Image.asset('assets/images/czas.png',
                                      height: 15),
                                  SizedBox(
                                    width: 2,
                                  ), //odległość miedzy ikoną i tekstem
                                  Text(
                                    meal.czas +
                                        ' ' +
                                        allTranslations.text('L_MIN'),
                                  ), //interpolacja ciągu znaków
                                ],
                              ),
       */

                            //poziom lubienia
                            globals.uzLogin != null //jezeli jest login uzytkownika tzn ze jest połączenie
                              ? Row(  //poziom lubienia                           
                                  children: <Widget>[
                                    CircularPercentIndicator(
                                      radius: 30.0,
                                      animation: true,
                                      animationDuration: 2200,
                                      lineWidth: 4.0,
                                      percent: int.parse(meal.lubi)/100,
                                      center: new Text(
                                        meal.lubi=="100" ? '' : meal.lubi,
                                        style:
                                            new TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                      ),
                                      circularStrokeCap: CircularStrokeCap.butt,
                                      backgroundColor: Colors.grey,
                                      progressColor: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                )
                              :Row(children: [
                                SizedBox(
                                    width: 1,
                                  ),
                              ],),
                              
                              Row(
                                //polubienie - Kazdy element wiersz jest wierszem złozonym z ikony i tekstu
                                children: <Widget>[
                                  Consumer<Meal>(
                                    // słuchacz na wybranym widzecie (kurs sklep  197)
                                    builder: (context, meal, child) =>
                                        GestureDetector(
                                      child: Icon(
                                        meal.fav == '1'
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Theme.of(context).primaryColor,
                                      ), //zmiana ikony
                                      onTap: () {
                                        
                                        meal.toggleFavoriteStatus(
                                            meal.id); //przekazane id dania
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              //zamiast zaślepki foto
                              if (meal.foto.substring(27) ==
                                  '/co.jpg') //jezeli zaślepka
                                SizedBox(
                                  width: 115,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (meal.foto.substring(27) != '/co.jpg') //jezeli jest foto
                  Container(
                    //pojemnik na zdjęcie
                    //padding: EdgeInsets.only(right: 1.00),
                    child: ClipRRect(
                      //element opakowania obrazka zeby zaokrąglić rogi
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(
                        //obrazek dania pobierany z neta
                        meal.foto, //adres internetowy
                        height: 110, //wysokość obrazka
                        width: 140,
                        fit: BoxFit.cover, //dopasowanie do pojemnika
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
