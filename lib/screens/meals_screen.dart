//lista dań w wybranej kategorii

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../models/meals.dart';
import '../models/meal.dart';
import '../models/mem.dart';
import '../models/mems.dart';
import '../models/rests.dart';
import '../models/podkat.dart';
import '../widgets/meal_item.dart';

class MealsScreen extends StatefulWidget {
  //stanowy bo usuwanie dań
  //stanowy bo usuwanie przepisów z listy
  static const routeName = '/category-meals'; //nazwa trasy do tego ekranu

  //do modyfikowania listy posiłków przez ustawianie filtów
  //final List<Meal> availableMeals;

  //CategoryMealsScreen(this.availableMeals);

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  String reload = 'false'; //czy załadować dane z serwera - przeładowanie danych?
  String initApp = 'false'; //czy jest to inicjalizacja apki - pierwsze uruchomienie po zainstalowaniu?
  String reloadTemp = 'false'; 
  String initAppTemp = 'false';
  final wersja = ['1','0','1','05.05.2020','nic','nic']; //major, minor, numer wydania, data publikacji, 

  String podkategoria1 = '291'; //wybrana podkategoria, domyślnie 291 czyli "Wszystkie" w kategorii 1
  String podkategoria2 = '292'; //wybrana podkategoria, domyślnie 292 czyli "Wszystkie" w kategorii 2
  String podkategoria3 = '293'; //wybrana podkategoria, domyślnie 293 czyli "Wszystkie" w kategorii 3
  String podkategoria4 = '294'; //wybrana podkategoria, domyślnie 294 czyli "Wszystkie" w kategorii 4
  String podkategoria5 = '295'; //wybrana podkategoria, domyślnie 295 czyli "Wszystkie" w kategorii 5
  String podkategoria6 = '296'; //wybrana podkategoria, domyślnie 296 czyli "Wszystkie" w kategorii 6
  String podkategoria7 = '297'; //wybrana podkategoria, domyślnie 297 czyli "Wszystkie" w kategorii 7
  String podkategoria8 = '298'; //wybrana podkategoria, domyślnie 298 czyli "Wszystkie" w kategorii 8
  String podkategoria9 = '299'; //wybrana podkategoria, domyślnie 299 czyli "Wszystkie" w kategorii 9
  String rodzaj = ''; //wybrany rodzaj dania np. Dania litewskie
  String categoryTitle;
  List<Mem> _memLok; //dane wybranej lokalizacji w tabeli memory - baza lokalna
  List<Mem> _memVer; //dane wersji aplikacji i bazy danych w tabeli memory - baza lokalna
  String _tytul = 'Lista dań'; //tytuł tymczasowy
  //String _selectedItem = '';
  List<Meal> meals1;
  List<Meal> meals2;
  List<Meal> meals3;
  List<Meal> meals4;
  List<Meal> meals5;
  List<Meal> meals6;
  List<Meal> meals7;
  List<Meal> meals8;
  List<Meal> meals9;
  /// bieżący czas, w „sekundach od epoki”
  static int currentTimeInSeconds () {
      var ms = (new DateTime.now ()). millisecondsSinceEpoch;
      return (ms / 1000) .round ();
  }
  @override
  void initState() { 
    print('wejście do initState');
    //_setPrefers('reload', 'true');  //dane aktualne - nie trzeba przeładować danych
    //_setPrefers('initApp', 'true'); //inicjalizacja apki przeprowadzona
    //zainicjowanie stanu po zmianie np. usunięciu dania
    //.... przeniesiono do didChangeDependencies()
    //przeniesiono bo nie działa tu ModalRoute bo initState uruchamia się przed uruchomieniem tego widzetu i nie ma jeszcze kontekstu.
    //tzn. ze w tym momencie nie mozna pobrać danych o trasie. Kontext tu nie działa !!!
    super.initState();
  }

  @override
  void didChangeDependencies() {
     
    print('wejscie do Dependencies ms 1');
    print('_isInit = $_isInit');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
      
      print('wejscie do Dependencies - Init meals_screen - czas...');
      print(currentTimeInSeconds ());
      fetchMemoryVer().then((_){  //pobranie danych o wersji apki   
        if (_memVer.isNotEmpty ){ 
          if(_memVer[0].a == wersja[0] && _memVer[0].b == wersja[1] && _memVer[0].c == wersja[2]){  // jezeli jest zgodna wersja aplikacji to przejdz dalej za ifa
              print('zgodna _memVer[0].a =${_memVer[0].a}'); 
          }else{ //jezeli niezgodna wersja apki to zmiana bazy w całości
            print('niezgodna _memVer[0].a =${_memVer[0].a}');
            reloadTemp = 'true'; //ustawienia tymczasowe
            initAppTemp = 'true'; //ustawienia tymczasowe
            _setPrefers('reload', 'true');  //trzeba przeładować dane - ustawienie do zapamiętania
            _setPrefers('initApp', 'true'); //potrzebna inicjalizacja apki - ustawienie do zapamiętania 
          }       
        }else{ //jezeli nie ma rekordu memVer tzn. ze nie ma bazy
          print('niema memVer - brak bazy danych');
            reloadTemp = 'true'; //ustawienia tymczasowe
            initAppTemp = 'true'; //ustawienia tymczasowe
            _setPrefers('reload', 'true');  //trzeba załadować dane - ustawienie do zapamiętania
            _setPrefers('initApp', 'true'); //potrzebna inicjalizacja apki - ustawienie do zapamiętania
        }
      
        _getPrefers().then((_) { //pobranie zmiennych globalnych
          if(reloadTemp == 'true' || reload == 'true' || reload == '0'){ //jezeli trzeba przeładować lub nie ma zmiennej 'reload'
            print ('trzeba załadować dane z serwera');
            if(initAppTemp == 'true' || initApp == 'true' || initApp == '0'){ //jezeli pierwsze uruchomienie apki
              //ładowanie danych domyślnych
              print('pierwsze uruchomienie apki!!!!!!!!');
            DBHelper.deleteBase().then((_) {  //kasowanie całej bazy danych bo będzie nowa
              Mems.insertMemory('memLok', '14','wielkopolskie','1', 'Konin','0','Wszystkie');//default '27','Borówka'
              Mems.insertMemory('memVer', wersja[0], wersja[1], wersja[2], wersja[3], wersja[4], wersja[5]);//default
              //print('usunięcie wszystkich danych i wczytanie danych domślnych');
              //fetchMemoryLok().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
                //Meals.deleteAllMeals().then((_) {  //kasowanie tabeli dań w bazie lokalnej
                  //Rests.deleteAllRests().then((_) {  //kasowanie tabeli restauracji w bazie lokalnej
                    //Podkategorie.deleteAllPodkategorie().then((_) {  //kasowanie tabeli podkategorii w bazie lokalnej
                      Meals.fetchMealsFromSerwer('https://cobytu.com/cbt.php?d=f_dania&uz_id=&woj_id=14&mia_id=1&rest=&lang=pl').then((_) { 
                        Rests.fetchRestsFromSerwer().then((_) { 
                          Podkategorie.fetchPodkategorieFromSerwer('https://cobytu.com/cbt.php?d=f_podkategorie&uz_id=&woj_id=14&mia_id=1&rest=27&lang=pl').then((_) { 
                            Provider.of<Meals>(context).fetchAndSetMeals().then((_) {  //z bazy lokalnej
                              Provider.of<Podkategorie>(context).fetchAndSetPodkategorie().then((_) {  //z bazy lokalnej
                                _setPrefers('reload', 'false');  //dane aktualne - nie trzeba przeładować danych
                                _setPrefers('initApp', 'false'); //inicjalizacja apki przeprowadzona
                                setState(() {
                                  _tytul = 'Konin';
                                  //_tytul = (_memLok[0].e == '0') ? _memLok[0].d : _memLok[0].f; //nazwa miasta lub restauracji 
                                  _isLoading = false; //zatrzymanie wskaznika ładowania danych
                                });
                              }); 
                            });
                          });  
                        });            
                      });
                    //});
                  //});  
                //});
              });
            }else{ //przeładowanie danych - z serwera (bo np. zmiana lokalizacji)
              print('przeładowanie danych - z serwera (bo np. zmiana lokalizacji)');
              fetchMemoryLok().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
                Meals.deleteAllMeals().then((_) {  //kasowanie tabeli dań w bazie lokalnej
                  Rests.deleteAllRests().then((_) {  //kasowanie tabeli restauracji w bazie lokalnej
                    Podkategorie.deleteAllPodkategorie().then((_) {  //kasowanie tabeli podkategorii w bazie lokalnej
                      Meals.fetchMealsFromSerwer('https://cobytu.com/cbt.php?d=f_dania&uz_id=&woj_id=${_memLok[0].a}&mia_id=${_memLok[0].c}&rest=${_memLok[0].e}&lang=pl').then((_) { 
                        Rests.fetchRestsFromSerwer().then((_) { 
                          Podkategorie.fetchPodkategorieFromSerwer('https://cobytu.com/cbt.php?d=f_podkategorie&uz_id=&woj_id=${_memLok[0].a}&mia_id=${_memLok[0].c}&rest=${_memLok[0].e}&lang=pl').then((_) { 
                            Provider.of<Meals>(context).fetchAndSetMeals().then((_) {  //z bazy lokalnej
                              Provider.of<Podkategorie>(context).fetchAndSetPodkategorie().then((_) {  //z bazy lokalnej
                                _setPrefers('reload', 'false');  //dane aktualne - nie trzeba przeładować danych
                                setState(() {
                                  _tytul = (_memLok[0].e == '0') ? _memLok[0].d : _memLok[0].f; //nazwa miasta lub restauracji 
                                  _isLoading = false; //zatrzymanie wskaznika ładowania danych
                                });
                              });
                            });   
                          });
                        });            
                      });
                    });
                  });
                });
              });
            }
          }else { //załadowanie dań z bazy loklnej - nie było potrzeby przeładowania danych
            fetchMemoryLok().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej (zeby uzyskać nazwę restacji jako tytuł ekranu)
              print('dane lokalne - załadowanie dań z bazy loklnej');
              Provider.of<Meals>(context).fetchAndSetMeals().then((_) {  //z bazy lokalnej
                Provider.of<Podkategorie>(context).fetchAndSetPodkategorie().then((_) {  //z bazy lokalnej
                  setState(() {
                    _tytul = (_memLok[0].e == '0') ? _memLok[0].d : _memLok[0].f; //nazwa miasta lub restauracji 
                    _isLoading = false; //zatrzymanie wskaznika ładowania dań
                  });
                });
              });
            }); 
          }
        });    
      }); 
    }
    _isInit = false;
    super.didChangeDependencies();
  }
  
  //ustawienianie zmiennych globalnych
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }

  //odczyt zmiennych globalnych
  _getPrefers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reload = prefs.getString('reload') ?? '0';
      initApp = prefs.getString('initApp') ?? '0';
      //podkategoria = prefs.getString('podkategoria') ?? '0';
    });
    print('get reload=$reload');
  }

    //pobranie memory z bazy lokalnej
  Future<void> fetchMemoryVer()async{
    final data = await DBHelper.getMemory('memVer');
    _memVer = data.map(
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
    return _memVer;
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
/*  szuflada od dołu
  void _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 180,
            child: Container(
              child: _buildBottomNavigationMenu(),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
              ),
            ),
          );
        });
  }

  Column _buildBottomNavigationMenu() {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.ac_unit),
          title: Text('Cooling'),
          onTap: () => _selectItem('Cooling'),
        ),
        ListTile(
          leading: Icon(Icons.accessibility_new),
          title: Text('People'),
          onTap: () => _selectItem('People'),
        ),
        ListTile(
          leading: Icon(Icons.assessment),
          title: Text('Stats'),
          onTap: () => _selectItem('Stats'),
        ),
      ],
    );
  }

  void _selectItem(String name) {
    Navigator.pop(context);
    setState(() {
      _selectedItem = name;
      print(_selectedItem);
    });
  }
*/

  @override
  Widget build(BuildContext context) { 
    //final snackBar = SnackBar(content: Text('Zapisano nową lokalizację'));
    //Scaffold.of(context).showSnackBar(snackBar);
    
    //podkategorie + rodzaje
    var podkatData = Provider.of<Podkategorie>(context);
    final podkat1 = podkatData.items.where((podk) {return podk.kaId.contains('1');}).toList();
    final podkat2 = podkatData.items.where((podk) {return podk.kaId.contains('2');}).toList();
    final podkat3 = podkatData.items.where((podk) {return podk.kaId.contains('3');}).toList();
    final podkat4 = podkatData.items.where((podk) {return podk.kaId.contains('4');}).toList();
    final podkat5 = podkatData.items.where((podk) {return podk.kaId.contains('5');}).toList();
    final podkat6 = podkatData.items.where((podk) {return podk.kaId.contains('6');}).toList();
    final podkat7 = podkatData.items.where((podk) {return podk.kaId.contains('7');}).toList();
    final podkat8 = podkatData.items.where((podk) {return podk.kaId.contains('8');}).toList();
    final podkat9 = podkatData.items.where((podk) {return podk.kaId.contains('9');}).toList();
    //print('podk ${podkat4[0].nazwa}');
    
    //dania
    var mealsData = Provider.of<Meals>(context);
    
    if(podkategoria1 == '291') meals1 = mealsData.items.where((meal) {return meal.kategoria.contains('1');}).toList(); //dania dla wybranej kategorii i wersji podstawowej
    else if (int.parse(podkategoria1) < 290) meals1 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria1);}).toList();
    else meals1 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();
    
    if(podkategoria2 == '292') meals2 = mealsData.items.where((meal) {return meal.kategoria.contains('2');}).toList();
    else if (int.parse(podkategoria2) < 290) meals2 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria2);}).toList();
    else meals2 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();
    
    if(podkategoria3 == '293') meals3 = mealsData.items.where((meal) {return meal.kategoria.contains('3');}).toList();
    else if (int.parse(podkategoria3) < 290) meals3 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria3);}).toList();
    else meals3 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();
    
    //print('podkat=$podkategoria');
    if(podkategoria4 == '294') meals4 = mealsData.items.where((meal) {return meal.kategoria.contains('4');}).toList();
    else if (int.parse(podkategoria4) < 290) meals4 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria4);}).toList();
    else meals4 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();
    
    if(podkategoria5 == '295') meals5 = mealsData.items.where((meal) {return meal.kategoria.contains('5');}).toList();
    else if (int.parse(podkategoria5) < 290) meals5 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria5);}).toList();
    else meals5 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();

    if(podkategoria6 == '296') meals6 = mealsData.items.where((meal) {return meal.kategoria.contains('6');}).toList();
    else if (int.parse(podkategoria6) < 290) meals6 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria6);}).toList();
    else meals6 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();

    if(podkategoria7 == '297') meals7 = mealsData.items.where((meal) {return meal.kategoria.contains('7');}).toList();
    else if (int.parse(podkategoria7) < 290) meals7 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria7);}).toList();
    else meals7 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();

    if(podkategoria8 == '298') meals8 = mealsData.items.where((meal) {return meal.kategoria.contains('8');}).toList();
    else if (int.parse(podkategoria8) < 290) meals8 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria8);}).toList();
    else meals8 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();
    
    if(podkategoria9 == '299') meals9 = mealsData.items.where((meal) {return meal.kategoria.contains('9');}).toList();
    else if (int.parse(podkategoria9) < 290) meals9 = mealsData.items.where((meal) {return meal.podkat.contains(podkategoria9);}).toList();
    else meals9 = mealsData.items.where((meal) {return meal.rodzaj.contains(rodzaj);}).toList();
    
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Test"),//Text(categoryTitle),
      //),
      body: DefaultTabController(
        length: 9,
        initialIndex: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_tytul),
            bottom: TabBar(
              isScrollable: true,              
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              tabs: <Widget>[
                Tab(text: 'ŚNIADANIA',), //Tab(icon: Icon(Icons.category),text: 'Kategoria1',),
                Tab(text: 'PRZYSTAWKI',),
                Tab(text: 'ZUPY',),
                Tab(text: 'SAŁATKI',),
                Tab(text: 'DANIA GŁOWNE',),
                Tab(text: 'DLA DZIECI',),
                Tab(text: 'DESERY',),
                Tab(text: 'NAPOJE',),
                Tab(text: 'ALKOHOLE',),
              ],
            ),
          ),
          //drawer:
              //MainDrawer(), //Drawer(child: Text('data'),), //ikona burgera z szufladą
          body: _isLoading  //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          :TabBarView(children: <Widget>[  //wyświetlenie listy dań
            //ŚNIADANIA
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat9.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria9 = podkat9[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat9[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria9 == podkat9[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat9[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat9[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals9[index],
                      child: MealItem(),
                      ),
                    itemCount: meals9.length,
                  ),
                ),
              ],
            ),

            //PRZYSTAWKI
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat1.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria1 = podkat1[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat1[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria1 == podkat1[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat1[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat1[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals1[index],
                      child: MealItem(),
                      ),
                    itemCount: meals1.length,
                  ),
                ),
              ],
            ),

            //ZUPY 
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat2.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria2 = podkat2[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat2[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria2 == podkat2[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat2[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat2[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals2[index],
                      child: MealItem(),
                      ),
                    itemCount: meals2.length,
                  ),
                ),
              ],
            ),
            
            //SAŁATKI
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat3.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria3 = podkat3[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat3[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria3 == podkat3[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat3[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat3[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals3[index],
                      child: MealItem(),
                      ),
                    itemCount: meals3.length,
                  ),
                ),
              ],
            ),            
            
            //DANIA GŁOWNE
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat4.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria4 = podkat4[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat4[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria4 == podkat4[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat4[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat4[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals4[index],
                      child: MealItem(),
                      ),
                    itemCount: meals4.length,
                  ),
                ),
              ],
            ),
            
            // DLA DZIECI
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat5.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria5 = podkat5[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat5[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria5 == podkat5[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat5[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat5[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals5[index],
                      child: MealItem(),
                      ),
                    itemCount: meals5.length,
                  ),
                ),
              ],
            ),

            //DESERY 
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat6.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria6 = podkat6[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat6[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria6 == podkat6[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat6[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat6[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals6[index],
                      child: MealItem(),
                      ),
                    itemCount: meals6.length,
                  ),
                ),
              ],
            ),

            //NAPOJE
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat7.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria7 = podkat7[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat7[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria7 == podkat7[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat7[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat7[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals7[index],
                      child: MealItem(),
                      ),
                    itemCount: meals7.length,
                  ),
                ),
              ],
            ),

            //ALKOHOLE
            Column( 
              mainAxisSize:MainAxisSize.min, 
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: <Widget>[
                //podkategorie
                Container( 
                  padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 1.0),
                  height: 40,//MediaQuery.of(context).size.height * 0.35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: podkat8.length, itemBuilder: (context, index) {
                    return Container(
                      //width: MediaQuery.of(context).size.width * 0.6,
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            podkategoria8 = podkat8[index].id; //dla filtrowania po podkategorii
                            rodzaj = podkat8[index].nazwa; //dla filtrowania po rodzaju dania
                          });
                        },
                        child: podkategoria8 == podkat8[index].id 
                        ? Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat8[index].nazwa, style: TextStyle(color: Colors.black, fontSize: 17.0),)),
                          ),
                        ):Card(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
                            child: Center(child: Text(podkat8[index].nazwa, style: TextStyle(color: Colors.grey, fontSize: 16.0),)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                //lista dań
                Expanded(
                  child: ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                      value: meals8[index],
                      child: MealItem(),
                      ),
                    itemCount: meals8.length,
                  ),
                ),
              ],
            ),
            
/*            
            //PRZYSTAWKI
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals1[index].id,
                  nazwa: meals1[index].nazwa,
                  opis: meals1[index].opis,
                  foto: meals1[index].foto,
                  kategoria: meals1[index].kategoria,
                  cena: meals1[index].cena,
                  czas: meals1[index].czas,
                  waga: meals1[index].waga,
                  kcal: meals1[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals1.length,
            ),
            //ZUPY
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals2[index].id,
                  nazwa: meals2[index].nazwa,
                  opis: meals2[index].opis,
                  foto: meals2[index].foto,
                  kategoria: meals2[index].kategoria,
                  cena: meals2[index].cena,
                  czas: meals2[index].czas,
                  waga: meals2[index].waga,
                  kcal: meals2[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals2.length,
            ),
            //SAŁATKI
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals3[index].id,
                  nazwa: meals3[index].nazwa,
                  opis: meals3[index].opis,
                  foto: meals3[index].foto,
                  kategoria: meals3[index].kategoria,
                  cena: meals3[index].cena,
                  czas: meals3[index].czas,
                  waga: meals3[index].waga,
                  kcal: meals3[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals3.length,
            ),
            //DANIA GŁWNE
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              //separatorBuilder: (ctx,index) => Divider(),
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals4[index].id,
                  nazwa: meals4[index].nazwa,
                  opis: meals4[index].opis,
                  foto: meals4[index].foto,
                  kategoria: meals4[index].kategoria,
                  cena: meals4[index].cena,
                  czas: meals4[index].czas,
                  waga: meals4[index].waga,
                  kcal: meals4[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals4.length,
            ),
            //DLA DZIECI
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals5[index].id,
                  nazwa: meals5[index].nazwa,
                  opis: meals5[index].opis,
                  foto: meals5[index].foto,
                  kategoria: meals5[index].kategoria,
                  cena: meals5[index].cena,
                  czas: meals5[index].czas,
                  waga: meals5[index].waga,
                  kcal: meals5[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals5.length,
            ),
            //DASERY
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals6[index].id,
                  nazwa: meals6[index].nazwa,
                  opis: meals6[index].opis,
                  foto: meals6[index].foto,
                  kategoria: meals6[index].kategoria,
                  cena: meals6[index].cena,
                  czas: meals6[index].czas,
                  waga: meals6[index].waga,
                  kcal: meals6[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals6.length,
            ),
            //NAPOJE
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals7[index].id,
                  nazwa: meals7[index].nazwa,
                  opis: meals7[index].opis,
                  foto: meals7[index].foto,
                  kategoria: meals7[index].kategoria,
                  cena: meals7[index].cena,
                  czas: meals7[index].czas,
                  waga: meals7[index].waga,
                  kcal: meals7[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals7.length,
            ),
            //ALKOHOLE
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) {
                //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
                return MealItem(
                  //pojedynczy element listy
                  id: meals8[index].id,
                  nazwa: meals8[index].nazwa,
                  opis: meals8[index].opis,
                  foto: meals8[index].foto,
                  kategoria: meals8[index].kategoria,
                  cena: meals8[index].cena,
                  czas: meals8[index].czas,
                  waga: meals8[index].waga,
                  kcal: meals8[index].kcal,
                  //removeItem: _removeMeal,
                );
              },
              itemCount: meals8.length,
            ),
        */    ]),
        ),
      ),
/*
      body: ListView.builder(
        //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
        itemBuilder: (ctx, index) {
          //itemBuilder to argument w którym podaje sie metodę budowania wywoływanej dla kazdego elementu listy (kurs 163). Budowany element otrzymuje kontekst i index renderowanego elementu i zostaje zbudowany jako pojedynczy element listy
          return MealItem(
            //pojedynczy element listy
            id: meals[index].id,
            title: meals[index].title,
            imageUrl: meals[index].imageUrl,
            duration: meals[index].duration,
            affordability: meals[index].affordability,
            complexity: meals[index].complexity,
            //removeItem: _removeMeal,
          );
        },
        itemCount: meals.length,
      ),
*/
      //Center(
      //child: Text(
      //  'The Recipis For  The Category!',
      //),
      //),
    );
  }
}
