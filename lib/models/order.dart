import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //obsługa json'a

import '../globals.dart' as globals;
import '../all_translations.dart';

class OrderItem with ChangeNotifier{
  final String id;        //za_id
  final String typ;       //za_typ: String
  final String typText;   //za_typ_text: String
  final String data;      //za_data: String
  final String odp3;      //za_odp3: String
  final String odp4;      //za_odp4: String
  final String godz;      //za_godz: String
  final String adres;     //za_adres: String
  final String numer;     //za_numer: String
  final String kod;       //za_kod: String
  final String miasto;    //za_miasto: String
  final String miejsc;    //za_miejsc: String
  final String czas;      //za_czas: String
  final String imie;      //za_imie: String
  final String nazwisko;  //za_nazwisko: String
  final String telefon;   //za_telefon: String
  final String email;     //za_email: String
  final String uwagi;     //za_uwagi: String
  final String platnosc;  //za_platnosc: String
  final String koszt;     //za_koszt: String
  final String moge;      //za_moge: String
  final String lang;      //za_lang: String
  final String razem;     //cena_razem: String
  final String statusId;  //za_status_id: String
  final String status;    //za_status: String

  OrderItem({
    @required this.id,
    @required this.typ,
    @required this.typText,
    @required this.data,
    @required this.odp3,
    @required this.odp4,
    @required this.godz,
    @required this.adres,
    @required this.numer,
    @required this.kod,
    @required this.miasto,
    @required this.miejsc,
    @required this.czas,
    @required this.imie,
    @required this.nazwisko,
    @required this.telefon,
    @required this.email,
    @required this.uwagi,
    @required this.platnosc,
    @required this.koszt,
    @required this.moge,
    @required this.lang,
    @required this.razem,
    @required this.statusId,
    @required this.status,
  });
}

class Orders with ChangeNotifier{
  List<OrderItem> _items = [];

  List<OrderItem> get items {
    return [..._items];
  }

  Future<void> fetchOrdersFromSerwer() async {
    var url = 'https://cobytu.com/cbt.php?d=f_zamowienia&uz_id=${globals.deviceId}&re=${globals.memoryLokE}&lang=pl';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return _items = [];
      }
      final List<OrderItem>loadedItems = [];
      
      extractedData.forEach((numerZamowienia, zamowienieData) {
        loadedItems.add(OrderItem(
          id: numerZamowienia,
          typ: zamowienieData['za_typ'], 
          typText: zamowienieData['za_typ_text'], 
          data: zamowienieData['za_data'],   
          odp3: zamowienieData['za_odp3'],     
          odp4: zamowienieData['za_odp4'],    
          godz: zamowienieData['za_godz'],       
          adres: zamowienieData['za_adres'],      
          numer: zamowienieData['za_numer'],     
          kod: zamowienieData['za_kod'],       
          miasto: zamowienieData['za_miasto'],    
          miejsc: zamowienieData['za_miejsc'],   
          czas: zamowienieData['za_czas'],      
          imie: zamowienieData['za_imie'],      
          nazwisko: zamowienieData['za_nazwisko'],  
          telefon: zamowienieData['za_telefon'],   
          email: zamowienieData['za_email'],     
          uwagi: zamowienieData['za_uwagi'],     
          platnosc: zamowienieData['za_platnosc'],  
          koszt: zamowienieData['za_koszt'],     
          moge: zamowienieData['za_moge'],      
          lang: zamowienieData['za_lang'],     
          razem: zamowienieData['cena_razem'],     
          statusId: zamowienieData['za_status_id'],  
          status: zamowienieData['za_status'], 
                    
        ));
      });
     // _items = loadedRests;
      print('numer zamówienia  = ${loadedItems[0].typText}');
      notifyListeners();
      
      if (loadedItems[0].id != 'brak ') _items = loadedItems;
      else _items = [];
     
     
    } catch (error) {
      throw (error);
    }
  }

}