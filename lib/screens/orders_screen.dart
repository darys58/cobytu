import 'package:flutter/material.dart';

class Zamowienie {
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

  Zamowienie({
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

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders'; 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zamówienia'),
      
      ),
      body: Text('ddd'),
    );
  }
}