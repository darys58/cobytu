import 'package:flutter/material.dart';
import '../models/rest.dart';
import '../models/rests.dart';
import 'package:provider/provider.dart';
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../widgets/main_drawer.dart';

class LocationScreen extends StatefulWidget {
  //nazwa trasy do nawigacji przez routeNamed
  static const routeName = '/location';

  //final Function saveFilters;
  //final Map<String, bool> currentFilters;

  //FiltersScreen(this.currentFilters, this.saveFilters);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}
enum SingingCharacter { lafayette, jefferson }

class _LocationScreenState extends State<LocationScreen> {
  List<DropdownMenuItem<Rest>> _dropdownMenuItemsWoj;
  List<DropdownMenuItem<Rest>> _dropdownMenuItemsMia;
  Rest _selectedWoj; //wybrane województwo
  Rest _selectedMiasto; //wybrane miasto
  List<Rest> _wojRest = []; //lista restauracji z nazwami województw dla buttona 1
  List<Rest> _miaRest = []; //lista restauracji z nazwami miast dla buttona 2
  List<Rest> _restsRest = []; //lista restauracji dla wybranego miasta
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  



  SingingCharacter _character = SingingCharacter.lafayette;
  
  @override
  void initState(){
    print('location initState');
    //_dropdownMenuItems = buildDropdownMenuItem(_wojRest);
    //_selectedCompany = _dropdownMenuItems[0].value;
    super.initState();
  }

   @override
  void didChangeDependencies() {
    print('location didChangeDependencies');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania dań
      });
      print('wejscie do Dependencies - Init location_screen');
   
      getWojewodztwa().then((_) {  //pobranie województw z bazy lokalnej
        _dropdownMenuItemsWoj = buildDropdownMenuItemWoj(_wojRest);
        _selectedWoj = _dropdownMenuItemsWoj[2].value;
        getMiasta().then((_) { //pobranie miast z bazy
          _dropdownMenuItemsMia = buildDropdownMenuItemMia(_miaRest);
          _selectedMiasto = _dropdownMenuItemsMia[0].value;
          Provider.of<Rests>(context).fetchAndSetRests(_selectedMiasto.miaId).then((_) {  //z bazy lokalnej

            setState(() {
              _isLoading = false; //zatrzymanie wskaznika ładowania dań
            });
          }); //dostawca restauracji
          setState(() {
            _isLoading = false; //zatrzymanie wskaznika ładowania dań
          });
        }); 
      });
    }
    _isInit = false;
    //Provider.of<Rests>(context, listen: false).fetchAndSetRests(); //dostawca restauracji
    super.didChangeDependencies();
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
        //_isLoading = false; //zatrzymanie wskaznika ładowania dań
      });

      Provider.of<Rests>(context).fetchAndSetRests(_selectedMiasto.miaId).then((_) {  //z bazy lokalnej

      setState(() {
        _isLoading = false; //zatrzymanie wskaznika ładowania dań
      });
    }); //dostawca restauracji

    }); 
  }

  //jezeli nastąpiła zmiana miasta
  onChangeDropdownItemMia(Rest selectedMiasto){
    setState(() {
      _selectedMiasto = selectedMiasto; //wybrane miasto 
      _isLoading = true;    
    });
    
    Provider.of<Rests>(context).fetchAndSetRests(_selectedMiasto.miaId).then((_) {  //z bazy lokalnej

      setState(() {
        _isLoading = false; //zatrzymanie wskaznika ładowania dań
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
          adres: item['obiekt'],        
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
          adres: item['obiekt'],        
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
      print('miaRest $_miaRest');
    return _miaRest;      
  }

  

  @override
  Widget build(BuildContext context) {
    print ('location budowanie ekranu');
  final restsData = Provider.of<Rests>(context);
  //final wojData = restsData.items.where((rest) {return rest.woj.contains('9');}).toList();
  
  final rests = restsData.items.toList(); 
  print('restsR $rests'); 
  print('rests.nazwa ${rests[0].nazwa}'); 
  String _currentValue = '27';

    return Scaffold(
      appBar :AppBar( 
        title: Text('Wybierz lokal')
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
              SizedBox(height: 10.0),
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
                          Text('Województwo'),
                          //SizedBox(height: 5.0),
                          DropdownButton(
                            style: TextStyle(
                              fontSize: 20,
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
                          Text('Miasto'),
                          //SizedBox(height: 5.0),
                          DropdownButton(
                            style: TextStyle(
                              fontSize: 20,
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
             //  Column(
              //   children: <Widget>[

                  ListView( 
                    padding: EdgeInsets.all(8.0),
                    children: rests.map((item) => RadioListTile(
                        groupValue: _currentValue,
                        title: Text(item.nazwa),
                        value: item.id,
                        onChanged: (val) {
                            setState(() {
                                //debugPrint('VAL = $val');
                                //_currentValue = val;
                            });
                        },
                    )).toList(),
                  ),
/*
                 RadioListTile<SingingCharacter>(
                    title: const Text('Lafayette'),
                    value: SingingCharacter.lafayette,
                    groupValue: _character,
                    onChanged: (SingingCharacter value) { setState(() { _character = value; }); },
                  ),
                  RadioListTile<SingingCharacter>(
                    title: const Text('Thomas Jefferson'),
                    value: SingingCharacter.jefferson,
                    groupValue: _character,
                    onChanged: (SingingCharacter value) { setState(() { _character = value; }); },
                  ),
*/

             //    ],
            //   ),
                /*
              Text('Województwo'),
              SizedBox(height: 20.0),
              DropdownButton(
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                value: _selectedWoj,
                items: _dropdownMenuItemsWoj,
                onChanged:  onChangeDropdownItemWoj,
              ),
              SizedBox(height: 20.0),
              //Text ('wybrwłeś: ${_selectedWoj.wojId}'),
              SizedBox(height: 20.0),
              
              
              DropdownButton(
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                value: _selectedMiasto,
                items: _dropdownMenuItemsMia,
                onChanged:  onChangeDropdownItemMia,
              ),
              SizedBox(height: 20.0),
              //Text ('wybrwłeś: ${_selectedMiasto.miaId}'),
             */ 
            ],
          ) ,

          
          
        ),
      ),
    );
  }
}
 