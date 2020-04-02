//widget pojedynczego elementu listy dań (165)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //pakiet dostawcy

import '../screens/tabs_detail_screen.dart';
import '../models/meal.dart';
import '../models/mems.dart';
import '../models/detailRest.dart';


class MealItem extends StatelessWidget {

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
  @override
  Widget build(BuildContext context) {
    final meal = Provider.of<Meal>(context, listen: false); //dostawca danych dostarcza danie z słuchaczem zmian. Zmiana nastąpi jezeli naciśniemy serce polubienie dania. Z listen: false zmieniony na tylko dostawcę danych a słuchacz lokalny "Consumer" zainstalowany  nizej
  //print(meal.foto.substring(27));

  return InkWell( //element klikalny
      onTap: () {
        Mems.insertMemory( //zapisanie danych wybranego dania przed przejściem do jego szczegółów               
          'memDanie',        //nazwa
          meal.id,           //a - daId
          meal.foto,         //b - foto
          meal.alergeny,     //c - alergeny
          meal.nazwa,        //d - nazwa dania
          '0',               //e - index wersji dania   (w iOS - index row)
          meal.fav,          //f - fav - polubienie
        );
        //pobranie danych restauracji z serwera (potrzebne modMenu - info kiedy była modyfikacja menu)
        //!!!@!!!!  jeeli ok to przejście do szczegółów

          Navigator.of(context).pushNamed(TabsDetailScreen.routeName, arguments: meal.id,);
       


        
      },//() => selectMeal(context),
      child: Card( //karta z daniem
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
                    padding: EdgeInsets.all(8.00), //margines wokół części tekstowej
                    child: Column( //ustawienie elementów jeden pod drugim - tytuł i opis
                      mainAxisSize:MainAxisSize.min, 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: <Widget>[
                        Text( //nazwa dania
                          meal.nazwa,
                          style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context).primaryColor,
                          ),
                          softWrap: false, //zawijanie tekstu
                          overflow: TextOverflow.fade, //skracanie tekstu zeby zmieścił sie
                          ),
                        Container( //pojemnik na opis
                          padding: EdgeInsets.only(top: 2),
                          height: 38,
                          child: Text( //opis dania
                            meal.opis,
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
                            mainAxisAlignment:
                              MainAxisAlignment.spaceAround, //główna oś wyrównywania
                            children: <Widget>[ //elementy rzędu które sa widzetami
                              Row( //cena dania
                                children: <Widget>[
                                  Text(
                                    meal.cena, //interpolacja ciągu znaków
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ), 
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ), //odległość miedzy ceną a PLN
                                  Text(
                                    'PLN', //interpolacja ciągu znaków
                                    style: TextStyle(
                                      //fontSize: 15,
                                      color: Colors.black,
                                    ), 
                                  ),  
                                ],
                              ),
                              Row(// czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                                children: <Widget>[
                                  Icon(
                                    Icons.hourglass_empty, color: Theme.of(context).primaryColor, //schedule
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ), //odległość miedzy ikoną i tekstem
                                  Text(
                                    meal.czas + ' min',
                                  ), //interpolacja ciągu znaków
                                ],
                              ),
                    /*          if(meal.foto.substring(27) == '/co.jpg')
                              Row(// czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                                children: <Widget>[
                                  Icon(
                                    Icons.battery_alert, color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ), //odległość miedzy ikoną i tekstem
                                  Text(
                                    meal.kcal + ' kcal',
                                  ), //interpolacja ciągu znaków
                                ],
                              ),
                       */       Row(//polubienie - Kazdy element wiersz jest wierszemonym z ikony i tekstu                            
                                children: <Widget>[ 
                                  Consumer<Meal>( // słuchacz na wybranym widzecie (kurs sklep  197)
                                    builder: (context, meal, child) => GestureDetector(
                                      child: Icon(meal.fav == '1' ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).primaryColor,), //zmiana ikony
                                      onTap: (){
                                        meal.toggleFavoriteStatus(meal.id); //przekazane id dania
                                      },                 
                                    ),
                                  ),
                                ],
                              ),
                              //zamiast zaślepki foto
                              if(meal.foto.substring(27) == '/co.jpg') //jezeli zaślepka
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
                if(meal.foto.substring(27) != '/co.jpg') //jezeli jest foto
                  Container( //pojemnik na zdjęcie
                    //padding: EdgeInsets.only(right: 1.00),
                    child: ClipRRect( //element opakowania obrazka zeby zaokrąglić rogi
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(//obrazek dania pobierany z neta
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
