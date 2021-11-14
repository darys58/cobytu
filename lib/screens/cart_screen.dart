import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //obsługa json'a
import '../models/cart.dart';
import '../models/strefa.dart';
import '../widgets/cart_one.dart';
import '../globals.dart' as globals;
import '../all_translations.dart';
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import './order_screen.dart';
import '../screens/meals_screen.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  String opakowanie =
      ''; //cena opakowania doliczana przez restaurację - wartość z bazy www
  String _cenaRazem;
  String _wagaRazem;
  String _kcalRazem;
  List<Strefa> _strefy = []; //lista stref
  int _wybranaStrefa = globals.wybranaStrefa;

  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
      fetchStrefyFromSerwer().then((_) {
        //pobranie stref z serwera www
        print('cart_screen: _wybranaStrefa = $_wybranaStrefa');
        if (_wybranaStrefa == null) _wybranaStrefa = 1;

        //pobieranie dań w koszyku z serwera www
        Provider.of<Cart>(context, listen: false)
            .fetchAndSetCartItems(
                'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLokE}&lang=${globals.language}')
            .then((_) {
          DBHelper.getRestWithId(globals.memoryLokE).then((restaurant) {
            opakowanie = restaurant.asMap()[0]
                ['opakowanie']; //pobranie doliczanej wartości opakowania
            print(
                'cart_screen: pobranie wartości opakowania z bazy lokalnej = $opakowanie');
            setState(() {
              _isLoading = false; //zatrzymanie wskaznika ładowania danych
            });
          });
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
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
    print('cart_screen: aktualizujKoszyk response.body ${response.body}');
    if (response.statusCode >= 200 &&
        response.statusCode <= 400 &&
        json != null) {
      //Map<String, dynamic> odpPost = json.decode(response.body);
      //zapisanie w tabeli 'dania' do pola 'stolik' ilości tego dania w koszyku
      //Meal.changeStolik(odpPost['ko_da_id'], odpPost['ko_ile'].toString());
      //Meals.updateKoszyk(odpPost['ko_da_id'], odpPost['ko_ile'].toString()); //aktualizacja ilości dania w koszyku w danych on daniu

      //aktualizacja zawartości koszyka z www
      Provider.of<Cart>(context, listen: false).fetchAndSetCartItems(
          'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLokE}&lang=${globals.language}');

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
      print('cart_screen: numer strefy w order = ${_strefy[0].numer}');
     
      //notifyListeners();
      return _strefy;
    } catch (error) {
      throw (error);
    }
  }

  void _showAlertYesNo(BuildContext context, String nazwa, String text) {
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
              aktualizujKoszyk(
                  '3'); //czyszczenie koszyka na serwerze - akcja '3'
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MealsScreen.routeName,
                  ModalRoute.withName(MealsScreen
                      .routeName)); //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
            },
            child: Text(allTranslations.text('L_TAK')),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(allTranslations.text('L_NIE')),
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

  void _showAlert(BuildContext context, String nazwa, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
       // title: Text(nazwa),
        content: Column(
          //zeby tekst był wyśrodkowany w poziomie
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                //color: Colors.black,
              ),
            ),
            //Divider(),
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

  @override
  Widget build(BuildContext context) {
    print('cart_screen: opłata za opakowanie = $opakowanie');
    //final rest = Provider.of<Rests>(context);
    //print('rest===');
    //print (rest.items);
    final cart = Provider.of<Cart>(context, listen: false);
    double razemC = 0;
    int razemW = 0;
    int razemK = 0;
    for (var i = 0; i < cart.items.length; i++) {
      razemC = razemC + double.parse(cart.items[i].cena);
      razemW = razemW + int.parse(cart.items[i].waga);
      razemK = razemK + int.parse(cart.items[i].kcal);
    }
    _cenaRazem = razemC.toStringAsFixed(2);
    _wagaRazem = razemW.toString();
    _kcalRazem = razemK.toString();
    print(
        'cart_screen: wartość obliczana z zawartości koszyka _cenaRazem = $_cenaRazem');

    return Scaffold(
      appBar: AppBar(
        title: globals.dostawy == '1' //jezeli dostawy
            ? Text(allTranslations.text('L_KOSZYK'))
            : Text(allTranslations.text('L_STOLIK')),
        actions: globals.memoryLokE != '0'
            ? <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                  ),
                  onPressed: () {
                    _showAlertYesNo(context, allTranslations.text('L_UWAGA'),
                        allTranslations.text('L_CZY_OPROZNIC_KOSZYK') + '?');
                  },
                )
              ]
            : <Widget>[],
      ),
      body: _isLoading //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          : Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        itemCount: cart.items.length + 1,
                        itemBuilder: (ctx, i) {
                          //print(cart.items[0].id);
                          if (cart.items[0].id != 'brak') {
                            if (i < cart.items.length) {
                              return CartOne(
//kolejne zamówione dania
                                i,
                                cart.items[i].id,
                                cart.items[i].daId,
                                cart.items[i].nazwa,
                                cart.items[i].opis,
                                cart.items[i].ile,
                                cart.items[i].cena,
                                cart.items[i].waga,
                                cart.items[i].kcal,
                              );
                            } else {
                              //
                              return Column(
                                children: <Widget>[
//RAZEM + przyciski
                                  Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 4,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 10),
                                      height: 40.0,
                                      child: Row(
                                        //polubienie - Kazdy element wiersz jest wierszemonym z ikony i tekstu
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            allTranslations.text('L_RAZEM'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
//RAZEM: cena, waga, kcal
                                          Row(
                                            //Kazdy element wiersz jest wierszemonym
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              //elementy rzędu które sa widzetami
                                              Row(
                                                //cena dania
                                                children: <Widget>[
                                                  Text(
                                                    globals.separator == '.'
                                                        ? _cenaRazem
                                                        : _cenaRazem.replaceAll(
                                                            '.', ','),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ), //meal.cena, //interpolacja ciągu znaków
                                                  ),
                                                  SizedBox(
                                                    width: 2,
                                                  ), //odległość miedzy ceną a PLN
                                                  Text(
                                                    allTranslations
                                                        .text('L_PLN'),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ), //interpolacja ciągu znaków
                                                  ),
                                                  SizedBox(
                                                    width: 18,
                                                  ),
                                                ],
                                              ),

                                              Row(
                                                // waga-
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 2,
                                                  ), //odległość miedzy ikoną i tekstem
                                                  int.parse(_wagaRazem) > 0 //jezeli są wprowadzone składniki podstawowe dania
                                                  ? Text(
                                                      _wagaRazem +
                                                          ' ' +
                                                          allTranslations
                                                              .text('L_G'),
                                                      style: TextStyle(
                                                        //fontWeight:
                                                            //FontWeight.bold,
                                                        //fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  : Text(
                                                      'n/a ' +
                                                          allTranslations
                                                              .text('L_G'),
                                                      style: TextStyle(
                                                        //fontWeight:
                                                            //FontWeight.bold,
                                                        //fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    width: 18,
                                                  ), //interpolacja ciągu znaków
                                                ],
                                              ),
                                              Row(
                                                // kcal - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 2,
                                                  ), //odległość miedzy ikoną i tekstem
                                                  int.parse(_wagaRazem) > 0 //jezeli są wprowadzone składniki podstawowe dania
                                                  ? Text(
                                                      _kcalRazem +
                                                          ' ' +
                                                          allTranslations
                                                              .text('L_KCAL'),
                                                      style: TextStyle(
                                                        //fontWeight:
                                                            //FontWeight.bold,
                                                        //fontSize: 15,
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  : Text(
                                                    'n/a ' +
                                                        allTranslations
                                                            .text('L_KCAL'),
                                                    style: TextStyle(
                                                      //fontWeight:
                                                          //FontWeight.bold,
                                                      //fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                  ), //interpolacja ciągu znaków
                                                  SizedBox(
                                                    width: 25,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
//text doliczanie opakowania
                                  Column(
                                    children: <Widget>[
                                      opakowanie ==
                                              '0.00' //jeli nie ma kosztu opakowania
                                          ? SizedBox(
                                              height: 2,
                                            )
                                          : Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 0.0),
                                              height: 55,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    globals.separator == '.'
                                                        ? Expanded(
                                                            child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: Text(
                                                                  allTranslations
                                                                          .text(
                                                                              'L_DOLICZANIE_OPAKOWANIA') +
                                                                      ' ' +
                                                                      opakowanie +
                                                                      ' ' +
                                                                      allTranslations
                                                                          .text(
                                                                              'L_PLN'),
                                                                  softWrap:
                                                                      true, //zawijanie tekstu
                                                                  maxLines:
                                                                      3, //ilość wierszy opisu
                                                                  //overflow: TextOverflow.ellipsis, //skracanie tekstu zeby zmieścił sie
                                                                )),
                                                          )
                                                        : Expanded(
                                                            child: Container(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15,
                                                                        right:
                                                                            15,
                                                                        top: 5),
                                                                child: Text(
                                                                  allTranslations
                                                                          .text(
                                                                              'L_DOLICZANIE_OPAKOWANIA') +
                                                                      ' ' +
                                                                      opakowanie.replaceAll(
                                                                          '.',
                                                                          ',') +
                                                                      ' ' +
                                                                      allTranslations
                                                                          .text(
                                                                              'L_PLN'),
                                                                  softWrap:
                                                                      true, //zawijanie tekstu
                                                                  maxLines:
                                                                      3, //ilość wierszy opisu
                                                                  //overflow: TextOverflow.ellipsis, //skracanie tekstu zeby zmieścił sie
                                                                )),
                                                          )
                                                  ])),
//przycisk zamawiania z dostawą
                                      globals.online ==
                                              '1' //jezeli zamawianie online przez CoByTu.com
                                          ? Container(
                                              height: 70,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  MaterialButton(
                                                    shape:
                                                        const StadiumBorder(),
                                                    onPressed: () {
                                                      if (_strefy[_wybranaStrefa-1].czynne=='1'){
                                                        if(razemC > double.parse(_strefy[_wybranaStrefa-1].wartMin)){
                                                          Navigator.of(context).pushNamed(OrderScreen.routeName);
                                                        }else globals.separator == '.' 
                                                          ? _showAlert(
                                                            context,
                                                            allTranslations.text(
                                                                'L_KOMUNIKAT'),
                                                            allTranslations.text(
                                                                'L_MUSI_PRZEKRACZAC') + _strefy[_wybranaStrefa-1].wartMin + ' ' + allTranslations
                                                                          .text(
                                                                              'L_PLN'))
                                                          : _showAlert(
                                                            context,
                                                            allTranslations.text(
                                                                'L_KOMUNIKAT'),
                                                            allTranslations.text(
                                                                'L_MUSI_PRZEKRACZAC') + _strefy[_wybranaStrefa-1].wartMin.replaceAll(
                                                                          '.',
                                                                          ',') + ' ' + allTranslations
                                                                          .text(
                                                                              'L_PLN'));
                                                      }else _showAlert(
                                                            context,
                                                            allTranslations.text(
                                                                'L_KOMUNIKAT'),
                                                            allTranslations.text(
                                                                'L_PROSIMY_SKLADAC') + _strefy[_wybranaStrefa-1].zamOd + ' - ' + _strefy[_wybranaStrefa-1].zamDo
                                                      );
                                                    },
                                                    child: Text(
                                                        allTranslations.text(
                                                            'L_ZAMAWIAM')),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    textColor: Colors.white,
                                                    disabledColor: Colors.grey,
                                                    disabledTextColor:
                                                        Colors.white,
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(15),
                                              child: Column(
                                                children: <Widget>[
                                                  Text(
                                                    globals.dostawy == '1'
                                                        ? allTranslations.text(
                                                                'L_ZAMOW_DO_STOLIKA') +
                                                            '\n' +
                                                            allTranslations.text(
                                                                'L_DOSTAWA_POD_ADRES')
                                                        : allTranslations.text(
                                                            'L_ZAMOW_DO_STOLIKA'),
                                                    softWrap:
                                                        true, //zawijanie tekstu
                                                    maxLines:
                                                        5, //ilość wierszy opisu
                                                    //overflow: TextOverflow.ellipsis, //skracanie tekstu zeby zmieścił sie
                                                  ),
                                                  /*     globals.dostawy == '1' 
                                                  ? Text(
                                                    allTranslations
                                                        .text('L_DOSTAWA_POD_ADRES'),
                                                    softWrap:
                                                        true, //zawijanie tekstu
                                                    maxLines:
                                                        5, //ilość wierszy opisu
                                                    //overflow: TextOverflow.ellipsis, //skracanie tekstu zeby zmieścił sie
                                                  ):{},
                                                */
                                                ],
                                              )),
                                    ],
                                  ),
                                ],
                              );
                            }
                          } else {
                            //od if(cart.items[0].id != 'brak') - czy koszyk jest pusty
                            if (i ==
                                0) //bo jest jeszcze i==1 i wtedy wyświetla dwa razy to samo
                              return Column(children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.only(top: 50),
                                  child: Text(
                                    globals.dostawy == '1' //jezeli dostawy
                                    ? allTranslations.text('L_KOSZYK_PUSTY')
                                    : allTranslations.text('L_STOLIK_PUSTY'),                                    
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              ]);
                          }
                        }),
                  ),
                ],
              ),
            ),
    );
  }
}
