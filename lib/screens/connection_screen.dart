import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;
import '../all_translations.dart';
import 'dart:convert'; //obsługa json'a
import '../screens/meals_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionScreen extends StatefulWidget {
  static const routeName = '/connection';

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  //List<Zamowienie> _zamowienia = [];
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  final _formKey2 = GlobalKey<FormState>();
  String _uzLogin = ''; //login do konta połączonego z aplikacją

  @override
  void didChangeDependencies() {
    print('init connection - połączenie z kontem na cobytu.com');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });

      wyslijKod('test_deviceId').then((_) {
        //jeeli jest połączenie tego telefonu to uz_login = login połączonego konta

        setState(() {
          _isLoading = false; //zatrzymanie wskaznika ładowania danych
        });
      });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  //wysyłanie kodu połączenia apki z kontem na cobytu.com
  Future<void> wyslijKod(
    String kod,
  ) async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_polacz.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "kod_mobile": kod,
        "deviceId": globals.deviceId,
      }),
    );
    print(response.body);
    if (response.statusCode >= 200 &&
        response.statusCode <= 400 &&
        json != null) {
      Map<String, dynamic> odpPost = json.decode(response.body);
      if (odpPost['success'] != 'ok') {
        if (kod != 'test_deviceId') {
          //jezeli nie był to test połączenia (tylko próba połączenia)
          _showAlert(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_POLACZENIE_ERROR'));
        } else {
          globals.uzLogin = ''; //kasowanie loginu bo nie wiadomo czy jest połączenie
          print('brak połączenie tej apki z kontem na cobytu.com');
        }
      } else {
        //jezeli odpowiedz "ok"
        if (kod == 'test_deviceId') {
          _uzLogin = odpPost[
              'uz_login']; //jest połączenie i zostanie wybrana część mówiąca o połaczeniu
          globals.uzLogin =
              _uzLogin; //zapamiętanie (przeładowanie) loginu uzytkownika
        } else if (kod == 'rozlacz') {
          //jezeli było to rozłaczenie
          _showAlertOK(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_ROZLOCZENIE_OK') + odpPost['uz_login']);
          globals.uzLogin = ''; //kasowanie loginu w zmiennej globalnej
        } else {
          //jezeli nie był to test połączenia ani rozłaczenie (tylko połączenie i to udane)
          _showAlertOK(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_POLACZENIE_OK') + odpPost['uz_login']);
          globals.uzLogin =
              odpPost['uz_login']; //zapisanie loginu do zmiannej globalnej
        }
        //Navigator.of(context).pushNamed(OrderScreen.routeName);
      }
    } else {
      throw Exception('Failed to create OdpPost. z połączenia konta z apką');
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
              _setPrefers('reload',
                  'true'); //dane nieaktualne - trzeba przeładować dane z serwera
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

  //ustawienianie zmiennych globalnych
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }

  @override
  Widget build(BuildContext context) {
    //final specialData = Provider.of<Specials>(context, listen: false);
    //List<SpecialItem> specials = specialData.items.toList();
    //print('zamowienia = ${orders[0].typText}');

    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('L_POLACZENIE_APKA_KONTO')),
      ),
      body: _isLoading //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          : _uzLogin == '' //jezeli nie ma loginu to znaczy ze nie ma połaczenia
              ? Center(
                  child: Column(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        allTranslations.text('L_BRAK_POLACZENIA'),
                        style: TextStyle(
                          fontSize: 15,
                          //color: Colors.grey,
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey2,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                            //initialValue: globals.numer,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: allTranslations.text('L_KOD_POLACZ'),
                              labelStyle: TextStyle(color: Colors.black),
                              //hintText: allTranslations
                              //.text('L_WPISZ_KOD_POLACZ'),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return allTranslations
                                    .text('L_WPISZ_KOD_POLACZ');
                              }
                              globals.kodMobile = value;
                              return null;
                            }),
                      ),
                    ),
                    Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MaterialButton(
                            shape: const StadiumBorder(),
                            onPressed: () {
                              if (_formKey2.currentState.validate()) {
                                //jezeli formularz wypełniony poprawnie
                                wyslijKod(globals.kodMobile);
                              }
                              //Navigator.of(context).pushNamed(OrderScreen.routeName);
                            },
                            child: Text('   ' +
                                allTranslations.text('L_WYSLIJ_KOD') +
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
              : //jezeli jest login to znaczy ze jest połaczenie
              Center(
                  child: Column(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        allTranslations.text('L_JEST_POLACZENIE') +
                            _uzLogin +
                            allTranslations.text('L_CZY_ROZLACZYC'),
                        style: TextStyle(
                          fontSize: 15,
                          //color: Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MaterialButton(
                            shape: const StadiumBorder(),
                            onPressed: () {
                              wyslijKod('rozlacz');

                              //Navigator.of(context).pushNamed(OrderScreen.routeName);
                            },
                            child: Text('   ' +
                                allTranslations.text('L_ROZLACZ') +
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
                ),
    );
  }
}
