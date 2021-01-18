//zarządzanie ekranami (renderowanie kart) z paska z tabami
import 'package:flutter/material.dart';
import 'package:meals/all_translations.dart';

import 'more_screen.dart';
import './favorites_screen.dart';
import './location_screen.dart';
import './meals_screen.dart';



class TabsScreen extends StatefulWidget {
  //final List<Meal> favoriteMeals;
  //final List<Meal> availableMeals;

  //TabsScreen(this.favoriteMeals, this.availableMeals);

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

//lista ekranów przełczanych w tabBar
class _TabsScreenState extends State<TabsScreen> {
  //List<Map<String, Object>> _pages; //taki złozony typ zeby mozna było wyświetlać tytuł taba/ekranu i np. przyciski akcji (171)
  List<Widget> _pages;
  int _selectedPageIndex = 0; //ręczne przełaczanie stron wybranej w tabs

  @override
  void initState(){ //zainicjowanie (przeładowanie) strony w chwili wyświetlenia
   
    /*_pages = [
    {
      'page': CategoryMealsScreen(widget.availableMeals),//CategoriesScreen(),
      'title': 'Categories',
    },
    {
      'page': FavoritesScreen(widget.favoriteMeals),
      'title': 'Your Favorite',
    },
    */
  
  _pages = [
    MealsScreen(),
    FavoritesScreen(),
    LocationScreen(),
    MoreScreen(),
    ];
    super.initState();
  }


//wywołwnie przy nacisnieciu taba - index zaley od wybranego taba
void _selectPage(int index){
  setState(() {
    _selectedPageIndex = index;
  });
}

  @override
  Widget build(BuildContext context) {
   
    return Scaffold( 
      //appBar: AppBar(
      //  title: Text(_pages[_selectedPageIndex]['title']), //(171)
        //title: Text('Meals'),
      //),
      //drawer: MainDrawer(),//Drawer(child: Text('data'),), //ikona burgera z szufladą
       
      body: _pages[_selectedPageIndex], //widget wyswietlwnej strony
      //body:  _pages[_selectedPageIndex],  //wywołanie gdy była uzyta lista widzetów
      
      bottomNavigationBar: BottomNavigationBar(
        onTap:_selectPage,  //wywołanie zmiany indeksu wyswietlwnej strony - obsługę trzeba zrobić samemu
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: _selectedPageIndex, //informuje tabbar któty tab jest wybrany
        type: BottomNavigationBarType.fixed ,//shifting, //lub fixed   //rózne typy tabBara
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.home),
            title: Text(allTranslations.text('L_MENU')),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.favorite),
            title: Text(allTranslations.text('L_ULUBIONE')),
            //title: Text('ULUBIONE'),
            //title: Text(AppLocalizations.of(context).translate('ulubione')),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.location_on),
            title: Text(allTranslations.text('L_LOKAL')),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.more_vert),
            title: Text(allTranslations.text('L_WIECEJ')),
          ),
        ],
      ),
    );
  }
} // tabs na górze ekranu - DefaultTabController - kurs 170
//initialIndex

