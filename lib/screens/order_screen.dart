import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert'; //obsługa json'a

import '../globals.dart' as globals;
import '../models/cart.dart';
import '../all_translations.dart';
import '../screens/meals_screen.dart';

class Strefa {
  final String numer;     //str_numer
  final String czynne;    //czynne
  final String zamOd;     //zamow_od
  final String zamDo;     //zamow_do
  final String zakres;    //str_zakres
  final String wartMin;   //str_wart_min
  final String koszt;     //str_koszt
  final String wartMax;   //str_wart_max
  final String bonus;     //str_wat_bonus
  final String platne;    //re_platne_dos

  Strefa({
    @required this.numer, 
    this.czynne, 
    this.zamOd, 
    this.zamDo,
    this.zakres, 
    this.wartMin,
    this.koszt,
    this.wartMax,
    this.bonus,
    this.platne,
    });
}


class OrderScreen extends StatefulWidget {
  static const routeName = '/order'; //nazwa trasy do tego ekranu

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<OrderScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  final _formKey1 = GlobalKey<FormState>();
  String opakowanie = '';
  String _cenaRazem;
  int _czyDostawa = globals.czyDostawa;
  String _czasDostawy = '0.99';
  int _sposobPlatnosci = globals.sposobPlatnosci;
  int _wybranaStrefa = globals.wybranaStrefa;
  var _now = DateTime.now();
  List<String> _czasy = [];
  String _uwagi = '';
  final String _currLang = allTranslations.currentLanguage; //aktualny język
  List<DropdownMenuItem<String>> _listaCzasowDostaw = [];
  List<Strefa> _strefy = []; //lista stref
  String strefa; //numer wybranej strefy

  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
      
      fetchStrefyFromSerwer().then((str) { //pobranie stref z serwera www
        //opakowanie = restaurant.asMap()[0]['opakowanie']; //pobranie doliczanej wartości opakowania
        strefa = str[0].numer; //domyślna wartość strefy
        
        //do której mozna składać zamówienia
        print('_wybranaStrefa $_wybranaStrefa');
        if (_wybranaStrefa == null) _wybranaStrefa = 1 ; 
        int doGodz = double.parse(_strefy[_wybranaStrefa - 1].zamDo).round().toInt();
        //generowanie tablicy czasów 
        for (var i = _now.hour + 1; i < doGodz; i++) {
          _czasy.add(i.toString() + ':00');
          _czasy.add(i.toString() + ':15');
          _czasy.add(i.toString() + ':30');
          _czasy.add(i.toString() + ':45');
        }
        _listaCzasowDostaw = buildDropdownMenuItem(_czasy);
        setState(() {
          _isLoading = false; //zatrzymanie wskaznika ładowania danych
        });
      });                        

    }  
    _isInit = false;
    super.didChangeDependencies();  
  } 
  
  //tworzenie buttona wyboru województwa
  List<DropdownMenuItem<String>> buildDropdownMenuItem(List<String> lista){
    List<DropdownMenuItem<String>> items = List();    
    print('lista do budowania buttona $lista');
    items.add(
        DropdownMenuItem(
          value: '0.99',
          child: Text('jak najszybciej'),
        ),
      );
    for (String czas in lista) {
      items.add(
        DropdownMenuItem(
          value: czas,
          child: Text(czas),
        ),
      );
    }
    return items;
  }
  
  void _showAlert(BuildContext context,String nazwa, String text){
    showDialog(context: context,
      builder: (context) =>AlertDialog(
        title: Text(nazwa),
        content: Column( //zeby tekst był wyśrodkowany w poziomie
          mainAxisSize:MainAxisSize.min, 
          children: <Widget>[
            Text(text),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(context).pop();
              }, 
            child: Text('Anuluj'),
          ),
        ],
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
    ),
      ),
      barrierDismissible: false, //zeby zaciemnione tło było zablokowane na kliknięcia    
    );
  }

  void _showAlertOK(BuildContext context,String nazwa, String text){
    showDialog(context: context,
      builder: (context) =>AlertDialog(
        title: Text(nazwa),
        content: Column( //zeby tekst był wyśrodkowany w poziomie
          mainAxisSize:MainAxisSize.min, 
          children: <Widget>[
            Text(text),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów                                
              }, 
            child: Text('OK'),
          ),
        ],
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
    ),
      ),
      barrierDismissible: false, //zeby zaciemnione tło było zablokowane na kliknięcia    
    );
  }

  //wysyłanie aktualizacji koszyka do serwera www - usuwanie wszystkich dań
  Future<void> aktualizujKoszyk(String akcja) async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_do_koszyka.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ko_uz_id': globals.deviceId,
        'ko_re_id': globals.memoryLokE,
        'ko_da_id': '0',
        'ko_dw1': '0',
        'ko_dw2': '0',
        'ko_dd': '0',
        'ko_cena': '0',
        'ko_waga': '0',
        'ko_kcal': '0',
        'ko_akcja': akcja,
      }),
    );
    print(response.body);
    if (response.statusCode >= 200 && response.statusCode <= 400 && json != null) {
      Map<String, dynamic> odpPost = json.decode(response.body);
      //zapisanie w tabeli 'dania' do pola 'stolik' ilości tego dania w koszyku
      //Meal.changeStolik(odpPost['ko_da_id'], odpPost['ko_ile'].toString());    
      //Meals.updateKoszyk(odpPost['ko_da_id'], odpPost['ko_ile'].toString()); //aktualizacja ilości dania w koszyku w danych on daniu
      
      Provider.of<Cart>(context).fetchAndSetCartItems('https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLokE}&lang=pl');  //aktualizacja zawartości koszyka z www             
  
     // _setPrefers('reload', 'true');    
      //return OdpPost.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create OdpPost.');
    }
  }

  //pobranie (z serwera www) stref dla danej restauracji
  Future<List<Strefa>> fetchStrefyFromSerwer() async {
    var url = 'https://cobytu.com/cbt.php?d=f_strefy&re_id=${globals.memoryLokE}&';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return[];
      }

      //final List<MealRest> loadedRests = [];
      extractedData.forEach((numerStrefy, strefaData) {
        _strefy.add(Strefa(
          numer: numerStrefy,
          czynne: strefaData['czynne'], 
          zamOd: strefaData['zamow_od'],       
          zamDo: strefaData['zamow_do'],
          zakres: strefaData['str_zakres'],   
          wartMin: strefaData['str_wart_min'],       
          koszt: strefaData['str_koszt'], 
          wartMax: strefaData['str_wart_max'], 
          bonus: strefaData['str_wat_bonus'], 
          platne: strefaData['re_platne_dos'],  
        ));
      });
     // _items = loadedRests;
      print('numer strefy w order = ${_strefy[0].numer}');
      //notifyListeners();
    return _strefy;
    } catch (error) {
      throw (error);
    }
  }


  //wysyłanie zamówienia do serwera www - typ: dostawa / odbiów własny
  Future<void> wyslijZamowienie() async {
    final http.Response response = await http.post(
      'https://cobytu.com/cbt_f_dostawa.php',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: _czyDostawa == 1 
      ? jsonEncode(<String, String>{
          "za_uz_id": globals.deviceId,
          "za_re_id": globals.memoryLokE,
          "za_typ": "1",                     //1 - dostawa lub odbiór własny
          "za_data": "1",   //data wstawiana w skrypcie php na serwerze
          "za_godz": _czasDostawy,
          "za_adres": globals.adres,
          "za_numer": globals.numer,
          "za_kod": globals.kod,
          "za_miasto": globals.miasto,
          "za_imie": globals.imie,
          "za_nazwisko": globals.nazwisko,
          "za_telefon": globals.telefon,
          "za_email": globals.email,
          "za_uwagi": _uwagi,
          "za_platnosc": _sposobPlatnosci.toString(),
          "za_koszt": _strefy[_wybranaStrefa - 1].koszt,
          "za_lang": _currLang,
        })
      : jsonEncode(<String, String>{
          "za_uz_id": globals.deviceId,
          "za_re_id": globals.memoryLokE,
          "za_typ": "1",                     //1 - dostawa lub odbiór własny
          "za_data": "1",   //data wstawiana w skrypcie php na serwerze
          "za_godz": _czasDostawy,
          "za_adres": '',
          "za_numer": '',
          "za_kod": '',
          "za_miasto": '',
          "za_imie": globals.imie,
          "za_nazwisko": globals.nazwisko,
          "za_telefon": globals.telefon,
          "za_email": globals.email,
          "za_uwagi": _uwagi,
          "za_platnosc": _sposobPlatnosci.toString(),
          "za_koszt": '0.00',
          "za_lang": _currLang,
          })
        );
    
    print(response.body);
    if (response.statusCode >= 200 && response.statusCode <= 400 && json != null) {
      Map<String, dynamic> odpPost = json.decode(response.body);
      if (odpPost['success'] != 'ok'){
        if (odpPost['zapis'] != 'ok'){
            _showAlert(context, 'Komunikat','Wysłanie zmówienia nie powiodło się. Sprawdź poprawność danych.');    
        }else{
          _showAlert(context, 'Komunikat','Zamówienie przekazano do restauracji ale nie wszystko jest OK. Prosimy o kontakt telefoniczny z naszą restauracją.');   
        }
      }else{
        _showAlertOK(context, 'Komunikat','Twoje zamówienie zostało przekazane do restauracji. Oczekuj na potwierdzenie. W razie pytań lub problemów prosimy o kontakt telefoniczny z naszą restauracją.');
        aktualizujKoszyk('3'); //czyszczenie koszyka na serwerze - akcja '3' 
        //Navigator.of(context).pushNamed(OrderScreen.routeName);
      }
    } else {
      throw Exception('Failed to create OdpPost. z zmówień');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    print(_czasy);
    //obliczenie wartości menu
    double razemC = 0;
    for (var i = 0; i < cart.items.length; i++) {
      razemC = razemC + double.parse(cart.items[i].cena) ;
    }
    _cenaRazem = razemC.toStringAsFixed(2);

    return Scaffold(
          appBar: AppBar(
            title: Text('Zamównienie'),
          ),
          body:  _isLoading  //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          :SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
//Dostawa
                      FlatButton.icon(
                        onPressed: (){
                          setState(() {
                            _czyDostawa = 1;
                            globals.czyDostawa = 1;
                          });
                        }, 
                        icon: Radio(
                          value: 1, 
                          groupValue: _czyDostawa, 
                          onChanged: (value){
                            setState(() {
                              _czyDostawa = value;
                              globals.czyDostawa = value;
                            });
                          } 
                        ), 
                        label: Text("Dostawa")
                      ),
//Odbiór własny
                      FlatButton.icon(
                        onPressed: (){
                          setState(() {
                            _czyDostawa = 2;
                            globals.czyDostawa = 2;
                          });
                        }, 
                        icon: Radio(
                          value: 2, 
                          groupValue: _czyDostawa, 
                          onChanged: (value){
                            setState(() {
                              _czyDostawa = value;
                              globals.czyDostawa = value;
                            });
                          } 
                        ), 
                        label: Text("Odbiór własny")
                      ),

                    ],
                  ),
                  //koszty
                  Container(
                    //padding: EdgeInsets.only(left: 20),
                    child: Column(
                      children: <Widget>[
                        Divider(color: Colors.grey,),
//koszt menu      
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text('Koszt menu',
                                style: TextStyle(           
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Row( //cena dania
                              children: <Widget>[
                                Text(
                                  globals.separator == '.' ? _cenaRazem  : _cenaRazem.replaceAll('.', ','),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ), 
                                ),
                                SizedBox(
                                  width: 2,
                                ), //odległość miedzy ceną a PLN
                                Text(
                                  allTranslations.text('L_PLN'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ), //interpolacja ciągu znaków
                                ), 
                                SizedBox(
                                  width: 25,
                                ), 
                              ],
                            ),
                          ]
                        ),
                        Divider(color: Colors.grey,),
      //koszt dostawy    
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text('Koszt dostawy',
                              style: TextStyle(           
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Row( //cena dania
                              children: <Widget>[
                                Text(
                                  _czyDostawa == 1 
                                  ? globals.separator == '.' ? _strefy[_wybranaStrefa - 1].koszt  : _strefy[_wybranaStrefa - 1].koszt.replaceAll('.', ',')
                                  : globals.separator == '.' ? '0.00'  : '0,00'
                                 ,
                                  style: TextStyle(           
                                    fontSize: 15,
                                    color: Colors.black,
                                  ), 
                                ),
                                SizedBox(
                                  width: 2,
                                ), //odległość miedzy ceną a PLN
                                Text(
                                  allTranslations.text('L_PLN'),
                                  style: TextStyle(           
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),//interpolacja ciągu znaków
                                ), 
                                SizedBox(
                                  width: 25,
                                ), 
                              ],
                            ),
                          ]
                        ),
                        Divider(color: Colors.grey,),
  //całkowity koszt    
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: Text('Całkowity koszt',
                                style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                            ),
                            Row( //cena dania
                              children: <Widget>[
                                Text(
                                  _czyDostawa == 1 
                                  ? globals.separator == '.' ? (razemC + double.parse(_strefy[_wybranaStrefa - 1].koszt)).toStringAsFixed(2)  : (razemC + double.parse(_strefy[_wybranaStrefa - 1].koszt)).toStringAsFixed(2).replaceAll('.', ',')
                                  : globals.separator == '.' ? _cenaRazem  : _cenaRazem.replaceAll('.', ',')
                                  ,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ), 
                                ),
                                SizedBox(
                                  width: 2,
                                ), //odległość miedzy ceną a PLN
                                Text(
                                  allTranslations.text('L_PLN'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ), //interpolacja ciągu znaków
                                ), 
                                SizedBox(
                                  width: 25,
                                ), 
                              ],
                            ),
                          ]
                        ),
                        Divider(color: Colors.grey,),
                        SizedBox(height: 5),
                          
                        
                      ],
                    )
             
                    
                  ),

  //miejsce dostawy
                  
                  Visibility(
                    visible: _czyDostawa == 1 ,                                                                        
                    child: Container(
                      margin:  EdgeInsets.only(left:20, right: 20),
                      padding: EdgeInsets.only(left: 20),
                      //color: Colors.grey[300],
                      height: 38,            
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('Miejsce dostawy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ]),
                    ),
      
                  ),
                   
                  
 //Strefa                 
                  Visibility(
                    visible: _czyDostawa == 1 , 
                      child: Container(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: RaisedButton(
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Container(
                                  width: double.maxFinite,
                                  child: Column(                                
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[                                
                                    Text('Wybierz strefę'),      
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _strefy.length,
                                      itemBuilder: (context, index){
                                      return InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _wybranaStrefa = index + 1;
                                            globals.wybranaStrefa = index + 1;
                                          });                                        
                                        },
                                        child: Card(
                                          margin: EdgeInsets.only(top: 20),
                                          elevation: 4, //cień za kartą
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: <Widget>[
                                                Text('Strefa ${_strefy[index].numer}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    //color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(_strefy[index].zakres)
                                              ],
                                            ),
                                          )
                                        ),
                                      );
                                    }),                        
                                  ],
                                ),
                              ),
                            );
                          });
                        }, 
                        color: Colors.grey[200],
                        child: Text(
                          'Strefa dostawy: ' + ' ' + _wybranaStrefa.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
//formularz
                  Container(
                    padding: EdgeInsets.only(left:20, right: 20),
                    child: Form(
                      key: _formKey1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
  //Adres                        
                          Visibility(
                            visible: _czyDostawa == 1 , 
                            child: TextFormField(
                              initialValue: globals.adres,
                              decoration: InputDecoration(
                                labelText: 'Adres',
                                labelStyle: TextStyle(color: Colors.black),
                                hintText: 'Wpisz nazwę ulicy i numer budynku',
                              ),                         
                              validator: (value){
                                if (value.isEmpty){
                                  return 'Wpisz nazwę ulicy i numer budynku';
                                }
                                globals.adres = value;
                                return null;
                              }
                            ),
                          ),
//Numer
                          Visibility(
                            visible: _czyDostawa == 1 , 
                            child: TextFormField(
                              initialValue: globals.numer,
                              decoration: InputDecoration(
                                labelText: 'Numer',
                                labelStyle: TextStyle(color: Colors.black),
                                hintText: 'Wpisz numer mieszkania, piętro, kod do bramy',
                              ),                 
                              validator: (value){
                                if (value.isEmpty){
                                  return 'Wpisz numer mieszkania, piętro, kod do bramy';
                                }
                                globals.numer = value;
                                return null;
                              }
                            ),
                          ),


//Kod
                          Visibility(
                            visible: _czyDostawa == 1 , 
                            child: TextFormField(
                              initialValue: globals.kod,
                              decoration: InputDecoration(
                                labelText: 'Kod pocztowy',
                                labelStyle: TextStyle(color: Colors.black),
                                hintText: 'Wpisz kod pocztowy (XX-XXX)',
                              ),                 
                              validator: (value){
                                if (value.isEmpty){
                                  return 'Wpisz kod pocztowy (XX-XXX)';
                                }
                                globals.kod = value;
                                return null;
                              }
                            ),
                          ),
//Miasto
                          Visibility(
                            visible: _czyDostawa == 1 , 
                            child: TextFormField(
                              initialValue: globals.miasto,
                              decoration: InputDecoration(
                                labelText: 'Miasto',
                                labelStyle: TextStyle(color: Colors.black),
                                hintText: 'Wpisz nazwę miasta, miejscowości',
                              ),                 
                              validator: (value){
                                if (value.isEmpty){
                                  return 'Wpisz nazwę miasta, miejscowości';
                                }
                                globals.miasto = value;
                                return null;
                              }
                            ),
                          ),
//dane zamawiającego
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 20),
                    //color: Colors.grey[300],
                    height: 38,            
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Dane zamawiającego',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                      ]),
                  ),


  //Imię                       
                          TextFormField(
                            initialValue: globals.imie,
                            decoration: InputDecoration(
                              labelText: 'Imię',
                              labelStyle: TextStyle(color: Colors.black),
                              hintText: 'Wpisz swoje imię',
                            ),                         
                            validator: (value){
                              if (value.isEmpty){
                                return 'Wpisz swoje imię';
                              }
                              globals.imie = value;
                              return null;
                            }
                          ),
//Nazwisko
                          TextFormField(
                            initialValue: globals.nazwisko,
                            decoration: InputDecoration(
                              labelText: 'Nazwisko',
                              labelStyle: TextStyle(color: Colors.black),
                              hintText: 'Wpisz swoje nazwisko',
                            ),                 
                            validator: (value){
                              globals.nazwisko = value;
                              return null;
                            }
                          ),


//Telefon
                          TextFormField(
                            initialValue: globals.telefon,
                            decoration: InputDecoration(
                              labelText: 'Telefon',
                              labelStyle: TextStyle(color: Colors.black),
                              hintText: 'Wpisz numer telefonu',
                            ),                 
                            validator: (value){
                              if (value.isEmpty){
                                return 'Wpisz numer telefonu';
                              }
                              globals.telefon = value;
                              return null;
                            }
                          ),
//Email
                          TextFormField(
                            initialValue: globals.email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.black),
                              hintText: 'Wpisz adres e-mail',
                            ),                 
                            validator: (value){
                              if (value.isEmpty){
                                return 'Wpisz adres e-mail';
                              }
                              globals.email = value;
                              return null;
                            }
                          ),
//informacje dodatkowe
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 20),
                    //color: Colors.grey[300],
                    height: 38,            
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Informacje dodatkowe',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                      ]),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Dostawa na: ',
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                          
                      SizedBox(width: 15),
                      DropdownButton(
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                        value: _czasDostawy, //ustawiona, widoczna wartość
                        items: _listaCzasowDostaw,  //lista elementów do wyboru
                        onChanged:(String newValue) {  //wybrana nowa wartość - nazwa dodatku
                          setState(() {
                            _czasDostawy = newValue; // ustawienie nowej wybranej nazwy dodatku
                            print ('_czasDostawy = $_czasDostawy');
                          //  war1Id = _listWar1.indexOf(newValue); //pobranie indexu wybranego dodatku z listy
                          //  _selectedWar1Id = _detailMealData[0].warList1Id[war1Id]; //Id wybranego dodatku
                           // przelicz();
                          });
                        }  //onChangeDropdownItemWar1,
                      ),
                    ],
                  ),
 //Uwagi
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Uwagi',                     
                      labelStyle: TextStyle(color: Colors.black),
                      hintText: 'Wpisz dodatkowe uwagi do zamówienia',
                    ),
                    onChanged:(String value) { 
                      setState(() {
                        _uwagi = value; 
                      });
                    }, 
                    maxLines: null,                
                    
                  ),
//informacje dodatkowe sposób zapłaty
               Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 20),
                    //color: Colors.grey[300],
                    height: 38,            
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Sposób zapłaty',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                      ]),
                  ),
//wybór sposobu zapłaty
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
//musi być conajmniej płatność gotówką więc:
                      FlatButton.icon(
                        onPressed: (){
                          setState(() {
                            _sposobPlatnosci = 1;
                            globals.sposobPlatnosci = 1;
                          });
                        }, 
                        icon: Radio(
                          value: 1, 
                          groupValue: _sposobPlatnosci, 
                          onChanged: (value){
                            setState(() {
                              _sposobPlatnosci = value;
                              globals.sposobPlatnosci = value;
                            });
                          } 
                        ), 
                        label: Text("Gotówka przy odbiorze")
                      ),

//jezeli platne (tzn. re_platne_dos) =  3 lub 7 to opócz gotówki jest karta
                      Visibility(
                        visible: _strefy[_wybranaStrefa - 1].platne == '3' || _strefy[_wybranaStrefa - 1].platne == '7',
                        child: FlatButton.icon(
                          onPressed: (){
                            setState(() {
                              _sposobPlatnosci = 2;
                              globals.sposobPlatnosci = 2;
                            });
                          }, 
                          icon: Radio(
                            value: 2, 
                            groupValue: _sposobPlatnosci, 
                            onChanged: (value){
                              setState(() {
                                _sposobPlatnosci = value;
                                globals.sposobPlatnosci = value;
                              });
                            } 
                          ), 
                          label: Text("Karta płatnicza przy odbiorze")
                        ),
                      ),

//jezeli platne (tzn. re_platne_dos) =  5 lub 7 to opócz gotówki i/lub karta jest online
                      Visibility(
                        visible: _strefy[_wybranaStrefa - 1].platne == '5' || _strefy[_wybranaStrefa - 1].platne == '7',
                        child: FlatButton.icon(
                          onPressed: (){
                            setState(() {
                              _sposobPlatnosci = 3;
                              globals.sposobPlatnosci = 3;
                            });
                          }, 
                          icon: Radio(
                            value: 2, 
                            groupValue: _sposobPlatnosci, 
                            onChanged: (value){
                              setState(() {
                                _sposobPlatnosci = value;
                                globals.sposobPlatnosci = value;
                              });
                            } 
                          ), 
                          label: Text("OnLine")
                        ),
                      ),

                    ],
                  ),



                        ]
                   
                        
                      )
                    ),
                  ),

                          
//informacje dodatkowe 
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    padding: EdgeInsets.only(left: 20),
                    //color: Colors.grey[300],
                    //height: 38,            
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                          text: TextSpan(
                            children:[
                              TextSpan(
                                text:'Klikając Zamawiam potwierdzasz, ze jest Ci znana nasza ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,  
                                ),                             
                              ),
                              
                              TextSpan(
                                text: 'Polityka prywatności',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,                                  
                                ),                            
                                recognizer: TapGestureRecognizer()
                                ..onTap = (){launch('https://www.cobytu.com/index.php?d=polityka&mobile=1');
                                },
                              ),
                              
                              TextSpan(
                                text:' oraz ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,                                  
                                ),                              
                              ),

                              TextSpan(
                                text: 'Regulamin',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,                                  
                                ),                            
                                recognizer: TapGestureRecognizer()
                                ..onTap = (){launch('https://www.cobytu.com/index.php?d=regulamin&mobile=1');
                                },
                              ),
                              
                              TextSpan(
                                text:'.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,                                  
                                ),                              
                              ),
                            ]
                          ),
                        ),

                        Container(
                            height: 90,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,                             
                              children: <Widget>[                                
                                MaterialButton(
                                  shape: const StadiumBorder(),
                                  onPressed: (){
                                    if (_formKey1.currentState.validate()){ //jezeli formularz wypełniony poprawnie
                                      if(globals.czyDostawa != null){
                                        if(globals.sposobPlatnosci != null){
                                          wyslijZamowienie();
                                          //Navigator.of(context).pushNamed(OrderScreen.routeName);
                                          print('form OK');
                                        }else  _showAlert(context, 'Komunikat','Wybierz sposób zapłaty');
                                      } else _showAlert(context, 'Komunikat','Wybierz dostawę lub odbiór osobisty');                                                                        
                                    }
                                    //Navigator.of(context).pushNamed(OrderScreen.routeName); 
                                  }, 
                                  child: Text ('   Zamawiam   '),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  disabledColor: Colors.grey,
                                  disabledTextColor: Colors.white,                                    
                                ),
                              ],
                            ),
                        ),
                      ]
                    ),
                  )
                ]
                   
              ),
            ),
          ),    
    );
  }
}