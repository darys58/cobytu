//ekran szczegółów dania
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/meals.dart';
import '../models/detailRest.dart';


class DetailIngredientsScreen extends StatefulWidget {
  static const routeName = '/detail-ingredients';

  @override
  _DetailIngredientsScreenState createState() => _DetailIngredientsScreenState();
}

class _DetailIngredientsScreenState extends State<DetailIngredientsScreen> {

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
       body: Column(
          children: <Widget>[
            Center(
              child:
              Text('Składniki'),
            ),


            
          ]
        )
    );
  }
}