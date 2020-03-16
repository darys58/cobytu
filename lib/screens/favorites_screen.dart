import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meals.dart';
import '../widgets/meal_item.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorite-meals'; 
  
  @override
  Widget build(BuildContext context) {
    final mealsData = Provider.of<Meals>(context, listen: false);
    final favorites = mealsData.items.where((meal) {return meal.fav.contains('1');}).toList();
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ulubione'), //const jezeli nie będzie aktualizowany tytul
        ),
        body: favorites.isEmpty ? Text('Brak ulubionych') : ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
            itemBuilder: (ctx, index) => ChangeNotifierProvider.value( //dostawca (wersja bez kontekstu)
            value: favorites[index],
            child: MealItem(),
            ),
            itemCount: favorites.length,
        ),
      );
   // } /*else {
      /*return ListView.builder(
        itemBuilder: (ctx, index) {
          return null ;//MealItem(
           // id: favoriteMeals[index].id,
           // title: favoriteMeals[index].title,
           // imageUrl: favoriteMeals[index].imageUrl,
           // duration: favoriteMeals[index].duration,
           // affordability: favoriteMeals[index].affordability,
           // complexity: favoriteMeals[index].complexity,
           // removeItem: _removeMeal,
         // );
        },
        itemCount: favoriteMeals.length,
      );
    }
    */
  }
}
