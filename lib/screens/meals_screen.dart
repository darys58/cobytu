//lista dań w wybranej kategorii

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mems.dart';
import '../models/rests.dart';
import '../models/meals.dart';
import '../widgets/main_drawer.dart';
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
  String categoryTitle;
  
  @override
  void initState() { 
    //zainicjowanie stanu po zmianie np. usunięciu dania
    //.... przeniesiono do didChangeDependencies()
    //przeniesiono bo nie działa tu ModalRoute bo initState uruchamia się przed uruchomieniem tego widzetu i nie ma jeszcze kontekstu.
    //tzn. ze w tym momencie nie mozna pobrać danych o trasie. Kontext tu nie działa !!!
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print('wejscie do Dependencies');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania dań
      });
      print('wejscie do Dependencies - Init meals_screen');
      
      if(false){
        Mems.insertMemory('memLok', '14','wielkopolskie','1', 'Konin','27','Borówka');//dane startowe
        Meals.deleteAllMeals().then((_) {  //kasowanie tabeli dań w bazie lokalnej
          Rests.deleteAllRests().then((_) {  //kasowanie tabeli restauracji w bazie lokalnej
            Meals.fetchMealsFromSerwer('https://cobytu.com/cbt.php?d=f_dania&uz_id=&woj_id=14&mia_id=1&rest=&lang=pl').then((_) { 
              Rests.fetchRestsFromSerwer().then((_) { 
                Provider.of<Meals>(context).fetchAndSetMeals().then((_) {  //z bazy lokalnej
                  setState(() {
                    _isLoading = false; //zatrzymanie wskaznika ładowania dań
                  });
                }); 
              });            
            });
          });
        });
      }else {
         Provider.of<Meals>(context).fetchAndSetMeals().then((_) {  //z bazy lokalnej
          setState(() {
            _isLoading = false; //zatrzymanie wskaznika ładowania dań
          });
        });
      }
      /*
        Provider.of<Meals>(context).fetchAndSetMeals().then((_) {  //z bazy lokalnej
          setState(() {
            _isLoading = false; //zatrzymanie wskaznika ładowania dań
          });
        });
      */
      
    }
      _isInit = false;
   
    super.didChangeDependencies();
  }

  
  //usuwanie przepisu z listy
  void _removeMeal(String mealId) {
    //meals.removeWhere((meal) => meal.id == mealId);
  }

  @override
  Widget build(BuildContext context) {
    /* przeniesione do initState bo dodano moliwość usuwania przepisów z listy

    //przekazanie argumentów trasy dla wywołania ekranu listy dań przez puschNamed
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final categoryTitle = routeArgs['title'];
    final categoryId = routeArgs['id'];
    final categoryMeals = DUMMY_MEALS.where((meal) {
      return meal.categories.contains(categoryId);
    }).toList();
*/  final mealsData = Provider.of<Meals>(context);
    final meals9 = mealsData.items.where((meal) {return meal.kategoria.contains('9');}).toList();
    final meals1 = mealsData.items.where((meal) {return meal.kategoria.contains('1');}).toList();
    final meals2 = mealsData.items.where((meal) {return meal.kategoria.contains('2');}).toList();
    final meals3 = mealsData.items.where((meal) {return meal.kategoria.contains('3');}).toList();
    final meals4 = mealsData.items.where((meal) {return meal.kategoria.contains('4');}).toList();
    final meals5 = mealsData.items.where((meal) {return meal.kategoria.contains('5');}).toList();
    final meals6 = mealsData.items.where((meal) {return meal.kategoria.contains('6');}).toList();
    final meals7 = mealsData.items.where((meal) {return meal.kategoria.contains('7');}).toList();
    final meals8 = mealsData.items.where((meal) {return meal.kategoria.contains('8');}).toList();
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Test"),//Text(categoryTitle),
      //),
      body: DefaultTabController(
        length: 9,
        initialIndex: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text('lista dań'),
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
          drawer:
              MainDrawer(), //Drawer(child: Text('data'),), //ikona burgera z szufladą
          body: _isLoading  //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          :TabBarView(children: <Widget>[  //wyświetlenie listy dań
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value( //dostawca danych dla dania z listy o podanym indeksie
                value: meals9[index],
                child: MealItem(),
                ),
               itemCount: meals9.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value( //dostawca (wersja bez kontekstu)
                value: meals1[index],
                child: MealItem(),
                ),
               itemCount: meals1.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: meals2[index],
                child: MealItem(),
                ),
               itemCount: meals2.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: meals3[index],
                child: MealItem(),
                ),
               itemCount: meals3.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: meals4[index],
                child: MealItem(),
                ),
               itemCount: meals4.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: meals5[index],
                child: MealItem(),
                ),
               itemCount: meals5.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: meals6[index],
                child: MealItem(),
                ),
               itemCount: meals6.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value( 
                value: meals7[index],
                child: MealItem(),
                ),
               itemCount: meals7.length,
            ),
            //ŚNIADANIA 
            ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
              itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                value: meals8[index],
                child: MealItem(),
                ),
               itemCount: meals8.length,
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
