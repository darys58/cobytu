import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //obsługa json'a

import '../globals.dart' as globals;

class SpecialItem with ChangeNotifier {
  final String id; //rb_id: String
  final String reId; //rb_re_id: String
  final String resta; //rb_resta: String
  final String miaId; //rb_mia_id: String
  final String daId; //rb_da_id: String
  final String tytul; //rb_tytul: String
  final String opis; //rb_opis: String
  final String dataMod; //rb_data_mod: String

  SpecialItem({
    @required this.id,
    @required this.reId,
    @required this.resta,
    @required this.miaId,
    @required this.daId,
    @required this.tytul,
    @required this.opis,
    @required this.dataMod,
  });
}

class Specials with ChangeNotifier {
  List<SpecialItem> _items = [];

  List<SpecialItem> get items {
    return [..._items];
  }

  Future<void> fetchSpecialsFromSerwer() async {
    var url =
        'https://cobytu.com/cbt.php?d=f_promocje&uz_id=${globals.deviceId}&mia_id=${globals.memoryLokC}&re=${globals.memoryLokE}&lang=${globals.language}';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return _items = [];
      }
      final List<SpecialItem> loadedItems = [];

      extractedData.forEach((numerPromocji, promocjeData) {
        loadedItems.add(SpecialItem(
          id: numerPromocji,
          reId: promocjeData['rb_re_id'],
          resta: promocjeData['rb_resta'],
          miaId: promocjeData['rb_mia_id'],
          daId: promocjeData['rb_da_id'],
          tytul: promocjeData['rb_tytul'],
          opis: promocjeData['rb_opis'],
          dataMod: promocjeData['dataMod'],
        ));
      });
      // _items = loadedRests;
      print('numer promocji  = ${loadedItems[0].id}');
      notifyListeners();

      if (loadedItems[0].id != 'brak ')
        _items = loadedItems;
      else
        _items = [];
    } catch (error) {
      throw (error);
    }
  }
}
