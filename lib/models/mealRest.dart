import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)

//dane restauracji dla szczegółów dania

class MealRest{
  final String id;         //re_id
  final String logo;       //re_logo
  final String nazwa;      //re_nazwa
  final String obiekt;     //re_obiekt
  final String adres;      //re_adres
  final String kod;        //re_kod
  final String miasto;     //re_miasto
  final String woj;        //re_woj
  final String tel1;       //re_tel1
  final String tel2;       //re_tel2
  final String email;      //e_email
  final String www;        //re_www
  final String gps;        //re_gps
  final String otwarteA;   //re_otwarte_a
  final String otwarteB;   //re_otwarte_b
  final String otwarteC;   //re_otwarte_c
  final String cena;       //cena
  final String parking;    //re_parking
  final String pojazd;     //re_podjazd
  final String wynos;      //re_na_wynos
  final String karta;      //re_p_karta
  final String zabaw;      //re_s_zabaw
  final String letni;      //re_o_letni
  final String klima;      //re_klima
  final String wifi;       //re_wifi
  final String modMenu;    //re_mod_menu

 MealRest({
    @required this.id,
    @required this.logo,
    @required this.nazwa,      
    @required this.obiekt,  
    @required this.adres,      
    @required this.kod,
    @required this.miasto,
    @required this.woj,
    @required this.tel1,
    @required this.tel2,
    @required this.email,
    @required this.www,
    @required this.gps,
    @required this.otwarteA,
    @required this.otwarteB,
    @required this.otwarteC,
    @required this.cena,
    @required this.parking,
    @required this.pojazd,
    @required this.wynos,
    @required this.karta,
    @required this.zabaw,
    @required this.letni,
    @required this.klima,
    @required this.wifi,
    @required this.modMenu, 
  });


}