import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meals/all_translations.dart';

import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../screens/meals_screen.dart';
import '../models/rest.dart';
import '../models/rests.dart';
import '../models/mem.dart';
import '../models/mems.dart';

//import '../widgets/main_drawer.dart';

class LocationScreen extends StatefulWidget {
  //nazwa trasy do nawigacji przez routeNamed
  static const routeName = '/location';

  //final Function saveFilters;
  //final Map<String, bool> currentFilters;

  //FiltersScreen(this.currentFilters, this.saveFilters);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<DropdownMenuItem<Rest>> _dropdownMenuItemsWoj;
  List<DropdownMenuItem<Rest>> _dropdownMenuItemsMia;
  Rest _selectedWoj; //wybrane województwo
  Rest _selectedMiasto; //wybrane miasto
  List<Mem> _memLok; //dane wybranej lokalizacji w tabeli memory - baza lokalna
  List<Rest> _wojRest = []; //lista restauracji z nazwami województw dla buttona 1
  List<Rest> _miaRest = []; //lista restauracji z nazwami miast dla buttona 2
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  String _currentValue;
  String _adresWszystkie = allTranslations.text('L_MIASTO'); //Miasto
  
  @override
  void initState(){
    print('location initState');
    
    //_dropdownMenuItems = buildDropdownMenuItem(_wojRest);
    //_selectedCompany = _dropdownMenuItems[0].value;
    super.initState();
  }

   @override
  void didChangeDependencies() {

    if (_isInit) { //wejście inicjalizujące - przy kadzym wejściu do ekranu
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania dań
      });
      print('location_screen didChangeDependencies ');
      fetchMemoryLok().then((_) {  //pobranie ustawień  memLok z "memory"
        
        getWojewodztwa().then((_) {  //pobranie województw z bazy lokalnej
          _dropdownMenuItemsWoj = buildDropdownMenuItemWoj(_wojRest);     
          //ustawienie województwa domyślnego pobranego z tabeli "memory" - rekord memLok
          var countWoj = _dropdownMenuItemsWoj.length;
          for (var i = 0; i < countWoj; i++) {
            if(_dropdownMenuItemsWoj[i].value.woj == _memLok[0].b){  //b:woj
              _selectedWoj = _dropdownMenuItemsWoj[i].value;  //domyślny woj  
            }  
          }

          getMiasta().then((_) { //pobranie miast z bazy
            _dropdownMenuItemsMia = buildDropdownMenuItemMia(_miaRest);
            //ustawienie miasta domyślnego pobranego z tabeli "memory" - rekord memLok
            var countMia = _dropdownMenuItemsMia.length;
            for (var i = 0; i < countMia; i++) {
              if(_dropdownMenuItemsMia[i].value.miasto == _memLok[0].d){  //d:miasto
                _selectedMiasto = _dropdownMenuItemsMia[i].value;
                _adresWszystkie = _selectedMiasto.miasto; //miasto jako adres dla "Wszystkie"
              }
            }
            _currentValue = _memLok[0].e;  //e:restId  domyślna restauracja
            Provider.of<Rests>(context).fetchAndSetRests(_selectedMiasto.miasto).then((_) {  //z bazy lokalnej

              setState(() {
                _isLoading = false; //zatrzymanie wskaznika ładowania dań
              });
            }); //dostawca restauracji
            setState(() {
              _isLoading = false; //zatrzymanie wskaznika ładowania dań
            });
          }); 
        });
      });
    }
    
    _isInit = false;
    //Provider.of<Rests>(context, listen: false).fetchAndSetRests(); //dostawca restauracji
    super.didChangeDependencies();
  }

  //zapisywanie zmiennych w SharedPreferences (zmienne widoczne globalnie)
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }

  //tworzenie buttona wyboru województwa
  List<DropdownMenuItem<Rest>> buildDropdownMenuItemWoj(List<Rest> lista){
    List<DropdownMenuItem<Rest>> items = List();    
    print('lista do budowania buttona $lista');
    for (Rest rest in lista) {
      items.add(
        DropdownMenuItem(
          value: rest,
          child: Text(rest.woj),
        ),
      );
    }
    return items;
  }

  //tworzenie buttona wyboru miasta
  List<DropdownMenuItem<Rest>> buildDropdownMenuItemMia(List<Rest> lista){
    List<DropdownMenuItem<Rest>> items = List();    
    print('lista do budowania buttona $lista');
    for (Rest rest in lista) {
      items.add(
        DropdownMenuItem(
          value: rest,
          child: Text(rest.miasto),
        ),
      );
    }
    return items;
  }

  //jezeli nastapiła zmiana województwa  
  onChangeDropdownItemWoj(Rest selectedWoj){

    setState(() {
      _selectedWoj = selectedWoj; //zmiana województwa przed pobraniem miast
      _isLoading = true; //uruchomienie wskaznika ładowania dań (tu chyba niepotrzebnie)
    });
    
    getMiasta().then((_) { //pobranie miast z bazy  lokalnej  
      setState(() {
        _dropdownMenuItemsMia = buildDropdownMenuItemMia(_miaRest);//tworzenie buttona z miastami
        _selectedMiasto = _dropdownMenuItemsMia[0].value; //ustawienie pierwszego miasta
        _adresWszystkie = _selectedMiasto.miasto; //miasto jako adres dla "Wszystkie"
      });

      Provider.of<Rests>(context).fetchAndSetRests(_selectedMiasto.miasto).then((_) {  //z bazy lokalnej

      setState(() {
        _isLoading = false; //zatrzymanie wskaznika ładowania dań
        _currentValue = '0'; //ustawienie "Wszystkie" restauracje
      });
    }); //dostawca restauracji

    }); 
  }

  //jezeli nastąpiła zmiana miasta
  onChangeDropdownItemMia(Rest selectedMiasto){
    setState(() {
      _selectedMiasto = selectedMiasto; //wybrane miasto 
      _adresWszystkie = _selectedMiasto.miasto; //miasto jako adres dla "Wszystkie"
      _isLoading = true;    
    });
    
    Provider.of<Rests>(context).fetchAndSetRests(_selectedMiasto.miasto).then((_) {  //z bazy lokalnej

      setState(() {
        _isLoading = false; //zatrzymanie wskaznika ładowania dań
        _currentValue = '0'; //ustawienie "Wszystkie" restauracje
      });
    }); //dostawca restauracji

  }

  //pobranie listy restauracji z unikalnymi nazwami województw z bazy lokalnej
  Future<List<Rest>> getWojewodztwa()async{
    final dataList = await DBHelper.getWoj('restauracje');
    //List<Rest> _pom = [];
    _wojRest = dataList
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
          dostawy: item['dostawy'],   
          opakowanie: item['opakowanie'],      
          doStolika: item['doStolika'],      
          rezerwacje: item['rezerwacje'],            
          mogeJesc: item['mogeJesc'],          
          modMenu: item['modMenu'],         
        ),  
      ).toList();
    return _wojRest;      
  }

  //pobranie listy restauracji z unikalnymi nazwami miast dla województwa z bazy lokalnej
  Future<List<Rest>> getMiasta()async{
    final dataList = await DBHelper.getMia(_selectedWoj.woj);
    _miaRest = dataList
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
          dostawy: item['dostawy'],   
          opakowanie: item['opakowanie'],      
          doStolika: item['doStolika'],      
          rezerwacje: item['rezerwacje'],            
          mogeJesc: item['mogeJesc'],          
          modMenu: item['modMenu'],         
        ),  
      ).toList();
    return _miaRest;      
  }

  //pobranie memory z bazy lokalnej
   Future<void> fetchMemoryLok()async{
    final data = await DBHelper.getMemory('memLok');
    _memLok = data.map(
        (item) => Mem(
          nazwa: item['nazwa'],          
          a: item['a'], 
          b: item['b'],     
          c: item['c'],        
          d: item['d'],       
          e: item['e'],          
          f: item['f'],                               
        ),  
      ).toList();
      return _memLok;
  }


  @override
  Widget build(BuildContext context) {
    print ('location budowanie ekranu');
  final restsData = Provider.of<Rests>(context);
  List<Rest> rests = restsData.items.toList();
  rests.add(Rest(id:'0',nazwa:allTranslations.text('L_WSZYSTKIE'),obiekt:'0', adres: _adresWszystkie, miaId:'0',miasto:'0',wojId:'0',woj:'0',dostawy:'0',opakowanie:'0',doStolika:'0',rezerwacje:'0',mogeJesc:'0',modMenu:'0')); //ten wpis zastąpił parametr memLok.f

    return Scaffold(
      appBar :AppBar( 
        title: Text(allTranslations.text('L_LOKALIZACJA')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              
              final _rest = rests.where((re) {return re.id.contains(_currentValue);}).toList();//wybrana restauracja
              Mems.insertMemory(
                'memLok',                 //nazwa
                _selectedWoj.wojId,       //a
                _selectedWoj.woj,         //b
                _selectedMiasto.miaId,    //c
                _selectedMiasto.miasto,   //d
                _currentValue,            //e - '0' lub id restauracji
                _rest[0].nazwa,           //f - "Wszystkie" lub nazwa restauracji
              ); 
              _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera  
              Navigator.of(context).pushReplacementNamed(MealsScreen.routeName);   //przejście z usunięciem (wymianą) ostatniego ekranu (ekranu lokalizacji)  
            },
          ),
        ],
      ),
      
      body: _isLoading  //jezeli dane są ładowane
      ? Center(
          child: CircularProgressIndicator(), //kółko ładowania danych
        )
      : Container( 
        padding: EdgeInsets.all(20.00),      
        child: Center(
          child: Column(
            children: <Widget>[
              //SizedBox(height: 10.0),
              Row( //całą zawatość kolmny stanowi wiersz
                mainAxisAlignment: MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
                children: <Widget>[
                  Expanded( //rozszerzona kolumna z tekstami  - cała dostępna przestrzeń (poza zdjęciem)
                    child: Container( //zeby zrobić margines wokół części tekstowej
                      padding: EdgeInsets.all(8.00),
                      child: Column( //ustawienie elementów jeden pod drugim
                        mainAxisSize:MainAxisSize.min, 
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: <Widget>[
                          Text(allTranslations.text('L_WOJEWODZTWO')),
                          //SizedBox(height: 5.0),
                          DropdownButton(
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            value: _selectedWoj,
                            items: _dropdownMenuItemsWoj,
                            onChanged:  onChangeDropdownItemWoj,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded( //rozszerzona kolumna z tekstami  - cała dostępna przestrzeń (poza zdjęciem)
                    child: Container( //zeby zrobić margines wokół części tekstowej
                      padding: EdgeInsets.all(8.00),
                      child: Column( //ustawienie elementów jeden pod drugim
                        mainAxisSize:MainAxisSize.min, 
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: <Widget>[
                          Text(allTranslations.text('L_MIASTO')),
                          //SizedBox(height: 5.0),
                          DropdownButton(
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                            value: _selectedMiasto,
                            items: _dropdownMenuItemsMia,
                            onChanged:  onChangeDropdownItemMia,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ),
              SizedBox(height: 10.0),
              Expanded(
                child: ListView( 
                  //padding: EdgeInsets.all(8.0),
                  children: 
                    rests.map((item) => RadioListTile(
                      groupValue: _currentValue,
                      title: Text(item.nazwa),
                      subtitle: Text(item.adres),
                      value: item.id,
                      onChanged: (val) {
                        setState(() {
                          _currentValue = val;
                        });
                      },
                    )).toList(),
                  scrollDirection: Axis.vertical,
                ),
              ),
            ],
          ) ,
        ),
      ),
    );
  }
}
 