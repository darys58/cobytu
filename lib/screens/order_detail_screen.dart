import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //obsługa json'a

import '../globals.dart' as globals;
import '../models/order.dart';
import '../all_translations.dart';
import '../screens/meals_screen.dart';

class OrderMeal {
  final String np; //numer_porzadkowy
  final String ile; //zm_ile
  final String nazwa; //zm_nazwa
  final String cena; //zm_cena

  OrderMeal({
    @required this.np,
    this.ile,
    this.nazwa,
    this.cena,
  });
}

class OrderDetailScreen extends StatefulWidget {
  static const routeName = '/order_detail'; //nazwa trasy do tego ekranu

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetailScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  //final _formKey1 = GlobalKey<FormState>();
  //String opakowanie = '';

  //final String _currLang = allTranslations.currentLanguage; //aktualny język
  List<OrderMeal> _dania = []; //lista dań do zamówienia
  String strefa; //numer wybranej strefy

  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });

      fetchOrderMealsFromSerwer().then((danie) {
        //pobranie dań do zamówienia z serwera www

        setState(() {
          _isLoading = false; //zatrzymanie wskaznika ładowania danych
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  //wysyłanie zamówienia do serwera www - typ: dostawa / odbiów własny
  Future<void> wyslijRezygnacje(
      String orderId, String orderTyp, String orderEmail) async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_rezygnacja.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "za_id": orderId,
        "za_uz_id": globals.deviceId,
        "za_re_id": globals.memoryLokE,
        "za_typ": orderTyp, //1 - dostawa lub odbiór własny
        "za_email": orderEmail,
      }),
    );
    print(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode <= 400 &&
        json != null) {
      Map<String, dynamic> odpPost = json.decode(response.body);
      if (odpPost['success'] != 'ok') {
        if (odpPost['zapis'] != 'ok') {
          _showAlert(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_WYSLANIE_REZYGNACJI_NIE'));
        } else {
          _showAlert(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_REZYGNACJE_PRZEKAZANO_ALE'));
        }
      } else {
        _showAlertOK(context, allTranslations.text('L_KOMUNIKAT'),
            allTranslations.text('L_REZYGNACJA_PRZEKAZANA'));
        //aktualizujKoszyk('3'); //czyszczenie koszyka na serwerze - akcja '3'
        //Navigator.of(context).pushNamed(OrderScreen.routeName);
      }
    } else {
      throw Exception('Failed to create OdpPost. z rezygnacji');
    }
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

  //pobranie (z serwera www) dań do zwybranego zamówienia
  Future<List<OrderMeal>> fetchOrderMealsFromSerwer() async {
    final zamId = ModalRoute.of(context).settings.arguments
        as String; //id zamówienia pobrany z argumentów trasy

    var url =
        'https://cobytu.com/cbt.php?d=f_dania_zamowienia&uz_id=${globals.deviceId}&re=${globals.memoryLokE}&za_id=$zamId&lang=${globals.language}';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return [];
      }

      //final List<MealRest> loadedRests = [];
      extractedData.forEach((numerPorzadkowy, zamData) {
        _dania.add(OrderMeal(
          np: numerPorzadkowy,
          ile: zamData['zm_ile'],
          nazwa: zamData['zm_nazwa'],
          cena: zamData['zm_cena'],
        ));
      });
      // _items = loadedRests;
      print('nazwa dania w order = $_dania');
      //notifyListeners();
      return _dania;
    } catch (error) {
      throw (error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    final zamId = ModalRoute.of(context).settings.arguments
        as String; //id zamówienia pobrany z argumentów trasy
    List<OrderItem> order = orderData.items.where((ord) {
      return ord.id.contains(zamId);
    }).toList(); //dane wybranego zamówienia

    var typZamowienia = allTranslations.text('L_DOSTAWA');
    if (order[0].typ == '1') if (order[0].kod != '')
      typZamowienia = allTranslations.text('L_DOSTAWA_MENU');
    else
      typZamowienia = allTranslations.text('L_ODBIOR_WLASNY');

    String platne;
    switch (order[0].platnosc) {
      case '0':
        platne = allTranslations.text('L_BRAK_DANYCH');
        break;
      case '1':
        platne = allTranslations.text('L_GOTOWKA');
        break;
      case '2':
        platne = allTranslations.text('L_KARTA');
        break;
      case '3':
        platne = allTranslations.text('L_ONLINE_M');
        break;
      default:
        platne = allTranslations.text('L_BRAK_DANYCH');
    }
    var ileDan = _dania.length;

    Color kolor = Color.fromRGBO(252, 255, 255, 1);
    switch (order[0].statusId) {
      case '0':
        kolor = const Color.fromRGBO(214, 234, 248, 1);
        break;
      case '1':
        kolor = const Color.fromRGBO(252, 243, 207, 1);
        break;
      case '2':
        kolor = const Color.fromRGBO(209, 242, 235, 1);
        break;
      case '3':
        kolor = const Color.fromRGBO(209, 242, 235, 1);
        break;
      case '31':
        kolor = const Color.fromRGBO(209, 242, 235, 1);
        break;
      case '4':
        kolor = const Color.fromRGBO(250, 219, 216, 1);
        break;
      case '5':
        kolor = const Color.fromRGBO(250, 219, 216, 1);
        break;
      case '51':
        kolor = const Color.fromRGBO(250, 219, 216, 1);
        break;
      case '6':
        kolor = const Color.fromRGBO(255, 255, 255, 1);
        break;
      case '7':
        kolor = const Color.fromRGBO(255, 255, 255, 1);
        break;
      case '71':
        kolor = const Color.fromRGBO(255, 255, 255, 1);
        break;
      case '80':
        kolor = const Color.fromRGBO(100, 100, 100, 1);
        break;
      case '90':
        kolor = const Color.fromRGBO(255, 255, 255, 1);
        break;
      default:
        kolor = Color.fromRGBO(255, 255, 255, 1);
    }

    //obliczenie wartości menu
    /*  double razemC = 0;
    for (var i = 0; i < cart.items.length; i++) {
      razemC = razemC + double.parse(cart.items[i].cena) ;
    }
    _cenaRazem = razemC.toStringAsFixed(2);
*/
    return Scaffold(
      backgroundColor: kolor,
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
//
                      Container(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
//rodzaj zamówienia: dostawa, odbiór własny
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
                                          typZamowienia,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                ),

                                SizedBox(
                                  height: 10,
                                ),
//dane zamówienia
                                Table(
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  //border: TableBorder.all(),
                                  columnWidths: {
                                    0: FractionColumnWidth(.0),
                                    1: FractionColumnWidth(.3),
                                    2: FractionColumnWidth(.7)
                                  },
                                  children: [
                                    TableRow(children: [
                                      //status
                                      TableCell(child: SizedBox(height: 25)),

                                      Text(
                                        allTranslations.text('L_STATUS') + ': ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        order[0].status,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
//info
                                    TableRow(children: [
                                      TableCell(child: SizedBox(height: 25)),
                                      Text(
                                        allTranslations.text('L_INFO') + ': ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        order[0].odp3,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
//data
                                    TableRow(children: [
                                      TableCell(child: SizedBox(height: 25)),
                                      Text(
                                        allTranslations.text('L_DATA') + ': ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        order[0].data + ' ' + order[0].godz,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
//adres
                                    if ((order[0].typ == '1') &&
                                        (order[0].kod != ''))
                                      TableRow(children: [
                                        TableCell(child: SizedBox(height: 25)),
                                        Text(
                                          allTranslations.text('L_ADRES') + ': ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          order[0].adres,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
//miasto
                                    if ((order[0].typ == '1') &&
                                        (order[0].kod != ''))
                                      TableRow(children: [
                                        TableCell(child: SizedBox(height: 25)),
                                        Text(
                                          allTranslations.text('L_MIASTO') + ': ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          order[0].miasto,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
//imie i nazwisko
                                    TableRow(children: [
                                      TableCell(child: SizedBox(height: 25)),
                                      Text(
                                        allTranslations.text('L_IMIE') + ': ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        order[0].imie + ' ' + order[0].nazwisko,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
//telefon
                                    TableRow(children: [
                                      TableCell(child: SizedBox(height: 25)),
                                      Text(
                                        allTranslations.text('L_TELEFON') + ': ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        order[0].telefon,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
//email
                                    TableRow(children: [
                                      TableCell(child: SizedBox(height: 25)),
                                      Text(
                                        allTranslations.text('L_EMAIL') + ': ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        order[0].email,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
//uwagi
                                    TableRow(children: [
                                      TableCell(child: SizedBox(height: 25)),
                                      Text(
                                        allTranslations.text('L_UWAGI') + ': ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        order[0].uwagi,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
//płatność
                                    TableRow(children: [
                                      TableCell(child: SizedBox(height: 25)),
                                      Text(
                                        allTranslations.text('L_PLATNOSC') + ': ',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        platne,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
//zamówione menu
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
                                          allTranslations.text('L_ZAMOWIONE_MENU'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                ),
                              ])),
//koszty
                      Container(
                          //padding: EdgeInsets.only(left: 20),
                          child: Column(
                        children: <Widget>[
                          Divider(
                            color: Colors.grey,
                          ),
//koszt poszczególnych dań
                          for (var i = 0; i < ileDan; i++) //dla kazdego dania
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      _dania[i].ile + ' x ' + _dania[i].nazwa,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    //cena dania
                                    children: <Widget>[
                                      Text(
                                        _dania[i].cena,
                                        //globals.separator == '.' ? _cenaRazem  : _cenaRazem.replaceAll('.', ','),
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
                                  //cena dania
                                  children: <Widget>[
                                    Text(
                                      (order[0].typ == '1') &&
                                              (order[0].kod != '')
                                          ? globals.separator == '.'
                                              ? order[0].koszt
                                              : order[0]
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
                                    allTranslations.text('L_RAZEM_M'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  //cena dania
                                  children: <Widget>[
                                    Text(
                                      globals.separator == '.'
                                          ? order[0].razem
                                          : order[0].razem.replaceAll('.', ',')

                                      //(order[0].typ == '1') && (order[0].kod != '')
                                      //? globals.separator == '.' ? (razemC + double.parse(_strefy[_wybranaStrefa - 1].koszt)).toStringAsFixed(2)  : (razemC + double.parse(_strefy[_wybranaStrefa - 1].koszt)).toStringAsFixed(2).replaceAll('.', ',')
                                      //: globals.separator == '.' ? _cenaRazem  : _cenaRazem.replaceAll('.', ',')
                                      ,
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
                          //SizedBox(height: 5),
                        ],
                      )),
//informacje dodatkowe
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(left: 20),
                        //color: Colors.grey[300],
                        //height: 38,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              /*                      RichText(
                          text: TextSpan(
                            children:[
                              TextSpan(
                                text:'Klikając Zamawiam potwierdzasz, ze jest Ci znana nasza ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,  
                                ),                             
                              ),
                              
                              TextSpan(
                                text: 'Polityka prywatności',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,                                  
                                ),                            
                                recognizer: TapGestureRecognizer()
                                ..onTap = (){launch('https://www.cobytu.com/index.php?d=polityka&mobile=1');
                                },
                              ),
                              
                              TextSpan(
                                text:' oraz ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,                                  
                                ),                              
                              ),

                              TextSpan(
                                text: 'Regulamin',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,                                  
                                ),                            
                                recognizer: TapGestureRecognizer()
                                ..onTap = (){launch('https://www.cobytu.com/index.php?d=regulamin&mobile=1');
                                },
                              ),
                              
                              TextSpan(
                                text:'.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,                                  
                                ),                              
                              ),
                            ]
                          ),
                        ),
*/
                              Visibility(
                                visible: order[0].statusId == '0' ||
                                    order[0].statusId == '1',
                                child: Container(
                                  height: 70,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      MaterialButton(
                                        shape: const StadiumBorder(),
                                        onPressed: () {
                                          wyslijRezygnacje(order[0].id,
                                              order[0].typ, order[0].email);

                                          print('rezygnacja !!!!!!!!!!');

                                          //Navigator.of(context).pushNamed(OrderScreen.routeName);
                                        },
                                        child: Text('   ' + allTranslations.text('L_REZYGNUJE') + '   '),
                                        color: Theme.of(context).primaryColor,
                                        textColor: Colors.white,
                                        disabledColor: Colors.grey,
                                        disabledTextColor: Colors.white,
                                      ),
                                    ],
                                  ),
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
