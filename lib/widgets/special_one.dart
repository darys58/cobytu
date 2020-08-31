import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity/connectivity.dart'; //czy jest Internet
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej

import '../all_translations.dart';
import '../models/specials.dart';
import '../screens/tabs_detail_screen.dart';


class SpecialOne extends StatelessWidget {

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
    final promocja = Provider.of<SpecialItem>(context,
        listen: false); //dostawca danych dostarcza danie z słuchaczem zmian.

    //final meal = Provider.of<Meal>(context,
    //listen: false); //dostawca danych dostarcza danie z słuchaczem zmian.

    return InkWell(
      //element klikalny
      onTap: () {
        if (promocja.daId != '0') {
          //jezeli jest to dania z MENU
          //czy jest Internet?
          _isInternet().then((inter) {
            if (inter != null && inter) { //jezeli jest internet
              //pobranie dania z bazy lokalnej
              DBHelper.getMeal(promocja.daId).then((danie) {
                //print(danie.asMap()[0]['nazwa']);
                if (danie == null) {
                  print("nie ma takiego dania");
                   _showAlertAnuluj(
                  context,
                  allTranslations.text('L_UPS'),
                  allTranslations.text('L_DANIE_USUNIETE'));
                }else{
                  //przejście do szczegółów dania
                  Navigator.of(context).pushNamed(
                    TabsDetailScreen.routeName,
                    arguments: promocja.daId,
                  );
                }
              });
            } else {
              print('braaaaaak internetu');
              _showAlertAnuluj(
                  context,
                  allTranslations.text('L_BRAK_INTERNETU'),
                  allTranslations.text('L_URUCHOM_INTERNETU'));
            } //if internet
          });
        }
      },

      child: Card(
        //karta z promocją
        //color: kolor, //kolor fiszki zamówienia
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
                        EdgeInsets.all(10.00), //margines wokół części tekstowej
                    child: Column(
                      //ustawienie elementów jeden pod drugim - tytuł i opis
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //MENU/INFO
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              //nazwa dania
                              (promocja.daId != '0') ? 'MENU' + ' - ' + promocja.resta  : "INFO" + ' - ' + promocja.resta ,
                              style: TextStyle(fontSize: 16, color: Colors.grey
                                  //fontWeight: FontWeight.bold,
                                  ),
                              softWrap: false, //zawijanie tekstu
                              overflow: TextOverflow
                                  .fade, //skracanie tekstu zeby zmieścił sie
                            ),
                      /*      Text(
                              //nazwa dania
                              promocja.resta,
                              style: TextStyle(fontSize: 16, color: Colors.grey
                                  //fontWeight: FontWeight.bold,
                                  ),
                              softWrap: false, //zawijanie tekstu
                              overflow: TextOverflow
                                  .fade, //skracanie tekstu zeby zmieścił sie
                            ),
                      */    ],
                        ),
//tytul
                        Container(
                          //pojemnik na opis
                          padding: EdgeInsets.only(top: 4),
                          height: 22,
                          child: Text(
                            //opis dania
                            promocja.tytul,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
//opis
                        Padding(
                          //odstępy dla wiersza ej
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            promocja.opis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            softWrap: true, //zawijanie tekstu
                            maxLines: 6, //ilość wierszy opisu
                            overflow: TextOverflow
                                .ellipsis, //skracanie tekstu zeby zmieścił sie
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //SizedBox(
                //   width: 15,
                // ),
                if (promocja.daId != '0')
                     Icon(Icons.chevron_right),
                  
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
