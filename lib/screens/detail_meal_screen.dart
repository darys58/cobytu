//ekran szczegółów dania
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:grouped_buttons/grouped_buttons.dart';
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../models/mem.dart';
import '../models/mems.dart';
import '../models/meals.dart';
import '../models/detailMeal.dart';


class DetailMealScreen extends StatefulWidget {
  static const routeName = '/detail-meal';

  @override
  _DetailMealScreenState createState() => _DetailMealScreenState();
}

class _DetailMealScreenState extends State<DetailMealScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  List<DetailMeal> _detailMealData = []; //szczegóły dania
  List<Mem> _memMeal; //dane wybranego dania w tabeli memory - baza lokalna
  List<Mem> _memLok; //dane wybranej restauracji w tabeli memory - baza lokalna
  var detailMealData;
  
  List<DropdownMenuItem<String>> _dropdownMenuItemsWer; ////lista wersji dania dla buttona wyboru
  String _selectedWer; //wybrana wersja dania
  
  List<DropdownMenuItem<String>> _dropdownMenuItemsWar1; ////lista dodatków wariantowych 1 dla buttona wyboru
  List<String> _listWar1; //lista dodatków wariantowych 1 jako lista stringów, zeby uzyskać index wybranego dodatku
  String _selectedWar1; //wybrany dodatek wariantowy 1
  int war1Id = 0; //index wybranego dodatku wariantowego 1 (index miejsca na liście a nie id dodatku )
  
  List<DropdownMenuItem<String>> _dropdownMenuItemsWar2; ////lista dodatków wariantowych 2 dla buttona wyboru
  List<String> _listWar2; //lista dodatków wariantowych 2 jako lista stringów, zeby uzyskać index wybranego dodatku
  String _selectedWar2; //wybrany dodatek wariantowy 2
  int war2Id = 0; //index wybranego dodatku wariantowego 2 (index miejsca na liście a nie id dodatku )

  List<String> _listDod; //lista dodatków dodatkowych do wyboru
  List<String> _selectedDod = []; //wybrane dodatki dodatkowe
  
  bool _isChecked = true;
  int _waga; //waga ustawiana w funkcji przelicz()
  int _kcal; //kcal ustawiana w funkcji przelicz()
  String _cena; //cena ustawiana w funkcji przelicz()
  
  

  @override
  void didChangeDependencies() {
    print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
      fetchMemoryMeal().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
        fetchMemoryLok().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
          fetchDetailMealFromSerwer(mealId).then((_) { 
            print('pobranie szczegółów');
            if (_detailMealData[0].werList.isNotEmpty){
              _dropdownMenuItemsWer = buildDropdownMenuWar(_detailMealData[0].werList); 
              _selectedWer = _dropdownMenuItemsWer[0].value;  //domyślny war1     
            }  
            if (_detailMealData[0].warList1.isNotEmpty){
              _dropdownMenuItemsWar1 = buildDropdownMenuWar(_detailMealData[0].warList1); 
              _selectedWar1 = _dropdownMenuItemsWar1[0].value;  //domyślny war1 
              _listWar1 = List<String>.from(_detailMealData[0].warList1);   
            }
            if (_detailMealData[0].warList2.isNotEmpty){
            _dropdownMenuItemsWar2 = buildDropdownMenuWar(_detailMealData[0].warList2); 
            _selectedWar2 = _dropdownMenuItemsWar2[0].value;  //domyślny war2
            _listWar2 = List<String>.from(_detailMealData[0].warList2);  
            }

            _listDod = List<String>.from(_detailMealData[0].dodat);//zmiana typu List<dynamic> na List<String>
            
            przelicz();
            
            print('dod dodatkowe = ');
            print (_listDod);
          //ustawienie war1 domyślnego hite
          //var countWar1 = _dropdownMenuItemsWar1.length;
          //for (var i = 0; i < countWar1; i++) {
            //if(_dropdownMenuItemsWar1[i].value == _memLok[0].b){  //b:woj
   //           _selectedWar1 = _dropdownMenuItemsWar1[0].value;  //domyślny war1  
           // }  
         // }
            
            
            setState(() {
              _isLoading = false; //zatrzymanie wskaznika ładowania dań
              detailMealData  = _detailMealData ;
            });
          });
        });
      });
    }
  _isInit = false;
    super.didChangeDependencies();  
  }

  //jezeli nastapiła zmiana dodatku wariantowego 1 
  onChangeDropdownItemWar1(String selectedWar1){

    setState(() {
      _selectedWar1 = selectedWar1; //zmiana war1
     // _isLoading = true; //uruchomienie wskaznika ładowania dań (tu chyba niepotrzebnie)
    });

  }

  //jezeli nastapiła zmiana dodatku wariantowego 1 
  onChangeDropdownItemWar2(String selectedWar2){

    setState(() {
      _selectedWar2 = selectedWar2; //zmiana war2
     // _isLoading = true; //uruchomienie wskaznika ładowania dań (tu chyba niepotrzebnie)
    });
  }

  onChangeDropdownItemWer(String selectedWer){

    setState(() {
      _selectedWer = selectedWer; //zmiana wersji dania
     // _isLoading = true; //uruchomienie wskaznika ładowania dań (tu chyba niepotrzebnie)
    });
  }

  //tworzenie buttonów wyboru dodatków wariantowych 1 i 2
  List<DropdownMenuItem<dynamic>>buildDropdownMenuWar(List<dynamic> lista){
    List<DropdownMenuItem<String>> items = List();    
    print('lista do budowania buttona $lista');
    for (String war in lista) {
      print(war);
      items.add(
        DropdownMenuItem(
          value: war,
          child: Text(war),
        ),
      );
    }
    return items;
  }


  //pobranie (z serwera www) szczegółów dania - dla szczegółów dania
  Future<List<DetailMeal>> fetchDetailMealFromSerwer(String idDania) async {
    var url = 'https://cobytu.com/cbt.php?d=f_danie&danie=${_memMeal[0].a}&uz_id=&rest=${_memLok[0].e}&lang=pl';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return[];
      }

      //final List<MealRest> loadedRests = [];
      extractedData.forEach((mealId, mealData) {
        _detailMealData.add(DetailMeal(
          id: mealId,
          nazwa: mealData['da_nazwa'], 
          opis: mealData['da_opis'],       
          cena: mealData['cena'],   
          czas: mealData['da_czas'],       
          waga: mealData['waga'], 
          kcal: mealData['kcal'], 
          lubi: mealData['da_lubi'], 
          stolik: mealData['na_stoliku'], 
          alergeny: mealData['alergeny'], 
          srednia: mealData['da_srednia'], 
          cenaPodst: mealData['cena_podst'], 
          wagaPodst: mealData['da_waga_podst'], 
          kcalPodst: mealData['da_kcal_podst'], 
          werListId: mealData['da_id_lista_wer'], 
          werList: mealData['da_wersja_lista'], 
          warUlub: mealData['do_wariant'], 
          warList1: mealData['do_wariant_lista1'], 
          warList2: mealData['do_wariant_lista2'], 
          dodat: mealData['do_dodat'], 
          podstId: mealData['do_podst_id'], 
          warUlubId: mealData['do_wariant_id'], 
          warList1Id: mealData['do_wariant_lista1_id'], 
          warList2Id: mealData['do_wariant_lista2_id'], 
          dodatId: mealData['do_dodat_id'],  
          warList1Waga: mealData['do_wariant_lista1_waga'],        
          warList2Waga: mealData['do_wariant_lista2_waga'], 
          dodatWaga: mealData['do_dodat_waga'], 
          warList1Kcal: mealData['do_wariant_lista1_kcal'], 
          warList2Kcal: mealData['do_wariant_lista2_kcal'], 
          dodatKcal: mealData['do_dodat_kcal'], 
          warList1Cena: mealData['do_wariant_lista1_cena'], 
          warList2Cena: mealData['do_wariant_lista2_cena'], 
          dodatCena: mealData['do_dodat_cena'],       
        ));
      });
     // _items = loadedRests;
     print('dane dania war1 = ${_detailMealData[0].warList1}');
      //notifyListeners();
    return _detailMealData;
    } catch (error) {
      throw (error);
    }
  }
  
  
  //pobranie memory z bazy lokalnej
   Future<void> fetchMemoryMeal()async{
    final data = await DBHelper.getMemory('memDanie');
    _memMeal = data.map(
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
      print('memoryMeal$_memMeal');
      return _memMeal;
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
      print('memoryLok$_memLok');
      return _memLok;
  }

  przelicz(){
    int waga = 0;
    int kcal = 0;
    double cena = 0.00;

    waga += int.parse(_detailMealData[0].wagaPodst);         //waga podstawowa
    kcal += int.parse(_detailMealData[0].kcalPodst);         //kcal podstawowe
    cena +=  double.parse(_detailMealData[0].cenaPodst);     //cena podstawowa
    
    if (_detailMealData[0].warList1.length > 0) {                     //jeżeli są dodatki wariant1
      waga += int.parse(_detailMealData[0].warList1Waga[war1Id]);     //+ wariant1
      kcal += int.parse(_detailMealData[0].warList1Kcal[war1Id]);     //+ wariant1
      cena += double.parse(_detailMealData[0].warList1Cena[war1Id]);  //+ wariant1
    }

    if (_detailMealData[0].warList2.length > 0) {                     //jeżeli są dodatki wariant2
      waga += int.parse(_detailMealData[0].warList2Waga[war2Id]);     //+ wariant2
      kcal += int.parse(_detailMealData[0].warList2Kcal[war2Id]);     //+ wariant2
      cena += double.parse(_detailMealData[0].warList2Cena[war2Id]);  //+ wariant2
    }

    for (String dodatek in _selectedDod) {
      int inx = _listDod.indexOf(dodatek); //index dodatku dodatkowego z listy wszystkich dodatków dodatkowych
      waga += int.parse(_detailMealData[0].dodatWaga[inx]);
      kcal += int.parse(_detailMealData[0].dodatKcal[inx]);
      cena += double.parse(_detailMealData[0].dodatCena[inx]);
    }
    
    setState(() {
      _waga = waga; 
      _kcal = kcal;
      _cena = cena.toStringAsFixed(2); //zamiana z double na string w formacie XXX.XX
     
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
    //final loadedMeal = Provider.of<Meals>(context).items.firstWhere((ml) => ml.id == mealId);//dla uproszczenia kodu przeniesiona do meals.dart i wtedy jak nizej
    final loadedMeal = Provider.of<Meals>(context, listen: false).findById(mealId);
print('budowa widzetu');
    !_isLoading ? print('dane dania war1 = ${detailMealData[0].warList1}') : print('nic');
  print(loadedMeal.foto);
  //print(_mealRestsData[0].foto);
    
    
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMeal.nazwa),
      ),
       body: _isLoading ? Center(
              //child: CircularProgressIndicator(), //kółko ładowania danych
            ) : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
//=== zdjęcie dania
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedMeal.foto.replaceFirst(RegExp('_m.jpg'), '.jpg'),//usuniecie _m z nazwy zdjęcia
                fit: BoxFit.cover, //dopasowanie do pojemnika
              ),
            ),
            Padding(//odstępy dla wiersza z ikonami
              padding: EdgeInsets.only(top: 15),
              child: Row( //rząd z informacjami o posiłku
                mainAxisAlignment:
                  MainAxisAlignment.end, //główna oś wyrównywania
                  
                children: <Widget>[ //elementy rzędu które sa widzetami
                  Row(// czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                    children: <Widget>[
  //=== czas                    
                      Icon(
                        Icons.hourglass_empty, color: Theme.of(context).primaryColor, //schedule
                      ),
                      SizedBox(
                        width: 2,
                      ), //odległość miedzy ikoną i tekstem
                      Text(
                        detailMealData[0].czas + ' min',
                      ), //interpolacja ciągu znaków
                    ],
                  ),
                  SizedBox(
                        width: 20,
                      ),
//=== waga 
                  Row(// czas                               
                    children: <Widget>[                     
                      Icon(
                        Icons.fitness_center, color: Theme.of(context).primaryColor, 
                      ),
                      SizedBox(
                        width: 2,
                      ), //odległość miedzy ikoną i tekstem
                      Text(
                        '$_waga' + ' g',
                      ),
                    ],
                  ),
                  SizedBox(
                        width: 20,
                      ),
                  Row(// czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                    children: <Widget>[
//=== kcal                     
                      Icon(
                        Icons.battery_unknown, color: Theme.of(context).primaryColor, //schedule
                      ),
                      SizedBox(
                        width: 2,
                      ), //odległość miedzy ikoną i tekstem
                      Text(
                        '$_kcal' + ' kcal',
                      ), //interpolacja ciągu znaków
                      SizedBox(
                        width: 20,
                      ),                     
                    ],
                  ),                 
                ]
              ),
            ),
//=== opis 
            Row( //całą zawatość kolmny stanowi wiersz
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
              children: <Widget>[
              Expanded(
                  child:Padding(
                    padding: EdgeInsets.only(left:20.0, top:20.0, right:20, bottom:5),                 
                    child: Text(
                      detailMealData[0].opis,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),                 
              ]
            ),
//wersja dania
            if (_detailMealData[0].werList.isNotEmpty)
              Row( //całą zawatość kolmny stanowi wiersz
                mainAxisAlignment: MainAxisAlignment.start, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
                children: <Widget>[
                  SizedBox(width: 20,),
                  DropdownButton(
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                    value: _selectedWer,
                    items: _dropdownMenuItemsWer,
                    onChanged:  onChangeDropdownItemWer,
                  ),
                ]
              ),
//dodatek wariantowy 1
            if (_detailMealData[0].warList1.isNotEmpty)
              Row( //całą zawatość kolmny stanowi wiersz
                mainAxisAlignment: MainAxisAlignment.start, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
                children: <Widget>[
                  SizedBox(width: 20,),
                  Text(
                    '+',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 15,),
                  DropdownButton(
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                    value: _selectedWar1, //ustawiona, widoczna wartość - nazwa dodatku
                    items: _dropdownMenuItemsWar1,  //lista elementów do wyboru
                    onChanged:(String newValue) {  //wybrana nowa wartość - nazwa dodatku
                      setState(() {
                        _selectedWar1 = newValue;
                        war1Id = _listWar1.indexOf(newValue); //pobranie indexu wybranego dodatku z listy
                        przelicz();
                      });
                    }  //onChangeDropdownItemWar1,
                  ),
                ]
              ),
          
//dodatek wariantowy 2
            if (_detailMealData[0].warList2.isNotEmpty) 
              Row( //całą zawatość kolmny stanowi wiersz
                mainAxisAlignment: MainAxisAlignment.start, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
                children: <Widget>[
                  SizedBox(width: 20,),
                  Text('+',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 15,),
                  DropdownButton(
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                    value: _selectedWar2,
                    items: _dropdownMenuItemsWar2,
                    onChanged:  (String newValue) {  //wybrana nowa wartość - nazwa dodatku
                      setState(() {
                        _selectedWar2 = newValue;
                        war2Id = _listWar2.indexOf(newValue); //pobranie indexu wybranego dodatku z listy
                        przelicz();
                      });
                    },
                  ),
                ]
              ),            
//dodatki dodatkowe          
            CheckboxGroup(
              activeColor: Theme.of(context).primaryColor,
              checkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              margin:  EdgeInsets.only(top: 5, right: 10.0),
              labels: _listDod, //lista z nazwami dodatków dodatkowych
              onChange: (bool isChecked, String label, int index) {//
                //przelicz();
                //print("isChecked: $isChecked   label: $label  index: $index");//np. isChecked: true   label: sos pieczeniowy  index: 0
              },
              onSelected: (selectedDod){
                setState(() {
                  _selectedDod = selectedDod; //
                  przelicz();
                });
                //print('_selectedDod: $_selectedDod');
                //print("checked: ${_selectedDod.toString()}");
                },
            ),

          ]
        )
      ),
//=== stopka
      bottomSheet:  
        _isLoading 
        ? Center(
          //child: CircularProgressIndicator(), //kółko ładowania danych
          )
        : Container(
        height: 54,
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
          children: <Widget>[
            SizedBox(
              width: 20,
            ), 
//=== cena            
            Text(
             '$_cena' + ' PLN', 
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ],
        )
      ),
    );
  }
}
    /*
      
    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedMeal.title}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              //zdjęcie dania
              height: 300,
              width: double.infinity,
              child: Image.network(
                selectedMeal.imageUrl,
                fit: BoxFit.cover, //dopasowanie do pojemnika
              ),
            ),
           // buildSectionTitle(
              //  context, 'Ingredients'), //zamiast tego co nizej zaremowane
            
            //frafment zamieniony wyzej na widget zeby nie powtarzać kodu w wielu miejscach
            Container(  //napis Ingriediens
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Ingredients',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            

            
            //opis jak wyzej
            Container(
              //lista składników
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              height: 200,
              width: 300,
              child: ListView.builder( ..... było to co nizej
              
           // buildContainer(
           /  ListView.builder(
                itemBuilder: (ctx, index) => Card(
                  //budowanie listy
                  color: Theme.of(context).accentColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Text(
                      selectedMeal.ingredients[index],
                    ),
                  ),
                ),
                itemCount: selectedMeal.ingredients.length,
              ),
            ),
            buildSectionTitle(context, 'Steps'),
            buildContainer(
              ListView.builder(
                itemBuilder: (ctx, index) => Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        child: Text('# ${(index + 1)}'),
                      ),
                      title: Text(
                        selectedMeal.steps[index],
                      ),
                    ),
                    Divider() //pozioma szara linia
                  ],
                ),
                itemCount: selectedMeal.steps.length, //ilość elementów listy
              ),
            ),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          isFavorite(mealId) ? Icons.star : Icons.star_border,
        ),
        onPressed: () => toggleFavorite(mealId),
        
        //() {
        //  Navigator.of(context).pop(mealId); //pop zdejmuje ekran ze stosu (podobnie jak przycisk "wstecz" <-), //mona w ten sposób zamyka okna dialogowe np.
          //popAndPushNamed   - wyrzuca biezącą stronę i wypycha nowa nazwaną stronę. Przekazuje tez argument mealID na stronę z której przyszadł
        //},
      ),
    );
  }
}
*/