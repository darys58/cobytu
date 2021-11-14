//ekran szczegółów dania
import 'dart:async';
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:grouped_buttons/grouped_buttons.dart';
//import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../models/mem.dart';
import '../models/mems.dart';
import '../models/meals.dart';
import '../models/detailMeal.dart';
import '../models/cart.dart';
import '../widgets/badge.dart';
import '../all_translations.dart';
import '../globals.dart' as globals;
import './cart_screen.dart';
import 'location_screen.dart';

/*
class OdpPost { //odpowiedź serwera www po wysłaniu aktualiuzacji koszyka metodą "post"
  final int ile;
  final String da;

  OdpPost({this.ile, this.da});

  factory OdpPost.fromJson(Map<String, dynamic> json) {
    return OdpPost(
      ile: json['ko_ile'],
      da: json['ko_da_id'],
    );
  }
  
  Map toMap() {
    var map = new Map<String, dynamic>();
    map["ile"] = ile;
    map["da"] = da;
    return map;
  }
}
*/
class DetailMealScreen extends StatefulWidget {
  static const routeName = '/detail-meal';

  @override
  _DetailMealScreenState createState() => _DetailMealScreenState();
}

class _DetailMealScreenState extends State<DetailMealScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  List<DetailMeal> _detailMealData = []; //szczegóły dania
  List<Mem> _memMeal; //dane wybranego dania w tabeli memory - baza lokalna
  List<Mem> _memLok; //dane wybranej restauracji w tabeli memory - baza lokalna
  var detailMealData;
  String _currLang = allTranslations.currentLanguage; //aktualny język

  List<DropdownMenuItem<String>>
      _dropdownMenuItemsWer; ////lista wersji dania dla buttona wyboru
  List<String>
      _listWer; //lista wersji jako lista stringów, zeby uzyskać index wybranej wersji
  String _selectedWer; //wybrana wersja dania
  int werId =
      0; //index wybranej wersji (index miejsca na liście a nie id wersji )

  List<DropdownMenuItem<String>>
      _dropdownMenuItemsWar1; ////lista dodatków wariantowych 1 dla buttona wyboru
  List<String>
      _listWar1; //lista dodatków wariantowych 1 jako lista stringów, zeby uzyskać index wybranego dodatku
  String _selectedWar1; //wybrany dodatek wariantowy 1
  String _selectedWar1Id; //ID wybranego dodateku wariantowego 1
  int war1Id =
      0; //index wybranego dodatku wariantowego 1 (index miejsca na liście a nie id dodatku )

  List<DropdownMenuItem<String>>
      _dropdownMenuItemsWar2; ////lista dodatków wariantowych 2 dla buttona wyboru
  List<String>
      _listWar2; //lista dodatków wariantowych 2 jako lista stringów, zeby uzyskać index wybranego dodatku
  String _selectedWar2; //wybrany dodatek wariantowy 2
  String _selectedWar2Id; //ID wybranego dodateku wariantowego 2
  int war2Id =
      0; //index wybranego dodatku wariantowego 2 (index miejsca na liście a nie id dodatku )

  List<String> _listDod; //lista dodatków dodatkowych do wyboru
  List<String> _selectedDod = []; //wybrane dodatki dodatkowe
  String _listSelectedDodId =
      '0'; //lista id wybranych dodatków dodatkowych - jako string np: '111,222,333'

  //bool _isChecked = true;
  int _waga; //waga ustawiana w funkcji przelicz()
  int _kcal; //kcal ustawiana w funkcji przelicz()
  String _cena; //cena ustawiana w funkcji przelicz()
  //Future<OdpPost> _futureKoszyk;

  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
      fetchMemoryMeal().then((_) {
        //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
        fetchMemoryLok().then((_) {
          //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
          fetchDetailMealFromSerwer().then((_) {
            //print('pobranie szczegółów w didChangeDependencies');
            if (_detailMealData[0].werList.isNotEmpty) {
              _dropdownMenuItemsWer =
                  buildDropdownMenuWar(_detailMealData[0].werList);
              _selectedWer = _dropdownMenuItemsWer[int.parse(_memMeal[0].e)]
                  .value; //domyślna wersja
              _listWer = List<String>.from(_detailMealData[0].werList);
            }
            if (_detailMealData[0].warList1.isNotEmpty) {
              _dropdownMenuItemsWar1 =
                  buildDropdownMenuWar(_detailMealData[0].warList1);
              _selectedWar1 = _dropdownMenuItemsWar1[0].value; //domyślny war1
              _listWar1 = List<String>.from(_detailMealData[0].warList1);
              _selectedWar1Id =
                  _detailMealData[0].warList1Id[0]; //domyśny Id war1
            }
            if (_detailMealData[0].warList2.isNotEmpty) {
              _dropdownMenuItemsWar2 =
                  buildDropdownMenuWar(_detailMealData[0].warList2);
              _selectedWar2 = _dropdownMenuItemsWar2[0].value; //domyślny war2
              _listWar2 = List<String>.from(_detailMealData[0].warList2);
              _selectedWar2Id =
                  _detailMealData[0].warList2Id[0]; //domyśny Id war2
            }

            _listDod = List<String>.from(_detailMealData[0]
                .dodat); //zmiana typu List<dynamic> na List<String>

            globals.wKoszyku = _detailMealData[0].stolik;
            print('ile na stoliku = ${_detailMealData[0].stolik}');
            przelicz();

            setState(() {
              detailMealData = _detailMealData;
              _isLoading = false; //zatrzymanie wskaznika ładowania dań    
            });
          });
        });
      });
    }
    if (_currLang == 'en' || _currLang == 'ja' || _currLang == 'zh')
      globals.separator = '.'; //separator w cenie
    _isInit = false;
    super.didChangeDependencies();
  }

  //jezeli wybrano inną wersję dania - wczytanie nowego dania
  rebuildDetailMeal() {
    //print ('wejście do rebuild');
    fetchMemoryMeal().then((_) {
      //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
      fetchDetailMealFromSerwer().then((_) {
        //print('rebuild po pobraniu danych - budowa pól wyboru');
        if (_detailMealData[0].werList.isNotEmpty) {
          _dropdownMenuItemsWer =
              buildDropdownMenuWar(_detailMealData[0].werList);
          _selectedWer = _dropdownMenuItemsWer[int.parse(_memMeal[0].e)]
              .value; //domyślna wersja
        }
        if (_detailMealData[0].warList1.isNotEmpty) {
          _dropdownMenuItemsWar1 =
              buildDropdownMenuWar(_detailMealData[0].warList1);
          _selectedWar1 = _dropdownMenuItemsWar1[0].value; //domyślny war1
          _listWar1 = List<String>.from(
              _detailMealData[0].warList1); //przerobienie na listę stringów
          _selectedWar1Id = _detailMealData[0].warList1Id[0]; //domyśny Id war1
        }
        if (_detailMealData[0].warList2.isNotEmpty) {
          _dropdownMenuItemsWar2 =
              buildDropdownMenuWar(_detailMealData[0].warList2);
          _selectedWar2 = _dropdownMenuItemsWar2[0].value; //domyślny war2
          _listWar2 = List<String>.from(_detailMealData[0].warList2);
          _selectedWar2Id = _detailMealData[0].warList2Id[0]; //domyśny Id war2
        }

        _listDod = List<String>.from(_detailMealData[0]
            .dodat); //zmiana typu List<dynamic> na List<String>

        globals.wKoszyku = _detailMealData[0].stolik;
        print('ile na stoliku = ${_detailMealData[0].stolik}');
        przelicz();

        setState(() {
          detailMealData = _detailMealData;
          // _isLoading = true; //uruchomienie wskaznika ładowania dań (tu chyba niepotrzebnie)
        });
      });
    });
  }

  //tworzenie buttonów wyboru dodatków wariantowych 1 i 2
  List<DropdownMenuItem<dynamic>> buildDropdownMenuWar(List<dynamic> lista) {
    List<DropdownMenuItem<String>> items = List();
    //print('lista do budowania buttona $lista');
    for (String war in lista) {
      print(war);
      items.add(
        DropdownMenuItem(
          value: war,
          child: Text(war),
        ),
      );
    }
    return items;
  }

  //pobranie (z serwera www) szczegółów dania - dla szczegółów dania
  //jezeli konto połaczone tzn. jest &dev - dane są spersonalizowane kontem zalogowanego
  Future<List<DetailMeal>> fetchDetailMealFromSerwer() async {
    var url =
        'https://cobytu.com/cbt.php?d=f_danie&danie=${_memMeal[0].a}&uz_id=&dev=${globals.deviceId}&rest=${_memLok[0].e}&lang=$_currLang';
    print(url);
    try {
      final response = await http.get(url);
      //print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return [];
      }

      _detailMealData =
          []; //konieczne zerowanie bo doda sie do poprzedniej wartości
      extractedData.forEach((mealId, mealData) {
        _detailMealData.add(DetailMeal(
          id: mealId,
          nazwa: mealData['da_nazwa'],
          opis: mealData['da_opis'],
          cena: mealData['cena'],
          czas: mealData['da_czas'],
          waga: mealData['waga'],
          kcal: mealData['kcal'],
          lubi: mealData['da_lubi'],
          stolik: mealData['na_stoliku'],
          alergeny: mealData['alergeny'],
          srednia: mealData['da_srednia'],
          cenaPodst: mealData['cena_podst'],
          wagaPodst: mealData['da_waga_podst'],
          kcalPodst: mealData['da_kcal_podst'],
          werListId: mealData['da_id_lista_wer'],
          werList: mealData['da_wersja_lista'],
          warUlub: mealData['do_wariant'],
          warList1: mealData['do_wariant_lista1'],
          warList2: mealData['do_wariant_lista2'],
          dodat: mealData['do_dodat'],
          podstId: mealData['do_podst_id'],
          warUlubId: mealData['do_wariant_id'],
          warList1Id: mealData['do_wariant_lista1_id'],
          warList2Id: mealData['do_wariant_lista2_id'],
          dodatId: mealData['do_dodat_id'],
          warList1Waga: mealData['do_wariant_lista1_waga'],
          warList2Waga: mealData['do_wariant_lista2_waga'],
          dodatWaga: mealData['do_dodat_waga'],
          warList1Kcal: mealData['do_wariant_lista1_kcal'],
          warList2Kcal: mealData['do_wariant_lista2_kcal'],
          dodatKcal: mealData['do_dodat_kcal'],
          warList1Cena: mealData['do_wariant_lista1_cena'],
          warList2Cena: mealData['do_wariant_lista2_cena'],
          dodatCena: mealData['do_dodat_cena'],
        ));
      });
      print('pobrane dane dania np. alergeny = ${_detailMealData[0].alergeny}');
      return _detailMealData;
    } catch (error) {
      throw (error);
    }
  }

  //pobranie memory z bazy lokalnej
  Future<void> fetchMemoryMeal() async {
    final data = await DBHelper.getMemory('memDanie');
    _memMeal = data
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
    //print('memoryMeal$_memMeal');
    return _memMeal;
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
    //print('memoryLok$_memLok');
    return _memLok;
  }

  przelicz() {
    int waga = 0;
    int kcal = 0;
    double cena = 0.00;

    waga += int.parse(_detailMealData[0].wagaPodst); //waga podstawowa
    kcal += int.parse(_detailMealData[0].kcalPodst); //kcal podstawowe
    cena += double.parse(_detailMealData[0].cenaPodst); //cena podstawowa

    if (_detailMealData[0].warList1.length > 0) {
      //jeżeli są dodatki wariant1
      waga += int.parse(_detailMealData[0].warList1Waga[war1Id]); //+ wariant1
      kcal += int.parse(_detailMealData[0].warList1Kcal[war1Id]); //+ wariant1
      cena +=
          double.parse(_detailMealData[0].warList1Cena[war1Id]); //+ wariant1
    }

    if (_detailMealData[0].warList2.length > 0) {
      //jeżeli są dodatki wariant2
      waga += int.parse(_detailMealData[0].warList2Waga[war2Id]); //+ wariant2
      kcal += int.parse(_detailMealData[0].warList2Kcal[war2Id]); //+ wariant2
      cena +=
          double.parse(_detailMealData[0].warList2Cena[war2Id]); //+ wariant2
    }

    for (String dodatek in _selectedDod) {
      int inx = _listDod.indexOf(
          dodatek); //index dodatku dodatkowego z listy wszystkich dodatków dodatkowych
      waga += int.parse(_detailMealData[0].dodatWaga[inx]);
      kcal += int.parse(_detailMealData[0].dodatKcal[inx]);
      cena += double.parse(_detailMealData[0].dodatCena[inx]);
    }

    setState(() {
      _waga = waga;
      _kcal = kcal;
      _cena = cena
          .toStringAsFixed(2); //zamiana z double na string w formacie XXX.XX
    });
  }

  //wysyłanie zamawianego dania do koszyka do serwera www
  Future<void> aktualizujKoszyk(String akcja) async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_do_koszyka.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ko_uz_id': globals.deviceId,
        'ko_re_id': _memLok[0].e,
        'ko_da_id': _detailMealData[0].id,
        'ko_dw1': _selectedWar1Id,
        'ko_dw2': _selectedWar2Id,
        'ko_dd': _listSelectedDodId,
        'ko_cena': _cena,
        'ko_waga': _waga.toString(),
        'ko_kcal': _kcal.toString(),
        'ko_akcja': akcja,
      }),
    );
    print(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode <= 400 &&
        json != null) {
      Map<String, dynamic> odpPost = json.decode(response.body);
      //zapisanie w tabeli 'dania' do pola 'stolik' ilości tego dania w koszyku
      //Meal.changeStolik(odpPost['ko_da_id'], odpPost['ko_ile'].toString());
      Meals.updateKoszyk(
          odpPost['ko_da_id'],
          odpPost['ko_ile']
              .toString()); //aktualizacja ilości dania w koszyku w danych on daniu
      Provider.of<Cart>(context, listen: false).fetchAndSetCartItems(
          'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLokE}&lang=${globals.language}'); //aktualizacja zawartości koszyka z www

      // _setPrefers('reload', 'true');
      //return OdpPost.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create OdpPost.');
    }
  }

/*
  //ustawienianie zmiennych globalnych
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }
  */
  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments
        as String; //id posiłku pobrany z argumentów trasy
    //final loadedMeal = Provider.of<Meals>(context).items.firstWhere((ml) => ml.id == mealId);//dla uproszczenia kodu przeniesiona do meals.dart i wtedy jak nizej
    final loadedMeal = Provider.of<Meals>(context, listen: false)
        .findById(mealId); //dla uzyskania nazwy dania i foto
    final cart =
        Provider.of<Cart>(context, listen: false); //dostęp do danych koszyka
    print('cart ========== $cart');
    //!_isLoading ? print('dane dania opis = ${detailMealData[0].opis}') : print('nic - jeszcze nie ma dania');
    //print('dane dania lubi!!!!!!!!! = ${detailMealData[0].lubi}');
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMeal.nazwa),
        actions: globals.memoryLokE != '0'
            ? <Widget>[
                //id restauracji = '0' - tzn. Wszystkie w mieście
                Consumer<Cart>(
                  builder: (_, cart, ch) => Badge(
                    child: ch,
                    value: cart.itemCount
                        .toString(), //globals.wKoszykuAll.toString(), //
                  ),
                  child: globals.dostawy ==
                          '1' //czy resta dostarcza dania z dowozem
                      ? IconButton(
                          icon: Icon(
                            Icons.shopping_cart,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(CartScreen.routeName);
                          },
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.room_service,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(CartScreen.routeName);
                          },
                        ),
                ),
              ]
            : <Widget>[],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          : SingleChildScrollView(
              child: Column(children: <Widget>[
//=== zdjęcie dania
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  loadedMeal.foto.replaceFirst(
                      RegExp('_m.jpg'), '.jpg'), //usuniecie _m z nazwy zdjęcia
                  fit: BoxFit.cover, //dopasowanie do pojemnika
                ),
              ),
//parametry dania
              Padding(
                //odstępy dla wiersza z ikonami
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  //rząd z informacjami o posiłku - cały
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, //główna oś wyrównywania - dodstęp pomidzy
                  children: [
                    detailMealData[0].alergeny.isNotEmpty 
                    ? Row(//rząd z informacjami o posiłku - po lewej
                        children: [
                          SizedBox(
                            width: 20,
                          ), 
                          Image.asset('assets/images/uwaga.png', height: 21), //ostrzezenie o alergenach (jakichkolwiek dla niezalogowanego lub tylko wskazanych dla zalogowanego np. przez połaczenie z kontem)
                         ])  
                    : Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                    ]),
                    Row(
                        //rząd z informacjami o posiłku - po prawej
                        mainAxisAlignment: MainAxisAlignment
                            .end, //główna oś wyrównywania - do prawej
                        children: <Widget>[
                          //elementy rzędu które sa widzetami
//=== czas
                          Row(
                            // czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu
                            children: <Widget>[
                              Image.asset('assets/images/czas.png', height: 15),
                              SizedBox(
                                width: 3,
                              ), //odległość miedzy ikoną i tekstem
                              Text(
                                detailMealData[0].czas +
                                    ' ' +
                                    allTranslations.text('L_MIN'),
                              ), //interpolacja ciągu znaków
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
//=== waga
                          Row(
                            // czas
                            children: <Widget>[
                              Image.asset('assets/images/waga.png', height: 15),
                              SizedBox(
                                width: 3,
                              ), //odległość miedzy ikoną i tekstem
                              _waga > 0 //jezeli są wprowadzone składniki podstawowe dania
                                  ? Text(
                                      '$_waga ' + allTranslations.text('L_G'),
                                    )
                                  : Text(
                                      'n/a ' + allTranslations.text('L_G'),
                                    ),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
//=== kcal
                          Row(
                            // czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu
                            children: <Widget>[
                              Image.asset('assets/images/energia.png',
                                  height: 15),
                              SizedBox(
                                width: 3,
                              ), //odległość miedzy ikoną i tekstem
                              _waga > 0 //jezeli są wprowadzone składniki podstawowe dania
                                  ? Text(
                                      '$_kcal ' +
                                          allTranslations.text('L_KCAL'),
                                    )
                                  : Text(
                                      'n/a ' + allTranslations.text('L_KCAL'),
                                    ), //interpolacja ciągu znaków
                              SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ]),
                  ],
                ),
              ),
//=== opis
              Row(
                  //całą zawatość kolmny stanowi wiersz
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 20.0, top: 20.0, right: 20, bottom: 5),
                        child: Text(
                          detailMealData[0].opis,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ]),
//wersja dania
              if (_detailMealData[0].werList.isNotEmpty)
                Row(
                    //całą zawatość kolmny stanowi wiersz
                    mainAxisAlignment: MainAxisAlignment
                        .start, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      DropdownButton(
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          value: _selectedWer,
                          items: _dropdownMenuItemsWer,
                          onChanged: (String newValue) {
                            //wybrana nowa wartość - nazwa wersji
                            setState(() {
                              _selectedWer =
                                  newValue; // ustawienie nowej wybranej nazwy dodatku
                              werId = _listWer.indexOf(
                                  newValue); //pobranie indexu wybranego dodatku z listy

                              Mems.insertMemory(
                                //zapisanie danych wybranego dania przed przejściem do jego szczegółów
                                'memDanie', //nazwa
                                _detailMealData[0].werListId[
                                    werId], //a - daId - id wybranej nowej wersji dania
                                _memMeal[0].b, //b - foto     // bez zmian
                                _memMeal[0].c, //c - alergeny
                                _memMeal[0].d, //d - nazwa dania
                                '$werId', //e - index wersji (miejsce na liscie)  (w iOS - index row)
                                _memMeal[0].f, //f - fav - polubienie
                              );

                              rebuildDetailMeal(); //funkcja wczytująca nowe danie
                              //przelicz();
                            });
                          }),
                    ]),
//dodatek wariantowy 1
              if (_detailMealData[0].warList1.isNotEmpty)
                Row(
                    //całą zawatość kolmny stanowi wiersz
                    mainAxisAlignment: MainAxisAlignment
                        .start, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      DropdownButton(
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          value:
                              _selectedWar1, //ustawiona, widoczna wartość - nazwa dodatku
                          items:
                              _dropdownMenuItemsWar1, //lista elementów do wyboru
                          onChanged: (String newValue) {
                            //wybrana nowa wartość - nazwa dodatku
                            setState(() {
                              _selectedWar1 =
                                  newValue; // ustawienie nowej wybranej nazwy dodatku
                              war1Id = _listWar1.indexOf(
                                  newValue); //pobranie indexu wybranego dodatku z listy
                              _selectedWar1Id = _detailMealData[0]
                                  .warList1Id[war1Id]; //Id wybranego dodatku
                              przelicz();
                            });
                          } //onChangeDropdownItemWar1,
                          ),
                    ]),

//dodatek wariantowy 2
              if (_detailMealData[0].warList2.isNotEmpty)
                Row(
                    //całą zawatość kolmny stanowi wiersz
                    mainAxisAlignment: MainAxisAlignment
                        .start, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        '+',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      DropdownButton(
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                        value: _selectedWar2,
                        items: _dropdownMenuItemsWar2,
                        onChanged: (String newValue) {
                          //wybrana nowa wartość - nazwa dodatku
                          setState(() {
                            _selectedWar2 = newValue;
                            war2Id = _listWar2.indexOf(
                                newValue); //pobranie indexu wybranego dodatku z listy
                            _selectedWar2Id = _detailMealData[0]
                                .warList2Id[war2Id]; //Id wybranego dodatku
                            przelicz();
                          });
                        },
                      ),
                    ]),
//dodatki dodatkowe
              CheckboxGroup(
                activeColor: Theme.of(context).primaryColor,
                checkColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
                margin: EdgeInsets.only(top: 5, right: 10.0),
                labels: _listDod, //lista z nazwami dodatków dodatkowych
                onChange: (bool isChecked, String label, int index) {
                  //
                  //przelicz();
                  //print("isChecked: $isChecked   label: $label  index: $index");//np. isChecked: true   label: sos pieczeniowy  index: 0
                },
                onSelected: (selectedDod) {
                  setState(() {
                    List<int> _listSelectedDodIdInt =
                        []; //lista indexów wybranych dodatków
                    _selectedDod = selectedDod; //lista nazw wybranych dodateków

                    for (var i = 0; i < _selectedDod.length; i++) {
                      //dla kazdego wybranego dodatku
                      //index miejsca dodatku na liscie wybranych dodatków
                      int _indexNaLiscieSelDod =
                          _detailMealData[0].dodat.indexOf(_selectedDod[i]);
                      //lista id wybranych dodatków - jako integery do posortowania by kolejność była zawsze taka sama - potrzebne do sprawdzania identyczności dania w koszyku
                      _listSelectedDodIdInt.add(int.parse(
                          _detailMealData[0].dodatId[_indexNaLiscieSelDod]));
                      _listSelectedDodIdInt.sort();
                    }
                    if (_listSelectedDodIdInt.isNotEmpty) {
                      _listSelectedDodId = _listSelectedDodIdInt
                          .toString(); //lista zawiera '[' i ']'
                      _listSelectedDodId = _listSelectedDodId.substring(1,
                          _listSelectedDodId.length - 1); //usuwanie '[' i ']'
                    } else
                      _listSelectedDodId = '0';
                    przelicz();
                  });
                  //print("checked: ${_selectedDod.toString()}");
                },
              ),
              SizedBox(
                height: 60,
              ), //odstęp kompensujacy dodanie bottomSheet (stopki z ceną)
            ])),
//=== stopka
      bottomSheet: _isLoading
          ? Center(
              //child: CircularProgressIndicator(), //kółko ładowania danych
              )
          : Container(
              height: 54,
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
//=== cena
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        globals.separator == '.'
                            ? _cena + ' ' + allTranslations.text('L_PLN')
                            : _cena.replaceAll('.', ',') +
                                ' ' +
                                allTranslations.text('L_PLN'),
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

//=== przyciski + -
                  globals.memoryLokE != '0'
                      ? Row(
                          // czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu
                          children: <Widget>[
                            IconButton(
                              icon:
                                  Icon(Icons.remove_circle_outline //przycisk -
                                      ),
                              iconSize: 40.0,
                              onPressed: () {
                                setState(() {
                                  if (globals.wKoszyku > 0) {
                                    aktualizujKoszyk(
                                        '2'); //usunięcie dania z koszyka na serwerze - akcja '2'
                                    globals.wKoszyku = globals.wKoszyku - 1;
                                    //cart.addItem(detailMealData[0].id, detailMealData[0].nazwa, -1, detailMealData[0].cena);
                                  }
                                });
                              },
                            ),
                            SizedBox(
                              width: 9,
                            ), //odległość miedzy ikoną i tekstem
                            Text(
                              '${globals.wKoszyku}', //ilość dań na stoliku
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 9,
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline //przycisk +
                                  ),
                              iconSize: 40.0,
                              onPressed: () {
                                setState(() {
                                  aktualizujKoszyk(
                                      '1'); //dodanie dania do koszyka na serwerze - akcja '1'
                                  globals.wKoszyku = globals.wKoszyku + 1;
                                  //cart.addItem(detailMealData[0].id, detailMealData[0].nazwa, 1, detailMealData[0].cena);
                                });
                              },
                            ),
                            SizedBox(
                              width: 15,
                            ), //interpolacja ciągu znaków
                          ],
                        )
                      : Row(children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(allTranslations.text('L_CHCESZ_ZAMOWIC') +
                                  '?'),
                              Text(allTranslations.text('L_LOKALIZACJA'))
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed: () {
                              //Navigator.of(context).pushReplacementNamed(LocationScreen.routeName);
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  LocationScreen.routeName,
                                  ModalRoute.withName(LocationScreen
                                      .routeName)); //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
                            },
                          ),
                        ]), //brak przycisków bo wybrano wszystkie restauracje
                ],
              )),
    );
  }
}
