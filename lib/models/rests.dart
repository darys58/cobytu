import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import './rest.dart';

class Rests with ChangeNotifier{  
  List<Rest> _items = [];
  
  List<Rest> get items{ //getter który zwraca kopię zmiennej _items
  //print('items w Rests $_items');
    return [..._items]; //... - operator rozprzestrzeniania
  }

   //metoda szukająca restauracji o danym id - z map_screen
  Rest findById(String id) {
    return _items.firstWhere((ml) => ml.id ==  id);
  }

  //pobranie restauracji dla wybranego miasta z bazy lokalnej
  Future<void> fetchAndSetRests(String miasto)async{
    final dataList = await DBHelper.getRests(miasto);
    _items = dataList
      .map(
        (item) => Rest(
          id: item['id'],          
          nazwa: item['nazwa'], 
          obiekt: item['obiekt'],     
          adres: item['adres'],        
          miaId: item['miaId'],       
          miasto: item['miasto'],          
          wojId: item['wojId'],        
          woj: item['woj'], 
          latitude: item['latitude'],
          longitude: item['longitude'], 
          online: item['online'],   
          dostawy: item['dostawy'],   
          opakowanie: item['opakowanie'],      
          doStolika: item['doStolika'],      
          rezerwacje: item['rezerwacje'],            
          mogeJesc: item['mogeJesc'],          
          modMenu: item['modMenu'],         
        ),  
      ).toList();
      notifyListeners();

      //print('items w Rests $_items');
  }
  
  
  
  //pobranie bazy restauracji z serwera www
  static Future<void> fetchRestsFromSerwer() async {
    const url = 'https://www.cobytu.com/cbt.php?d=f_restauracje';
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      
      extractedData.forEach((restId, restData) {
        //zapis restauracji do bazy
        DBHelper.insert('restauracje', {
        'id': restId,
        'nazwa': restData['re_nazwa'], 
        'obiekt': restData['re_obiekt'],     
        'adres': restData['re_adres'],        
        'miaId': restData['re_mia_id'],       
        'miasto': restData['re_miasto'],          
        'wojId': restData['re_woj_id'],        
        'woj': restData['re_woj'], 
        'latitude': restData['re_latitude'],
        'longitude': restData['re_longitude'], 
        'online': restData['re_online'],
        'dostawy': restData['re_dostawy'],   
        'opakowanie': restData['re_opakowanie'],      
        'doStolika': restData['re_do_stolika'],      
        'rezerwacje': restData['re_rezerwacje'],            
        'mogeJesc': restData['re_moge_jesc'],          
        'modMenu': restData['re_mod_menu'],         
        });
      });
      
    } catch (error) {
      throw (error);
    }
  }

  //usuwanie wszystkich restauracji z bazy lokalnej
  static Future<void> deleteAllRests()async{
     await DBHelper.deleteTable('restauracje');
  }
  

} 
// JSON odbierany z 'https://www.cobytu.com/cbt.php?d=f_restauracje';
// {11: {re_nazwa: Bazylia, re_obiekt: Stare Miasto, re_adres: Stradomska 13, re_mia_id: 3, re_miasto: Kraków, re_woj_id: 7, re_woj: małopolskie, re_dostawy: 0, re_opakowanie: 0.00, re_do_stolika: 0, re_rezerwacje: 0, re_moge_jesc: 0, re_mod_menu: 0}, 
//  27: {re_nazwa: Borówka, re_obiekt: Stary Konin, re_adres: 3 Maja 35, re_mia_id: 1, re_miasto: Konin, re_woj_id: 14, re_woj: wielkopolskie, re_dostawy: 1, re_opakowanie: 1.00, re_do_stolika: 0, re_rezerwacje: 1, re_moge_jesc: 0, re_mod_menu: 1583967600}, 
//  17: {re_nazwa: Czarny Staw, re_obiekt: Centrum, re_adres: Krupówki 2, re_mia_id: 4, re_miasto: Zakopane, re_woj_id: 7, re_woj: małopolskie, re_dostawy: 0, re_opakowanie: 0.00, re_do_stolika: 0, re_rezerwacje: 0, re_moge_jesc: 0, re_mod_menu: 1580979201}, 
//   9: {re_nazwa: Egao Sushi, re_obiekt: Nowy Konin, re_adres: Przemysłowa 10, re_mia_id: 1, re_miasto: Konin, re_woj_id: 14, re_woj: wielkopolskie, re_dostawy: 0, re_opakowanie: 0.00, re_do_stolika: 0, re_rezerwacje: 0, re_moge_jesc: 0, re_mod_menu: 0},