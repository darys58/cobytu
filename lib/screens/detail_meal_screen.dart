//ekran szczegółów dania
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
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
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
      fetchMemoryMeal().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
        fetchMemoryLok().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
          fetchDetailMealFromSerwer(mealId).then((_) { 
            print('pobranie szczegółów');
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
     // print('dane restauracji w MealRests = ${_detailMealData[0].alergeny}');
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
      return _memLok;
  }
  
  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
    //final loadedMeal = Provider.of<Meals>(context).items.firstWhere((ml) => ml.id == mealId);//dla uproszczenia kodu przeniesiona do meals.dart i wtedy jak nizej
    final loadedMeal = Provider.of<Meals>(context, listen: false).findById(mealId);

    //print('dane restauracji w MealRests = ${_detailMealData[0].alergeny}');
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
              //zdjęcie dania
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
                  Row(// czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                    children: <Widget>[
                      Icon(
                        Icons.fitness_center, color: Theme.of(context).primaryColor, //schedule
                      ),
                      SizedBox(
                        width: 2,
                      ), //odległość miedzy ikoną i tekstem
                      Text(
                        '${detailMealData[0].waga}' + ' g',
                      ), //interpolacja ciągu znaków
                    ],
                  ),
                  SizedBox(
                        width: 20,
                      ),
                  Row(// czas - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                    children: <Widget>[
                      Icon(
                        Icons.battery_unknown, color: Theme.of(context).primaryColor, //schedule
                      ),
                      SizedBox(
                        width: 2,
                      ), //odległość miedzy ikoną i tekstem
                      Text(
                        '${detailMealData[0].kcal}' + ' kcal',
                      ), //interpolacja ciągu znaków
                      SizedBox(
                        width: 20,
                      ),                     
                    ],
                  ),                 
                ]
              ),
            ),
            Row( //całą zawatość kolmny stanowi wiersz
              mainAxisAlignment: MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
              children: <Widget>[
              Expanded(
                  child:Padding(
                    padding: EdgeInsets.all(10.0),
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
            )
          ]
        )
      ),
      bottomSheet:  
        _isLoading 
        ? Center(
          //child: CircularProgressIndicator(), //kółko ładowania danych
          )
        : Container(
        height: 50,
        color: Colors.grey,
        width: MediaQuery.of(context).size.width,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstęp między lewą kolumną z tekstami a zdjęciem              
          children: <Widget>[
            SizedBox(
              width: 10,
            ), 
            Text(
             '${detailMealData[0].cena} PLN', 
              style: TextStyle(
                fontSize: 22,
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