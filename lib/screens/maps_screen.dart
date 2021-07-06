import 'package:flutter/material.dart';
import 'package:meals/widgets/location_input.dart';
import 'package:provider/provider.dart';
import '../models/meals.dart';
import '../widgets/meal_item.dart';
import '../all_translations.dart';

class MapsScreen extends StatelessWidget {
  static const routeName = '/maps'; 
  
  @override
  Widget build(BuildContext context) {
    //final mealsData = Provider.of<Meals>(context, listen: false);
    //final favorites = mealsData.items.where((meal) {return meal.fav.contains('1');}).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('L_ULUBIONE_M')), //const jezeli nie będzie aktualizowany tytul
      ),
      body: Center( 
          child:Column(
            children: <Widget>[
              LocationInput(),
            ],
          ),
        ) 

    );
  }
}