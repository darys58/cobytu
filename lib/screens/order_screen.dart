import 'dart:convert'; //obsługa json'a

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../all_translations.dart';
import '../globals.dart' as globals;
import '../models/cart.dart';
import '../models/strefa.dart';
import '../screens/meals_screen.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/order'; //nazwa trasy do tego ekranu

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<OrderScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  final _formKey1 = GlobalKey<FormState>();
  //String opakowanie = '';
  int _czyDostawa = globals.czyDostawa;
  String _czasDostawy = '0.99';
  int _sposobPlatnosci = globals.sposobPlatnosci;
  int _wybranaStrefa = globals.wybranaStrefa;
  var _now = DateTime.now();
  List<String> _czasy = [];
  String _uwagi = '';
  final String _currLang = allTranslations.currentLanguage; //aktualny język
  List<DropdownMenuItem<String>> _listaCzasowDostaw = [];
  List<Strefa> _strefy = []; //lista stref
  bool moznaWysylac =
      true; //słuy do blokowania przycisku "Zamawiam" zeby pnie wysyłac kilka razy tego samego

  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });

      fetchStrefyFromSerwer().then((_) {
        //pobranie stref z serwera www
        //opakowanie = restaurant.asMap()[0]['opakowanie']; //pobranie doliczanej wartości opakowania

        //do której mozna składać zamówienia
        print('order_screen: _wybranaStrefa = $_wybranaStrefa');
        if (_wybranaStrefa == null) _wybranaStrefa = 1;
        int doGodz =
            double.parse(_strefy[_wybranaStrefa - 1].zamDo).round().toInt();
        //generowanie tablicy czasów
        for (var i = _now.hour + 1; i < doGodz; i++) {
          _czasy.add(i.toString() + ':00');
          _czasy.add(i.toString() + ':15');
          _czasy.add(i.toString() + ':30');
          _czasy.add(i.toString() + ':45');
        }
        _listaCzasowDostaw = buildDropdownMenuItem(_czasy);
        if (_czyDostawa != 1 && _czyDostawa != 2) {
          _czyDostawa = 2;
          globals.czyDostawa = 2;
        }
        setState(() {
          _isLoading = false; //zatrzymanie wskaznika ładowania danych
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  //tworzenie buttona wyboru czasu dostawy
  List<DropdownMenuItem<String>> buildDropdownMenuItem(List<String> lista) {
    List<DropdownMenuItem<String>> items = List();
    print('order_screen: lista do budowania buttona  = $lista');
    items.add(
      DropdownMenuItem(
        value: '0.99',
        child: Text(allTranslations.text('L_JAK_NAJSZYBCIEJ')),
      ),
    );
    for (String czas in lista) {
      items.add(
        DropdownMenuItem(
          value: czas,
          child: Text(czas),
        ),
      );
    }
    return items;
  }

  void _showAlert(BuildContext context, String nazwa, String text) {
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

  void _showAlertOK(BuildContext context, String nazwa, String text) {
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MealsScreen.routeName,
                  ModalRoute.withName(MealsScreen
                      .routeName)); //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
            },
            child: Text('OK'),
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

  //wysyłanie aktualizacji koszyka do serwera www - usuwanie wszystkich dań
  Future<void> aktualizujKoszyk(String akcja) async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_do_koszyka.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ko_uz_id': globals.deviceId,
        'ko_re_id': globals.memoryLokE,
        'ko_da_id': '0',
        'ko_dw1': '0',
        'ko_dw2': '0',
        'ko_dd': '0',
        'ko_cena': '0',
        'ko_waga': '0',
        'ko_kcal': '0',
        'ko_akcja': akcja,
      }),
    );
    print('order_screen: aktualizujKoszyk response.body = ${response.body}');
    if (response.statusCode >= 200 &&
        response.statusCode <= 400 &&
        json != null) {
      //Map<String, dynamic> odpPost = json.decode(response.body);
      //zapisanie w tabeli 'dania' do pola 'stolik' ilości tego dania w koszyku
      //Meal.changeStolik(odpPost['ko_da_id'], odpPost['ko_ile'].toString());
      //Meals.updateKoszyk(odpPost['ko_da_id'], odpPost['ko_ile'].toString()); //aktualizacja ilości dania w koszyku w danych on daniu

      Provider.of<Cart>(context).fetchAndSetCartItems(
          'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLokE}&lang=${globals.language}'); //aktualizacja zawartości koszyka z www

      // _setPrefers('reload', 'true');
      //return OdpPost.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed przy wysyłanie aktualizacji koszyka');
    }
  }

  //pobranie (z serwera www) stref dla danej restauracji
  Future<List<Strefa>> fetchStrefyFromSerwer() async {
    var url =
        'https://cobytu.com/cbt.php?d=f_strefy&re_id=${globals.memoryLokE}';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return [];
      }

      //final List<MealRest> loadedRests = [];
      extractedData.forEach((numerStrefy, strefaData) {
        _strefy.add(Strefa(
          numer: numerStrefy,
          czynne: strefaData['czynne'],
          zamOd: strefaData['zamow_od'],
          zamDo: strefaData['zamow_do'],
          zakres: strefaData['str_zakres'],
          wartMin: strefaData['str_wart_min'],
          koszt: strefaData['str_koszt'],
          wartMax: strefaData['str_wart_max'],
          bonus: strefaData['str_wat_bonus'],
          platne: strefaData['re_platne_dos'],
        ));
      });
      // _items = loadedRests;
      print('order_screen: numer strefy w order = ${_strefy[0].numer}');
      //notifyListeners();
      return _strefy;
    } catch (error) {
      throw (error);
    }
  }

  //wysyłanie zamówienia do serwera www - typ: dostawa / odbiów własny
  Future<void> wyslijZamowienie() async {
    final http.Response response =
        await http.post('https://cobytu.com/cbt_f_dostawa.php',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: _czyDostawa == 1
                ? jsonEncode(<String, String>{
                    "za_uz_id": globals.deviceId,
                    "za_re_id": globals.memoryLokE,
                    "za_typ": "1", //1 - dostawa lub odbiór własny
                    "za_data": "1", //data wstawiana w skrypcie php na serwerze
                    "za_godz": _czasDostawy,
                    "za_adres": globals.adres,
                    "za_numer": globals.numer,
                    "za_kod": globals.kod,
                    "za_miasto": globals.miasto,
                    "za_imie": globals.imie,
                    "za_nazwisko": globals.nazwisko,
                    "za_telefon": globals.telefon,
                    "za_email": globals.email,
                    "za_uwagi": _uwagi,
                    "za_platnosc": _sposobPlatnosci.toString(),
                    "za_koszt":
                        _strefy[_wybranaStrefa - 1].koszt, //koszt dostawy
                    "za_lang": _currLang,
                  })
                : jsonEncode(<String, String>{
                    "za_uz_id": globals.deviceId,
                    "za_re_id": globals.memoryLokE,
                    "za_typ": "1", //1 - dostawa lub odbiór własny
                    "za_data": "1", //data wstawiana w skrypcie php na serwerze
                    "za_godz": _czasDostawy,
                    "za_adres": '',
                    "za_numer": '',
                    "za_kod": '',
                    "za_miasto": '',
                    "za_imie": globals.imie,
                    "za_nazwisko": globals.nazwisko,
                    "za_telefon": globals.telefon,
                    "za_email": globals.email,
                    "za_uwagi": _uwagi,
                    "za_platnosc": _sposobPlatnosci.toString(),
                    "za_koszt": '0.00',
                    "za_lang": _currLang,
                  }));

    print('order_screen: wyslijZamowienie response.body ${response.body}');
    if (response.statusCode >= 200 &&
        response.statusCode <= 400 &&
        json != null) {
      Map<String, dynamic> odpPost = json.decode(response.body);
      if (odpPost['success'] != 'ok') {
        if (odpPost['zapis'] != 'ok') {
          _showAlert(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_WYSLANIE_ZAMOWIENIA_NIE'));
          moznaWysylac = true;
        } else {
          _showAlert(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_ZAMOWIENIE_PRZEKAZANO_ALE'));
          moznaWysylac = true;
        }
      } else {
        _showAlertOK(context, allTranslations.text('L_KOMUNIKAT'),
            allTranslations.text('L_ZAMOWIENIE_PRZEKAZANE'));
        moznaWysylac = true;
        aktualizujKoszyk('3'); //czyszczenie koszyka na serwerze - akcja '3'
        //Navigator.of(context).pushNamed(OrderScreen.routeName);
      }
    } else {
      throw Exception('Failed to create OdpPost. z zmówień');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    //print('platne ${_strefy[_wybranaStrefa - 1].platne}');

    //obliczenie wartości menu + opakowania
    double kosztMenu = 0;
    double kosztOpakowan = 0;
    for (var i = 0; i < cart.items.length; i++) {
      kosztMenu = kosztMenu + double.parse(cart.items[i].cena); //cena dań
      kosztOpakowan = kosztOpakowan +
          (cart.items[i].ile) * double.parse(globals.cenaOpakowania) +
          cart.items[i].dodOpak * double.parse(globals.cenaOpakowania);
      //(ilość dań * cena opakowania) + (ilość dodatkowych opakowań dla "zup dnia" * cena opakowania)

      print(kosztMenu);
      print('koszt menu = ');
      print(double.parse(cart.items[i].cena));
      print('+');
      print(cart.items[i].dodOpak);
      print('*');
      print(double.parse(globals.cenaOpakowania));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('L_ZAMOWIENIE')),
      ),
      body: _isLoading //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
//Dostawa
                          FlatButton.icon(
                              onPressed: () {
                                setState(() {
                                  _czyDostawa = 1;
                                  globals.czyDostawa = 1;
                                });
                              },
                              icon: Radio(
                                  value: 1,
                                  groupValue: _czyDostawa,
                                  onChanged: (value) {
                                    setState(() {
                                      _czyDostawa = value;
                                      globals.czyDostawa = value;
                                    });
                                  }),
                              label: Text(allTranslations.text('L_DOSTAWA'))),
//Odbiór własny
                          FlatButton.icon(
                              onPressed: () {
                                setState(() {
                                  _czyDostawa = 2;
                                  globals.czyDostawa = 2;
                                });
                              },
                              icon: Radio(
                                  value: 2,
                                  groupValue: _czyDostawa,
                                  onChanged: (value) {
                                    setState(() {
                                      _czyDostawa = value;
                                      globals.czyDostawa = value;
                                    });
                                  }),
                              label: Text(
                                  allTranslations.text('L_ODBIOR_WLASNY'))),
                        ],
                      ),
                      //koszty
                      Container(
                          //padding: EdgeInsets.only(left: 20),
                          child: Column(
                        children: <Widget>[
                          Divider(
                            color: Colors.grey,
                          ),
//koszt menu
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    allTranslations.text('L_KOSZT_MENU'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  //wartość
                                  children: <Widget>[
                                    Text(
                                      globals.separator == '.'
                                          ? kosztMenu.toStringAsFixed(2)
                                          : kosztMenu
                                              .toStringAsFixed(2)
                                              .replaceAll('.', ','),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ), //odległość miedzy ceną a PLN
                                    Text(
                                      allTranslations.text('L_PLN'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ), //interpolacja ciągu znaków
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                  ],
                                ),
                              ]),
                          Divider(
                            color: Colors.grey,
                          ),

//koszt opakowań
                          Visibility(
                            visible: globals.cenaOpakowania != "0.00",
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      allTranslations.text('L_KOSZT_OPAKOWAN'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    //wartość
                                    children: <Widget>[
                                      Text(
                                        globals.separator == '.'
                                            ? kosztOpakowan.toStringAsFixed(2)
                                            : kosztOpakowan
                                                .toStringAsFixed(2)
                                                .replaceAll('.', ','),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ), //odległość miedzy ceną a PLN
                                      Text(
                                        allTranslations.text('L_PLN'),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ), //interpolacja ciągu znaków
                                      ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                    ],
                                  ),
                                ]),
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
//koszt dostawy
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    allTranslations.text('L_KOSZT_DOSTAWY'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Row(
//wartość
                                  children: <Widget>[
                                    Text(
                                      _czyDostawa == 1
                                          ? globals.separator == '.'
                                              ? _strefy[_wybranaStrefa - 1]
                                                  .koszt
                                              : _strefy[_wybranaStrefa - 1]
                                                  .koszt
                                                  .replaceAll('.', ',')
                                          : globals.separator == '.'
                                              ? '0.00'
                                              : '0,00',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ), //odległość miedzy ceną a PLN
                                    Text(
                                      allTranslations.text('L_PLN'),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ), //interpolacja ciągu znaków
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                  ],
                                ),
                              ]),
                          Divider(
                            color: Colors.grey,
                          ),
//całkowity koszt
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    allTranslations.text('L_CALKOWITY_KOSZT'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Row(
//wartość
                                  children: <Widget>[
                                    Text(
                                      _czyDostawa == 1
                                          ? globals.separator == '.'
                                              ? (kosztMenu +
                                                      kosztOpakowan +
                                                      double.parse(_strefy[
                                                              _wybranaStrefa -
                                                                  1]
                                                          .koszt))
                                                  .toStringAsFixed(2)
                                              : (kosztMenu +
                                                      kosztOpakowan +
                                                      double.parse(_strefy[
                                                              _wybranaStrefa -
                                                                  1]
                                                          .koszt))
                                                  .toStringAsFixed(2)
                                                  .replaceAll('.', ',')
                                          : globals.separator == '.'
                                              ? (kosztOpakowan + kosztMenu)
                                                  .toStringAsFixed(2)
                                              : (kosztOpakowan + kosztMenu)
                                                  .toStringAsFixed(2)
                                                  .replaceAll('.', ','),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ), //odległość miedzy ceną a PLN
                                    Text(
                                      allTranslations.text('L_PLN'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black,
                                      ), //interpolacja ciągu znaków
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                  ],
                                ),
                              ]),
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(height: 5),
                        ],
                      )),

//miejsce dostawy

                      Visibility(
                        visible: _czyDostawa == 1,
                        child: Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          padding: EdgeInsets.only(left: 20),
                          //color: Colors.grey[300],
                          height: 38,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  allTranslations.text('L_MIEJSCE_DOSTAWY'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ]),
                        ),
                      ),

//Strefa
                      Visibility(
                        visible: _czyDostawa == 1,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20, top: 10),
                          child: RaisedButton(
                            onPressed: () {
                              showDialog(
                                  //okno do wyboru stref
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30.0),
                                      child: AlertDialog(
                                        content: Container(
                                          width: double.maxFinite,
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(allTranslations
                                                    .text('L_WYBIERZ_STREFE')),
                                                Expanded(
                                                  child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: _strefy.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            setState(() {
                                                              _wybranaStrefa =
                                                                  index + 1;
                                                              globals.wybranaStrefa =
                                                                  index + 1;
                                                            });
                                                          },
                                                          child: Card(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 20),
                                                              elevation:
                                                                  4, //cień za kartą
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                child: Column(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      allTranslations
                                                                              .text('L_STREFA') +
                                                                          ' ${_strefy[index].numer}',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        //color: Colors.grey,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    Text(_strefy[
                                                                            index]
                                                                        .zakres)
                                                                  ],
                                                                ),
                                                              )),
                                                        );
                                                      }),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            color: Colors.grey[200],
                            child: Text(
                              allTranslations.text('L_STREFA_DOSTAWY') +
                                  ' ' +
                                  _wybranaStrefa.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
//formularz
                      Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Form(
                            key: _formKey1,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  //Adres
                                  Visibility(
                                    visible: _czyDostawa == 1,
                                    child: TextFormField(
                                        initialValue: globals.adres,
                                        decoration: InputDecoration(
                                          labelText:
                                              allTranslations.text('L_ADRES'),
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                          hintText: allTranslations
                                              .text('L_WPISZ_ULICE'),
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return allTranslations
                                                .text('L_WPISZ_ULICE');
                                          }
                                          globals.adres = value;
                                          return null;
                                        }),
                                  ),
//Numer
                                  Visibility(
                                    visible: _czyDostawa == 1,
                                    child: TextFormField(
                                        initialValue: globals.numer,
                                        decoration: InputDecoration(
                                          labelText:
                                              allTranslations.text('L_NUMER'),
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                          hintText: allTranslations
                                              .text('L_WPISZ_NUMER'),
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return allTranslations
                                                .text('L_WPISZ_NUMER');
                                          }
                                          globals.numer = value;
                                          return null;
                                        }),
                                  ),

//Kod
                                  Visibility(
                                    visible: _czyDostawa == 1,
                                    child: TextFormField(
                                        initialValue: globals.kod,
                                        decoration: InputDecoration(
                                          labelText: allTranslations
                                              .text('L_KOD_POCZTOWY'),
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                          hintText: allTranslations
                                                  .text('L_WPISZ_KOD') +
                                              ' (XX-XXX)',
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return allTranslations
                                                    .text('L_WPISZ_KOD') +
                                                ' (XX-XXX)';
                                          }
                                          globals.kod = value;
                                          return null;
                                        }),
                                  ),
//Miasto
                                  Visibility(
                                    visible: _czyDostawa == 1,
                                    child: TextFormField(
                                        initialValue: globals.miasto,
                                        decoration: InputDecoration(
                                          labelText:
                                              allTranslations.text('L_MIASTO'),
                                          labelStyle:
                                              TextStyle(color: Colors.black),
                                          hintText: allTranslations
                                              .text('L_WPISZ_MIASTO'),
                                        ),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return allTranslations
                                                .text('L_WPISZ_MIASTO');
                                          }
                                          globals.miasto = value;
                                          return null;
                                        }),
                                  ),
//dane zamawiającego
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding: EdgeInsets.only(left: 20),
                                    //color: Colors.grey[300],
                                    height: 38,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            allTranslations
                                                .text('L_DANE_ZAMAWIAJACEGO'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ]),
                                  ),

                                  //Imię
                                  TextFormField(
                                      initialValue: globals.imie,
                                      decoration: InputDecoration(
                                        labelText:
                                            allTranslations.text('L_IMIE'),
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        hintText: allTranslations
                                            .text('L_WPISZ_IMIE'),
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return allTranslations
                                              .text('L_WPISZ_IMIE');
                                        }
                                        globals.imie = value;
                                        return null;
                                      }),
//Nazwisko
                                  TextFormField(
                                      initialValue: globals.nazwisko,
                                      decoration: InputDecoration(
                                        labelText:
                                            allTranslations.text('L_NAZWISKO'),
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        hintText: allTranslations
                                            .text('L_WPISZ_NAZWISKO'),
                                      ),
                                      validator: (value) {
                                        globals.nazwisko = value;
                                        return null;
                                      }),

//Telefon
                                  TextFormField(
                                      initialValue: globals.telefon,
                                      decoration: InputDecoration(
                                        labelText:
                                            allTranslations.text('L_TELEFON'),
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        hintText: allTranslations
                                            .text('L_WPISZ_TELEFON'),
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return allTranslations
                                              .text('L_WPISZ_TELEFON');
                                        }
                                        globals.telefon = value;
                                        return null;
                                      }),
//Email
                                  TextFormField(
                                      initialValue: globals.email,
                                      decoration: InputDecoration(
                                        labelText:
                                            allTranslations.text('L_EMAIL'),
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        hintText: allTranslations
                                            .text('L_WPISZ_EMAIL'),
                                      ),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return allTranslations
                                              .text('L_WPISZ_EMAIL');
                                        }
                                        globals.email = value;
                                        return null;
                                      }),
//informacje dodatkowe
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding: EdgeInsets.only(left: 20),
                                    //color: Colors.grey[300],
                                    height: 38,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            allTranslations
                                                .text('L_INFO_DODATKOWE'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ]),
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        allTranslations.text('L_CZAS_DOSTAWY') +
                                            ': ',
                                        style: TextStyle(
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      DropdownButton(
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black54,
                                          ),
                                          value:
                                              _czasDostawy, //ustawiona, widoczna wartość
                                          items:
                                              _listaCzasowDostaw, //lista elementów do wyboru
                                          onChanged: (String newValue) {
                                            //wybrana nowa wartość - nazwa dodatku
                                            setState(() {
                                              _czasDostawy =
                                                  newValue; // ustawienie nowej wybranej nazwy dodatku
                                              print(
                                                  '_czasDostawy = $_czasDostawy');
                                              //  war1Id = _listWar1.indexOf(newValue); //pobranie indexu wybranego dodatku z listy
                                              //  _selectedWar1Id = _detailMealData[0].warList1Id[war1Id]; //Id wybranego dodatku
                                              // przelicz();
                                            });
                                          } //onChangeDropdownItemWar1,
                                          ),
                                    ],
                                  ),
                                  //Uwagi
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText:
                                          allTranslations.text('L_UWAGI'),
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      hintText:
                                          allTranslations.text('L_WPISZ_UWAGI'),
                                    ),
                                    onChanged: (String value) {
                                      setState(() {
                                        _uwagi = value;
                                      });
                                    },
                                    maxLines: null,
                                  ),
//informacje dodatkowe sposób zapłaty
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    padding: EdgeInsets.only(left: 20),
                                    //color: Colors.grey[300],
                                    height: 38,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            allTranslations
                                                .text('L_SPOSOB_ZAPLATY'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ]),
                                  ),
//wybór sposobu zapłaty
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
//musi być conajmniej płatność gotówką więc:
                                      FlatButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _sposobPlatnosci = 1;
                                              globals.sposobPlatnosci = 1;
                                            });
                                          },
                                          icon: Radio(
                                              value: 1,
                                              groupValue: _sposobPlatnosci,
                                              onChanged: (value) {
                                                setState(() {
                                                  _sposobPlatnosci = value;
                                                  globals.sposobPlatnosci =
                                                      value;
                                                });
                                              }),
                                          label: Text(allTranslations.text(
                                              'L_GOTOWKA_PRZY_ODBIORZE'))),

//jezeli platne (tzn. re_platne_dos) =  3 lub 7 to opócz gotówki jest karta
                                      Visibility(
                                        visible: _strefy[_wybranaStrefa - 1]
                                                    .platne ==
                                                '3' ||
                                            _strefy[_wybranaStrefa - 1]
                                                    .platne ==
                                                '7',
                                        child: FlatButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _sposobPlatnosci = 2;
                                                globals.sposobPlatnosci = 2;
                                              });
                                            },
                                            icon: Radio(
                                                value: 2,
                                                groupValue: _sposobPlatnosci,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _sposobPlatnosci = value;
                                                    globals.sposobPlatnosci =
                                                        value;
                                                  });
                                                }),
                                            label: Text(allTranslations.text(
                                                'L_KARTA_PRZY_ODBIORZE'))),
                                      ),

//jezeli platne (tzn. re_platne_dos) =  5 lub 7 to opócz gotówki i/lub karta jest online
                                      Visibility(
                                        visible: _strefy[_wybranaStrefa - 1]
                                                    .platne ==
                                                '5' ||
                                            _strefy[_wybranaStrefa - 1]
                                                    .platne ==
                                                '7',
                                        child: FlatButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _sposobPlatnosci = 3;
                                              globals.sposobPlatnosci = 3;
                                            });
                                          },
                                          icon: Radio(
                                              value: 2,
                                              groupValue: _sposobPlatnosci,
                                              onChanged: (value) {
                                                setState(() {
                                                  _sposobPlatnosci = value;
                                                  globals.sposobPlatnosci =
                                                      value;
                                                });
                                              }),
                                          label: Text(allTranslations
                                              .text('L_ONLINE_M')),
                                        ),
                                      )
                                    ],
                                  ),
                                ])),
                      ),

//informacje dodatkowe
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(left: 20),
                        //color: Colors.grey[300],
                        //height: 38,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: allTranslations
                                            .text('L_KLIKAJAC_POTWIERDZASZ') +
                                        ' ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: allTranslations.text('L_POLITYKA'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launch(
                                            'https://www.cobytu.com/index.php?d=polityka&mobile=1');
                                      },
                                  ),
                                  TextSpan(
                                    text: ' ' +
                                        allTranslations.text('L_ORAZ') +
                                        ' ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: allTranslations.text('L_REGULAMIN'),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launch(
                                            'https://www.cobytu.com/index.php?d=regulamin&mobile=1');
                                      },
                                  ),
                                  TextSpan(
                                    text: '.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ]),
                              ),
                              Container(
                                height: 90,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    MaterialButton(
                                      shape: const StadiumBorder(),
                                      onPressed: () {
                                        if (_formKey1.currentState.validate()) {
                                          //jezeli formularz wypełniony poprawnie
                                          if (globals.czyDostawa != null) {
                                            if (globals.sposobPlatnosci !=
                                                null) {
                                              if (moznaWysylac) {
                                                moznaWysylac = false;
                                                wyslijZamowienie();
                                              }
                                              //Navigator.of(context).pushNamed(OrderScreen.routeName);
                                              print('order_screen: form OK');
                                            } else
                                              _showAlert(
                                                  context,
                                                  allTranslations
                                                      .text('L_KOMUNIKAT'),
                                                  allTranslations.text(
                                                      'L_WYBIERZ_SPOSOB_ZAPLATY'));
                                          } else
                                            _showAlert(
                                                context,
                                                allTranslations
                                                    .text('L_KOMUNIKAT'),
                                                allTranslations.text(
                                                    'L_WYBIERZ_DOSTAWE_LUB'));
                                        }
                                        //Navigator.of(context).pushNamed(OrderScreen.routeName);
                                      },
                                      child: Text('   ' +
                                          allTranslations.text('L_ZAMAWIAM') +
                                          '   '),
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      disabledColor: Colors.grey,
                                      disabledTextColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                      )
                    ]),
              ),
            ),
    );
  }
}
