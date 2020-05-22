import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meals.dart';
import '../widgets/meal_item.dart';
import '../all_translations.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorite-meals'; 
  
  @override
  Widget build(BuildContext context) {
    final mealsData = Provider.of<Meals>(context, listen: false);
    final favorites = mealsData.items.where((meal) {return meal.fav.contains('1');}).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('L_ULUBIONE_M')), //const jezeli nie będzie aktualizowany tytul
      ),
      body: favorites.isEmpty 
      ? Center( 
          child:Text(
            allTranslations.text('L_ULUBIONE_BRAK'),
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
        ) 
      : ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
          itemBuilder: (ctx, index) => ChangeNotifierProvider.value( //dostawca (wersja bez kontekstu)
          value: favorites[index],
          child: MealItem(),
          ),
          itemCount: favorites.length,
      ),
    );
  }
}
