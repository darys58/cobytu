//ekran szczegółów dania
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/meals.dart';
import '../models/detailRest.dart';


class DetailRestaScreen extends StatefulWidget {
  static const routeName = '/detail_resta';

  @override
  _DetailRestaScreenState createState() => _DetailRestaScreenState();
}

class _DetailRestaScreenState extends State<DetailRestaScreen> {
List<DetailRest> _mealRestsData = []; //szczegóły restauracji


@override
  void didChangeDependencies() {
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
      fetchDetailRestsFromSerwer(mealId).then((_) { 
        print('pobranie szczegółów');
        setState(() {
         // _mealRestsData  = _mealRestsData ;
        });
      });

    super.didChangeDependencies();  
  }
  
//pobranie (z serwera www) restauracji serwujących wybrane danie - dla szczegółów dania
  Future<List<DetailRest>> fetchDetailRestsFromSerwer(String idDania) async {
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
        _mealRestsData.add(DetailRest(
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
    final loadedMeal = Provider.of<Meals>(context).items.firstWhere((ml) => ml.id == mealId);//dla uproszczenia kodu przeniesiona do meals.dart i wtedy jak nizej
    //final loadedMeal = Provider.of<Meals>(context, listen: false).findById(mealId);

    //print('mealRestsData w szczegółach = ${_mealRestsData[0].nazwa}');
  
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMeal.nazwa),
      ),
       body: Column(
          children: <Widget>[
            Center(
              child:
              Text('Resta'),
            ),
            Container(  //napis Ingriediens
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Ingredients',
                style: Theme.of(context).textTheme.title,
              ),
            )

            
          ]
        )
    );
  }
}