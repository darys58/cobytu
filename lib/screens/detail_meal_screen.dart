//ekran szczegółów dania
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/meals.dart';
import '../models/mealRest.dart';


class DetailMealScreen extends StatefulWidget {
  static const routeName = '/detail-meal';

  @override
  _DetailMealScreenState createState() => _DetailMealScreenState();
}

class _DetailMealScreenState extends State<DetailMealScreen> {
 List<MealRest> _mealRestsData = [];

  @override
  void didChangeDependencies() {
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
      fetchMealRestsFromSerwer(mealId).then((_) { 
        print('pobranie szczegółów');
        setState(() {
         // _mealRestsData  = _mealRestsData ;
        });
      });

    super.didChangeDependencies();  
  }
  
  //pobranie (z serwera www) restauracji serwujących wybrane danie - dla szczegółów dania
  Future<List<MealRest>> fetchMealRestsFromSerwer(String idDania) async {
    var url = 'https://cobytu.com/cbt.php?d=f_danie_resta&danie=$idDania&lang=pl';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return[];
      }

      //final List<MealRest> loadedRests = [];
      extractedData.forEach((restId, restData) {
        _mealRestsData.add(MealRest(
          id: restId,
          logo: restData['re_logo'], 
          nazwa: restData['re_nazwa'],       
          obiekt: restData['re_obiekt'],   
          adres: restData['re_adres'],       
          kod: restData['re_kod'], 
          miasto: restData['re_miasto'], 
          woj: restData['re_woj'], 
          tel1: restData['re_tel1'], 
          tel2: restData['re_tel2'], 
          email: restData['re_email'], 
          www: restData['re_www'], 
          gps: restData['re_gps'], 
          otwarteA: restData['re_otwarte_a'], 
          otwarteB: restData['re_otwarte_b'], 
          otwarteC: restData['re_otwarte_c'], 
          cena: restData['cena'], 
          parking: restData['re_parking'], 
          pojazd: restData['re_podjazd'], 
          wynos: restData['re_na_wynos'], 
          karta: restData['re_p_karta'], 
          zabaw: restData['re_s_zabaw'], 
          letni: restData['re_o_letni'], 
          klima: restData['re_klima'], 
          wifi: restData['re_wifi'],  
          modMenu: restData['re_mod_menu'],  
        ));
      });
     // _items = loadedRests;
      print('dane restauracji w MealRests = ${_mealRestsData[0].nazwa}');
      //notifyListeners();
    return _mealRestsData;
    } catch (error) {
      throw (error);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
    //final loadedMeal = Provider.of<Meals>(context).items.firstWhere((ml) => ml.id == mealId);//dla uproszczenia kodu przeniesiona do meals.dart i wtedy jak nizej
    final loadedMeal = Provider.of<Meals>(context, listen: false).findById(mealId);

    //print('mealRestsData w szczegółach = ${_mealRestsData[0].nazwa}');
  
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMeal.nazwa),
      ),
       body: _mealRestsData == null ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            ) : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              //zdjęcie dania
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedMeal.foto,
                fit: BoxFit.cover, //dopasowanie do pojemnika
              ),
            ),


            
          ]
        )
      )
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