//widzet szuflady
import 'package:flutter/material.dart';

import '../screens/filters_screen.dart';

class MainDrawer extends StatelessWidget {
  //funkcja tworząca elementy klikalne szuflady zamiasy pisania ich po kolei
  Widget buildListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'RobotoCondensed',
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          //nagłówek na górze szuflady
          height: 120,
          width: double.infinity,
          padding: EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          color: Theme.of(context)
              .accentColor, //lub decoration: BoxDecoration(color: , ),
          child: Text(
            'Cooking Up',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 30,
                color: Theme.of(context).primaryColor),
          ),
        ),
        SizedBox(
          height: 20,
        ), //odstęp w pionie
        buildListTile(  //zamiast tego co nizej zaremowane
          'Meals',
          Icons.restaurant,
          () {  //funkcja anonimowa 
            Navigator.of(context).pushReplacementNamed('/'); //zastąpienie aktualnego ekranu nowym, brak przycisku wstecz
          }
        ), 
        buildListTile(
          'Filters',
          Icons.settings,
          () {
            Navigator.of(context).pushReplacementNamed(FiltersScreen.routeName);
          }
        ),
        /*
        ListTile(
          leading: Icon(
            Icons.restaurant,
            size: 26,
          ),
          title: Text(
            'Meals',
            style: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {

            //...
          },
        ),
        ListTile(
          leading: Icon(
            Icons.settings,
            size: 26,
          ),
          title: Text(
            'Filters',
            style: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {

            //...
          },
        ) */
      ],
    ));
  }
}
