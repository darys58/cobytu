import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)
import '../models/meals.dart';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;
import 'dart:convert'; //obsługa json'a

//danie - wzorzec dania, wyświetlany na liście dań

class Meal with ChangeNotifier {
  //dzięki ChangeNotifier dania mogą powiadamiać słuchaczy o zmianach np.polubienia dania
  final String id; //da_id
  final String nazwa; //da_nazwa
  final String opis; //da_opis
  final String idwer; //da_id_wer
  final String wersja; //da_wersja
  final String foto; //da_foto   - adres w sieci
  final String gdzie; //da_gdzie
  final String kategoria; //da_kategoria
  final String podkat; //da_podkategoria
  final String rodzaj; //da_rodzaj
  final String srednia; //da_srednia
  final String alergeny; //alergeny
  final String cena; //cena
  final String czas; //da_czas
  final String waga; //waga
  final String kcal; //kcal
  final String lubi; //ud0_da_lubi
  String fav; //fav
  String stolik; //na_stoliku

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
    this.rodzaj,
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

  void toggleFavoriteStatus(String id) {
    //przełącznik polubienia dania
    if (fav == '0') {
      fav = '1';
      wyslijFav(id,
          fav); //wysłanie na serwer jezeli jest połączenie z kontem uzytkownika
      Meals.updateFavorite(id, fav); //update w bazie lokalnej
    } else {
      fav = '0';
      wyslijFav(id, fav);
      Meals.updateFavorite(id, fav); //update w bazie lokalnej
    }
    notifyListeners(); //wysłanie powiadomienia aby wszyscy słuchacze wiedzieli ze trzeba wywołać powiadamiacze nasłuchujące bo nastąpoiła zmiana w Meal (zmiana w obiekcie), podobnie jak zmiana stanu
  }

  //wysyłanie polubienie dania jezeli jest połączenie z kontem na cobytu.com
  Future<void> wyslijFav(String id, String fav) async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_fav.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "idDania": id,
        "fav": fav,
        "deviceId": globals.deviceId,
      }),
    );
    print('******** fav *******');
    print(id + fav + globals.deviceId);
    print(response.body);
    /*  if (response.statusCode >= 200 &&
        response.statusCode <= 400 &&
        json != null) {
      Map<String, dynamic> odpPost = json.decode(response.body);
      if (odpPost['success'] != 'ok') {
        if (kod != 'test_deviceId') {
          //jezeli nie był to test połączenia (tylko próba połączenia)
          _showAlert(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_POLACZENIE_ERROR'));
        } else {
          print('brak połączenie tej apki z kontem na cobytu.com');
        }
      } else {
        //jezeli odpowiedz "ok"
        if (kod == 'test_deviceId') {
          _uzLogin = odpPost['uz_login']; //jest połączenie i zostanie wybrana część mówiąca o połaczeniu        
        } 
        else if (kod == 'rozlacz') {
          //jezeli było to rozłaczenie
          _showAlertOK(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_ROZLOCZENIE_OK') + odpPost['uz_login']);
        }
        else {
          //jezeli nie był to test połączenia ani rozłaczenie (tylko połączenie i to udane)
          _showAlertOK(context, allTranslations.text('L_KOMUNIKAT'),
              allTranslations.text('L_POLACZENIE_OK') + odpPost['uz_login']);
        }
        //Navigator.of(context).pushNamed(OrderScreen.routeName);
      }
    } else {
      throw Exception('Failed to create OdpPost. z połączenia konta z apką');
    }
*/
  }

/*  void changeStolik(String id, String ile) {
    stolik = ile;
    Meals.updateKoszyk(id, ile);  
    notifyListeners(); 
  }
*/
}
