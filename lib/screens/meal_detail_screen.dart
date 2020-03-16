//ekran szczegółów dania

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meals.dart';


class MealDetailScreen extends StatelessWidget {
  static const routeName = '/meal-detail';

  //final Function toggleFavorite;
  //final Function isFavorite;

  //MealDetailScreen(this.toggleFavorite, this.isFavorite);
/*
  //widget (jako funkcja wielokrotnie wykorzystywana) budujący tytuły sekcji np. "Ingrediens", "Steps"
  Widget buildSectionTitle(BuildContext context, String text) {
    return Container(
      //napis Ingriediens
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.title,
      ),
    );
  }

  //podobnie jak wyzej ale do budowania kontenera dla listy składników i kroków przepisu
  Widget buildContainer(Widget child) {
    return Container(
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
      child: child,
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
    //final loadedMeal = Provider.of<Meals>(context).items.firstWhere((ml) => ml.id == mealId);//dla uproszczenia kodu przeniesiopna do meals.dart i wtedy jak nizej
    final loadedMeal = Provider.of<Meals>(context, listen: false).findById(mealId);

  
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMeal.nazwa),
        //title: Text('${selectedMeal.title}'),
      ),
    );
  
  }
}
    /*
      
    final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == mealId);
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