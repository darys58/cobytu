import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //obsługa json'a
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../globals.dart' as globals;
import '../all_translations.dart';

class CartOne extends StatefulWidget { //dane lokalne dla pojedynczego elementu zamówienia (to nie Cart)
  final int index; //index dania na liście List<CartItem>
  final String id;      //ko_id
  final String daId;    //da_id
  final String nazwa;   //da_nazwa
  final String opis;    //da_opis
   int ile;        //ko_ile
   String cena;    //ko_cena
  final String waga;    //ko_waga
  final String kcal; 
  
  //konstruktor
  CartOne(
    this.index,
    this.id, 
    this.daId, 
    this.nazwa, 
    this.opis, 
    this.ile,
    this.cena,
    this.waga,
    this.kcal,
  );

  @override
  _CartOneState createState() => _CartOneState();
}

class _CartOneState extends State<CartOne> {
  final String _currLang = allTranslations.currentLanguage; //aktualny język


  //wysyłanie zmiany ilości dania w koszyku do serwera www
  Future<void> aktualizujKoszyk(String akcja) async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_do_koszyka.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{      
        'ko_id': widget.id,
        'ko_akcja': akcja,
      }),
    );
    //print(response.body);
    if (response.statusCode >= 200 && response.statusCode <= 400 && json != null) {
      //pobranie zawartości koszyka w celu aktualizacji wyswietlanych danych
      Provider.of<Cart>(context).fetchAndSetCartItems('https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLok_e}&lang=pl');  //zawartość koszyka z www             
    } else {
      throw Exception('Failed to create OdpPost.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context); 

    return Dismissible( //przesuwanie karty w celu usuniecia
      key: ValueKey(widget.id),
      background: Container(
        color: Colors.red,
        child: Icon (
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin : EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction){
        aktualizujKoszyk('3');//usunięcie dania z koszyka
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.ltr, 
          children: <Widget>[
            
            //kolumna z przyciskami ilości dania
            Column(
              children:[
                Container(
                  padding: const EdgeInsets.all(0.0),
                  height: 40.0,
                  child: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    icon: Icon(
                      Icons.add_circle_outline //przycisk +
                    ),
                    iconSize: 30.0,
                    onPressed: (){
                      setState(() {
                        aktualizujKoszyk('1'); //inkrementacja dania do koszyka na serwerze - akcja '1'
                        widget.ile = widget.ile + 1; //zeby zmiana pokazywała się od razu
                      });
                    },
                  ),
                ),
          
                Text(
                  widget.ile.toString(),   //ilość dań na stoliku
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
           
                Container(
                  padding: const EdgeInsets.all(0.0),
                  height: 40.0,
                  child: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    icon: Icon(
                      Icons.remove_circle_outline //przycisk -
                    ),
                    iconSize: 30.0,
                    onPressed: (){
                      setState(() {
                        if (widget.ile > 0) {
                          aktualizujKoszyk('2'); //dekrementacja dania z koszyka na serwerze - akcja '2'
                          widget.ile = widget.ile - 1; //zeby zmiana pokazywała sie od razu
                        }
                      });
                    },
                  ),
                ), 
              ]
            ),
           
            //kolumna z tytułe, opisem itd.
            Expanded( //powoduje dopasowanie kolumny do wolnego miejsca
              child: Column( //ustawienie elementów jeden pod drugim - tytuł i opis
                mainAxisSize:MainAxisSize.min, 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text( //nazwa dania
                    widget.nazwa,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    softWrap: false, //zawijanie tekstu
                    overflow: TextOverflow.fade, //skracanie tekstu zeby zmieścił sie
                    ),
                  Container( //pojemnik na opis
                    padding: EdgeInsets.only(top: 5),
                    height: 41,
                    child: Text( //opis dania
                      widget.opis,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                      softWrap: true, //zawijanie tekstu
                      maxLines: 2, //ilość wierszy opisu
                      overflow: TextOverflow.ellipsis, //skracanie tekstu zeby zmieścił sie
                    ),
                  ),
                  Padding(//odstępy dla wiersza z ikonami
                    padding: EdgeInsets.only(top: 5),
                    child: Row( //rząd z informacjami o posiłku
                    mainAxisAlignment: MainAxisAlignment.end,
                    
                      children: <Widget>[ //elementy rzędu które sa widzetami
                        Row( //cena dania
                          children: <Widget>[
                            Text(
                              globals.separator == '.' ? cart.items[widget.index].cena  : cart.items[widget.index].cena.replaceAll('.', ','), //meal.cena, //interpolacja ciągu znaków
                            ),
                            SizedBox(
                              width: 2,
                            ), //odległość miedzy ceną a PLN
                            Text(
                              allTranslations.text('L_PLN'), //interpolacja ciągu znaków
                            ), 
                            SizedBox(
                              width: 25,
                            ), 
                          ],
                        ),
                        
                        Row(// waga- Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                          children: <Widget>[
                            //Icon(
                           //   Icons.hourglass_empty, color: Theme.of(context).primaryColor, //schedule
                           // ),
                            SizedBox(
                              width: 2,
                            ), //odległość miedzy ikoną i tekstem
                            Text(
                              widget.waga + ' ' + allTranslations.text('L_G'),
                            ), 
                            SizedBox(
                              width: 25,
                            ),//interpolacja ciągu znaków
                          ],
                        ),
                        Row(// kcal - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                          children: <Widget>[
                           // Icon(
                           //   Icons.hourglass_empty, color: Theme.of(context).primaryColor, //schedule
                           // ),
                            SizedBox(
                              width: 2,
                            ), //odległość miedzy ikoną i tekstem
                            Text(
                              widget.kcal + ' ' + allTranslations.text('L_KCAL'),
                            ), //interpolacja ciągu znaków
                            SizedBox(
                              width: 25,
                            ),
                          ],
                        ),
                     Row(//polubienie - Kazdy element wiersz jest wierszemonym z ikony i tekstu                            
                          children: <Widget>[ 
                            
                          ],
                        ),                    
                      ],
                    ),
                  ),
                ],
              ),
            ),  
          ],
        ),      
      ),
    );
  }
}