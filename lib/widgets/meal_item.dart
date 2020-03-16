//widget pojedynczego elementu listy dań (165)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //pakiet dostawcy

import '../screens/meal_detail_screen.dart';
import '../models/meal.dart';

class MealItem extends StatelessWidget {
 /* final String id;          
  final String  nazwa; 
  final String  opis; //'Pier\u015b z kurczaka w sosie \u015bmietanowym z zielonym pieprzem',      
  //final String  idwer: '0',        
  //final String  wersja: '',       
  final String  foto;        
  //final String  gdzie;       
  final String  kategoria;    
  //final List<String>  podkat;  
  //final String  srednia;     
  //final String  alergeny;      
  final String  cena;           
  final String  czas;        
  final String  waga;       
  final String  kcal;         
  //final String  lubi;          
  //final String  fav;           
  //final String  stolik;
  
  //final String id;
  //final String title;
  //final String imageUrl;
  //final int duration;
  //final Complexity complexity;
  //final Affordability affordability;
  //final Function removeItem;


  MealItem({
    @required this.id,
    @required this.nazwa,
    @required this.opis,
    @required this.foto,
    @required this.kategoria,
    @required this.cena,
    @required this.czas,
    @required this.waga,
    @required this.kcal,
   // @required this.fav,
    //@required this.removeItem,
  });
*/
/*
//funkcja przejścia do ekranu ze szczegółami dania
  void selectMeal(BuildContext context) {
    Navigator.of(context)
        .pushNamed( //pushNamed zwraca Future - obiekt który pozwala okreslić funkcję która powinna być wykonana po wykonaniu pewnej operacji np. wyświetlić strone na która chcesz się udać.
      MealDetailScreen.routeName, //tzn. MealDetailScreen to strona po wykonaniu pushNamed. Przyszły zwrot przez pushNamed pozwla wiedzieć kiedy strona na którą sie przełaczyłeś nie jest juz wyświetlana.
      arguments: id,
    ).then((result) { //result - id usuwanego przepisu (ikoną kosza). Funkca then wykonywana jest po powrocie z opusczanej strony (po wykonaniu pop).
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
    
    return InkWell( //element klikalny
      onTap: () {
            Navigator.of(context).pushNamed(MealDetailScreen.routeName, arguments: meal.id,);
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

                   /* 
                  ClipRRect( //belka po lewej - element opakowania obrazka zeby zaokrąglić rogi
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ),
                    child: Container( 
                      width: 10,
                      height: 110,
                      color: Colors.red, 
                    ),
                  ), */


                  Expanded( //rozszerzona kolumna z tekstami  - cała dostępna przestrzeń (poza zdjęciem)
                    child: Container( //zeby zrobić margines wokół części tekstowej
                      padding: EdgeInsets.all(8.00),
                      child: Column( //ustawienie elementów jeden pod drugim
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
                              Row(
                                //Kzdy element wiersz jest wierszemonym z ikony i tekstu
                                children: <Widget>[
                                  //Icon(
                                  //  Icons.schedule,
                                  //),
                                  Text(
                                    meal.cena, //interpolacja ciągu znaków
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ), 
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ), //odległość miedzy ikoną i tekstem
                                  Text(
                                    'PLN', //interpolacja ciągu znaków
                                    style: TextStyle(
                                      //fontSize: 15,
                                      color: Colors.black,
                                    ), 
                                  ),  
                                ],
                              ),
                              Row(
                                //Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu
                                children: <Widget>[
                                  Icon(
                                    Icons.schedule, color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(
                                    width: 1,
                                  ), //odległość miedzy ikoną i tekstem
                                  Text(
                                    meal.czas + ' min',
                                  ), //interpolacja ciągu znaków
                                ],
                              ),
                              Row(
                                //Kazdy element wiersz jest wierszemonym z ikony i tekstu
                                children: <Widget>[
                                  
                                  Consumer<Meal>( // słuchacz na wybranym widzecie (kurs sklep  197)
                                    builder: (context, meal, child) => GestureDetector(
                                      child: Icon(meal.fav == '1' ? Icons.favorite : Icons.favorite_border, color: Theme.of(context).primaryColor,), //zmiana ikony
                                      onTap: (){
                                        meal.toggleFavoriteStatus(meal.id); //przekazane id dania
                                      },
                                      
                                    ),
                                  ),
                                  
                                  
                                  /*
                                  IconButton(
                                     icon: Icon(
                                      meal.fav == '1' ? Icons.favorite : Icons.favorite_border
                                    ),
                                    onPressed: (){
                                      meal.toggleFavoriteStatus();
                                    },
                                  ),
                                  
                                  */
                                  //SizedBox(
                                  //  width: 6,
                                  //), //odległość miedzy ikoną i tekstem
                                  //Text(
                                   // kcal,
                                  //), //interpolacja ciągu znaków
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                     
                    ),
                  ),
                  Container(
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
