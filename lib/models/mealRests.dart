//dane dań
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import './mealRest.dart';

class MealRests {  
  List<MealRest> _items = []; 
    
  List<MealRest> get items{ //getter który zwraca kopię zmiennej _items
    return [..._items]; //... - operator rozprzestrzeniania
  }

  //pobranie (z serwera www) restauracji serwujących wybrane danie - dla szczegółów dania
  static Future<List<MealRest>> fetchMealRestsFromSerwer(String idDania) async {
    var url = 'https://cobytu.com/cbt.php?d=f_danie_resta&danie=$idDania&lang=pl';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
     // if (extractedData == null) {
     //   return[];
     // }

      final List<MealRest> loadedRests = [];
      extractedData.forEach((restId, restData) {
        loadedRests.add(MealRest(
          id: restId,
          logo: restData['re_logo'], 
          nazwa: restData['re_nazwa'],       
          obiekt: restData['re_obiekt'],   
          adres: restData['re_adres'],       
          kod: restData['re_kod'], 
          miasto: restData['re_miasto'], 
          woj: restData['re_woj'], 
          tel1: restData['re_tel1'], 
          tel2: restData['re_tel2'], 
          email: restData['re_email'], 
          www: restData['re_www'], 
          gps: restData['re_gps'], 
          otwarteA: restData['re_otwarte_a'], 
          otwarteB: restData['re_otwarte_b'], 
          otwarteC: restData['re_otwarte_c'], 
          cena: restData['cena'], 
          parking: restData['re_parking'], 
          pojazd: restData['re_podjazd'], 
          wynos: restData['re_na_wynos'], 
          karta: restData['re_p_karta'], 
          zabaw: restData['re_s_zabaw'], 
          letni: restData['re_o_letni'], 
          klima: restData['re_klima'], 
          wifi: restData['re_wifi'],  
          modMenu: restData['re_mod_menu'],  
        ));
      });
     // _items = loadedRests;
      print('dane restauracji w MealRests = ${loadedRests[0].nazwa}');
      //notifyListeners();
    return loadedRests;
    } catch (error) {
      throw (error);
    }
  }

}