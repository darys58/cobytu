//zarządzanie ekranami (renderowanie kart) z paska z tabami
import 'package:flutter/material.dart';

//import '../widgets/main_drawer.dart';
import './detail_meal_screen.dart';
import './detail_resta_screen.dart';
import './detail_ingred_screen.dart';
import './detail_opinion_screen.dart';
import '../all_translations.dart';



class TabsDetailScreen extends StatefulWidget {
  static const routeName = '/tabs_detail'; //nazwa trasy do tego ekranu

  @override
  _TabsDetailScreenState createState() => _TabsDetailScreenState();
}

//lista ekranów przełczanych w tabBar
class _TabsDetailScreenState extends State<TabsDetailScreen> {
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
    DetailMealScreen(),
    DetailRestaScreen(),
    DetailIngredientsScreen(),
    DetailOpinionScreen(),
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
        onTap: _selectPage,  //wywołanie zmiany indeksu wyswietlwnej strony - obsługę trzeba zrobić samemu
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: _selectedPageIndex, //informuje tabbar któty tab jest wybrany
        type: BottomNavigationBarType.fixed ,//shifting, //lub fixed   //rózne typy tabBara
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.info_outline),
            title: Text(allTranslations.text('L_O_DANIU')),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.local_dining),
            title: Text(allTranslations.text('L_O_LOKALU')),
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.format_list_bulleted),
            title: Text(allTranslations.text('L_SKLADNIKI')),
          ),
     /*     BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            icon: Icon(Icons.star),
            title: Text('OPINIE'),
          ),
      */ ],
      ),
    );
  }
} // tabs na górze ekranu - DefaultTabController - kurs 170
//initialIndex

