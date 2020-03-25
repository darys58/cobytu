import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)
import '../models/meals.dart';

//danie - wzorzec dania, wyświetlany na liście dań

class Meal with ChangeNotifier{ //dzięki ChangeNotifier dania mogą powiadamiać słuchaczy o zmianach np.polubienia dania
  final String id;             //da_id
  final String nazwa;          //da_nazwa
  final String opis;           //da_opis
  final String idwer;          //da_id_wer
  final String wersja;         //da_wersja
  final String foto;           //da_foto   - adres w sieci
  final String gdzie;          //da_gdzie
  final String kategoria;      //da_kategoria
  final String podkat;         //da_podkategoria
  final String srednia;        //da_srednia
  final String alergeny;       //alergeny
  final String cena;           //cena
  final String czas;           //da_czas
  final String waga;           //waga
  final String kcal;           //kcal
  final String lubi;           //ud0_da_lubi
  String fav;            //fav
  String stolik;         //na_stoliku

  Meal({
    @required this.id,
    @required this.nazwa,
    @required this.opis,
    this.idwer,
    this.wersja,
    @required this.foto,
    @required this.gdzie,
    @required this.kategoria,
    @required this.podkat,
    @required this.srednia,
    @required this.alergeny,
    @required this.cena,
    @required this.czas,
    @required this.waga,
    @required this.kcal,
    @required this.lubi,
    this.fav,
    this.stolik,
  });


  void toggleFavoriteStatus(String id) { //przełącznik polubienia dania
      if (fav == '0') {
        fav = '1';
        Meals.updateFavorite(id, fav); //update w bazie lokalnej
        //trzeba uaktualnić baze na serwerze!!!!!
      }else{
        fav = '0'; 
        Meals.updateFavorite(id, fav); //update w bazie lokalnej
      } 
    notifyListeners(); //wysłanie powiadomienia aby wszyscy słuchacze wiedzieli ze trzeba wywołać powiadamiacze nasłuchujące bo nastąpoiła zmiana w Meal (zmiana w obiekcie), podobnie jak zmiana stanu
  }


}