import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej

//podkategoria

class Podkat { 
  final String id;             //pk_id
  final String kolejnosc;      //pk_kolejnosc
  final String kaId;         //pk_ka_id 
  final String nazwa;          //pk_nazwa
  
  Podkat({
    @required this.id,
    @required this.kolejnosc,
    @required this.kaId,
    @required this.nazwa,
  });
}

class Podkategorie with ChangeNotifier{  
  List<Podkat> _items = []; //lista podkategorii

  List<Podkat> get items{ //getter który zwraca kopię zmiennej _items
    return [..._items]; //... - operator rozprzestrzeniania
  }

  //metoda szukająca dania o danym id - przeniesiona z meal_detail_screen.dart
  //Meal findById(String id) {
 //   return _items.firstWhere((ml) => ml.id ==  id);
 // }

  //pobranie podkategorii z serwera www
  static Future<void> fetchPodkategorieFromSerwer(String url) async {
    //const url = 'https://cobytu.com/cbt.php?d=f_podkategorie&lang=pl';
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      
      extractedData.forEach((pkId, pkData) {
        //zapis dania do bazy
        DBHelper.insert('podkategorie', {
        'id': pkId,                         
        'kolejnosc': pkData['pk_kolejnosc'],        
        'kaId': pkData['pk_ka_id'],         
        'nazwa': pkData['pk_nazwa'],       
        });
      });
      
    } catch (error) {
      throw (error);
    }
  }

  //pobranie podkategorii z bazy lokalnej
  Future<void> fetchAndSetPodkategorie()async{
    final dataList = await DBHelper.getData('podkategorie');
    _items = dataList
      .map(
        (item) => Podkat(
          id: item['id'], 
          kolejnosc: item['kolejnosc'],     
          kaId: item['kaId'],          
          nazwa: item['nazwa'],  
        ),
      ).toList();
      print(_items);
    notifyListeners();
  }
  
  //usuwanie wszystkich dań z bazy lokalnej
  static Future<void> deleteAllPodkategorie()async{
     await DBHelper.deleteTable('podkategorie');

  }

}