import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../globals.dart' as globals;
import '../all_translations.dart';
import '../models/order.dart';
import '../screens/order_detail_screen.dart';

class OrderOne extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final zamowienie = Provider.of<OrderItem>(context, listen: false); //dostawca danych dostarcza danie z słuchaczem zmian. 
  
    Color kolor = Color.fromRGBO(252, 255, 255, 1);
    switch (zamowienie.statusId) {
      case '0': kolor = const Color.fromRGBO(214, 234, 248, 1); break;
      case '10': kolor = const Color.fromRGBO(252, 243, 207, 1); break; 
      case '20': kolor = const Color.fromRGBO(209, 242, 235, 1); break;
      case '30': kolor = const Color.fromRGBO(209, 242, 235, 1); break; 
      case '31': kolor = const Color.fromRGBO(209, 242, 235, 1); break;
      case '40': kolor = const Color.fromRGBO(250, 219, 216, 1); break; 
      case '50': kolor = const Color.fromRGBO(250, 219, 216, 1); break;
      case '51': kolor = const Color.fromRGBO(250, 219, 216, 1); break; 
      case '60': kolor = const Color.fromRGBO(255, 255, 255, 1); break;
      case '70': kolor = const Color.fromRGBO(255, 255, 255, 1); break; 
      case '71': kolor = const Color.fromRGBO(255, 255, 255, 1); break;
      case '80': kolor = const Color.fromRGBO(100, 100, 100, 1); break;
      case '90': kolor = const Color.fromRGBO(255, 255, 255, 1); break;
    default:
        kolor = Color.fromRGBO(255, 255, 255, 1);
    }

    return InkWell( //element klikalny
      onTap: () {
        Navigator.of(context).pushNamed(OrderDetailScreen.routeName, arguments: zamowienie.id,); 
      },

      child: Card( //karta z daniem
      color: kolor, //kolor fiszki zamówienia
        shape: RoundedRectangleBorder( //kształt karty
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4, //cień za kartą
        margin: EdgeInsets.all(7), //margines wokół karty     
        child: Column( //zawartość karty - kolumna z widzetami
          children: <Widget>[         
            Row( //całą zawatość kolmny stanowi wiersz
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
              children: <Widget>[
                Expanded( //rozszerzona kolumna z tekstami  - cała dostępna przestrzeń (poza zdjęciem)
                  child: Container( //zeby zrobić margines wokół części tekstowej
                    padding: EdgeInsets.all(10.00), //margines wokół części tekstowej
                    child: Column( //ustawienie elementów jeden pod drugim - tytuł i opis
                      mainAxisSize:MainAxisSize.min, 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: <Widget>[
                        Text( //nazwa dania
                          (zamowienie.typ == '1') && (zamowienie.kod != '')                         
                          ? zamowienie.typText + '   ' + zamowienie.data
                          : allTranslations.text('L_ODBIOR_WLASNY') + '   ' + zamowienie.data,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: false, //zawijanie tekstu
                          overflow: TextOverflow.fade, //skracanie tekstu zeby zmieścił sie
                          ),
                        Container( //pojemnik na opis
                          padding: EdgeInsets.only(top: 2),
                          height: 20,
                          child: Text( //opis dania
                            allTranslations.text('L_NA_GODZ') + '  ' + zamowienie.godz,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            softWrap: true, //zawijanie tekstu
                            maxLines: 2, //ilość wierszy opisu
                            overflow: TextOverflow.ellipsis, //skracanie tekstu zeby zmieścił sie
                          ),
                        ),
                        Padding(//odstępy dla wiersza ej
                          padding: EdgeInsets.only(top: 5),
                          child: Row( //rząd z informacjami o posiłku
                            mainAxisAlignment:
                              MainAxisAlignment.start , //główna oś wyrównywania
                            children: <Widget>[ //elementy rzędu które sa widzetami
                              Row( //cena dania
                                children: <Widget>[
                                  Text(
                                    allTranslations.text('L_WARTOSC_ZMOWIENIA') + ': ', //interpolacja ciągu znaków
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ), 
                                  ),  
                                  Text(
                                    globals.separator == '.' ? zamowienie.razem  : zamowienie.razem.replaceAll('.', ','), //meal.cena, //interpolacja ciągu znaków
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ), 
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ), //odległość miedzy ceną a PLN
                                  Text(
                                    allTranslations.text('L_PLN'), //interpolacja ciągu znaków
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ), 
                                  ),  
                                ],
                              ),
                     
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                (zamowienie.typ == '1') && (zamowienie.kod != '')  
                ? Image.asset('assets/images/dostawa.png')
                : Image.asset('assets/images/jedzenie.png'),
                SizedBox(
                  width: 15,
                ),
                Icon(Icons.chevron_right), 
                SizedBox(
                  width: 15,
                ),             
              ],
            ),
          ],
        ),
      ),
    );
  }
}