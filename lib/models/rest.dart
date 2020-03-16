import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)


class Rest{
  final String id;             //re_id
  final String nazwa;          //re_nazwa
  final String obiekt;         //re_obiekt
  final String adres;          //re_adres
  final String miaId;          //re_mia_id
  final String miasto;         //re_miasto
  final String wojId;          //re_woj_id
  final String woj;            //re_woj
  final String dostawy;        //re_dostawy
  final String opakowanie;     //re_opakowanie
  final String doStolika;      //re_do_stolika
  final String rezerwacje;     //re_rezerwacje
  final String mogeJesc;       //re_moge_jesc
  final String modMenu;        //re_mod_menu

  Rest({
    @required this.id,
    @required this.nazwa,
    @required this.obiekt,
    @required this.adres,
    @required this.miaId,
    @required this.miasto,
    @required this.wojId,
    @required this.woj,
    @required this.dostawy,
    @required this.opakowanie,
    @required this.doStolika,
    @required this.rezerwacje,
    @required this.mogeJesc,
    @required this.modMenu,
  });

}

