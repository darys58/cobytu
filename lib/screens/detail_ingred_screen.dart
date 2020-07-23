//ekran szczegółów dania
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../models/mem.dart';
import '../models/meals.dart';
import '../models/detailMeal.dart';
import '../models/detailIngred.dart';
import '../all_translations.dart';

class DetailIngredientsScreen extends StatefulWidget {
  static const routeName = '/detail-ingredients';

  @override
  _DetailIngredientsScreenState createState() => _DetailIngredientsScreenState();
}

class _DetailIngredientsScreenState extends State<DetailIngredientsScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  List<DetailMeal> _detailMealData = []; //szczegóły dania
  List<DetailIngred> _detailIngredData = []; //składniki dania
  List<Mem> _memMeal; //dane wybranego dania w tabeli memory - baza lokalna
  List<Mem> _memLok; //dane wybranej restauracji w tabeli memory - baza lokalna
  var detailMealData;
  var detailIngredData;
  String _currLang = allTranslations.currentLanguage; //aktualny język

  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
      fetchMemoryMeal().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
        fetchMemoryLok().then((_){ //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
          fetchDetailMealFromSerwer().then((_) { 
            fetchDetailIngredFromSerwer().then((_){
                setState(() {
                  _isLoading = false; //zatrzymanie wskaznika ładowania dań
                  detailMealData  = _detailMealData ;
                  detailIngredData = _detailIngredData;
                });
            });
          });
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();  
  }


//pobranie (z serwera www) szczegółów dania - dla szczegółów dania
//!!!!! potrzebne tylko dla listy alergrnów - moze lepiej zapamitywać alergeny w zmiennej globalnej !!!!!!!! 

  Future<List<DetailMeal>> fetchDetailMealFromSerwer() async {
    var url = 'https://cobytu.com/cbt.php?d=f_danie&danie=${_memMeal[0].a}&uz_id=&rest=${_memLok[0].e}&lang=$_currLang';
    //print(url);
    try {
      final response = await http.get(url);
      //print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return[];
      }

      _detailMealData = []; //konieczne zerowanie bo doda sie do poprzedniej wartości
      extractedData.forEach((mealId, mealData) {
        _detailMealData.add(DetailMeal(
          id: mealId,
          nazwa: mealData['da_nazwa'], 
          opis: mealData['da_opis'],       
          cena: mealData['cena'],   
          czas: mealData['da_czas'],       
          waga: mealData['waga'], 
          kcal: mealData['kcal'], 
          lubi: mealData['da_lubi'], 
          stolik: mealData['na_stoliku'], 
          alergeny: mealData['alergeny'], 
          srednia: mealData['da_srednia'], 
          cenaPodst: mealData['cena_podst'], 
          wagaPodst: mealData['da_waga_podst'], 
          kcalPodst: mealData['da_kcal_podst'], 
          werListId: mealData['da_id_lista_wer'], 
          werList: mealData['da_wersja_lista'], 
          warUlub: mealData['do_wariant'], 
          warList1: mealData['do_wariant_lista1'], 
          warList2: mealData['do_wariant_lista2'], 
          dodat: mealData['do_dodat'], 
          podstId: mealData['do_podst_id'], 
          warUlubId: mealData['do_wariant_id'], 
          warList1Id: mealData['do_wariant_lista1_id'], 
          warList2Id: mealData['do_wariant_lista2_id'], 
          dodatId: mealData['do_dodat_id'],  
          warList1Waga: mealData['do_wariant_lista1_waga'],        
          warList2Waga: mealData['do_wariant_lista2_waga'], 
          dodatWaga: mealData['do_dodat_waga'], 
          warList1Kcal: mealData['do_wariant_lista1_kcal'], 
          warList2Kcal: mealData['do_wariant_lista2_kcal'], 
          dodatKcal: mealData['do_dodat_kcal'], 
          warList1Cena: mealData['do_wariant_lista1_cena'], 
          warList2Cena: mealData['do_wariant_lista2_cena'], 
          dodatCena: mealData['do_dodat_cena'],       
        ));
      });
     //print('pobrane dane dania np. war1 = ${_detailMealData[0].opis}');
    return _detailMealData;
    } catch (error) {
      throw (error);
    }
  }

  Future<List<DetailIngred>> fetchDetailIngredFromSerwer() async {
    var url = 'https://cobytu.com/cbt.php?d=f_danie_sklad&danie=${_memMeal[0].a}&uz_id=&lang=$_currLang';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return[];
      }

      _detailIngredData = []; //konieczne zerowanie bo doda sie do poprzedniej wartości
      extractedData.forEach((ingredId, ingredData) {
        _detailIngredData.add(DetailIngred(
          doId: ingredId,                      //do_id
          rdId: ingredData['do_rd_id'],        //do_rd_id
          ndNazwa: ingredData['nd_nazwa'],     //nd_nazwa
          fdForma: ingredData['fd_forma'],     //fd_forma
          daId: ingredData['dd_da_id'],        //dd_da_id
          doKcal100: ingredData['do_kcal100'], //do_kcal100
          udLubi: ingredData['ud_lubi'],       //ud_lubi
        ));
      });
     print('pobrane składniki dania np. war1 = ${_detailIngredData[0].ndNazwa}');
    return _detailIngredData;
    } catch (error) {
      throw (error);
    }
  }
   
  //pobranie memory z bazy lokalnej
   Future<void> fetchMemoryMeal()async{
    final data = await DBHelper.getMemory('memDanie');
    _memMeal = data.map(
        (item) => Mem(
          nazwa: item['nazwa'],          
          a: item['a'], 
          b: item['b'],     
          c: item['c'],        
          d: item['d'],       
          e: item['e'],          
          f: item['f'],                               
        ),  
      ).toList();
      //print('memoryMeal$_memMeal');
      return _memMeal;
  }

  //pobranie memory z bazy lokalnej
   Future<void> fetchMemoryLok()async{
    final data = await DBHelper.getMemory('memLok');
    _memLok = data.map(
        (item) => Mem(
          nazwa: item['nazwa'],          
          a: item['a'], 
          b: item['b'],     
          c: item['c'],        
          d: item['d'],       
          e: item['e'],          
          f: item['f'],                               
        ),  
      ).toList();
      //print('memoryLok$_memLok');
      return _memLok;
  }






@override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String; //id posiłku pobrany z argumentów trasy
    //final loadedMeal = Provider.of<Meals>(context).items.firstWhere((ml) => ml.id == mealId);//dla uproszczenia kodu przeniesiona do meals.dart i wtedy jak nizej
    final loadedMeal = Provider.of<Meals>(context, listen: false).findById(mealId);

    //print('detailIngredData w szczegółach = ${detailIngredData[0].ndNazwa}');
  
    return Scaffold(
      appBar: AppBar(
        title: Text(loadedMeal.nazwa),
      ),
       body: _isLoading 
      ? Center(
          child: CircularProgressIndicator(), //kółko ładowania danych
        ) 
      : Column(
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Row(             
                children: <Widget>[
                  SizedBox(width: 15,),             
                  Text(
                  allTranslations.text('L_ALERGENY') + ': ' + '${detailMealData[0].alergeny.join(', ')}', //join łączy argumenty z listy w jeden string
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
            ),

            Container(
              height: 50,
              color: Colors.grey[300],
              width: MediaQuery.of(context).size.width,
              child: Row(             
                children: <Widget>[
                  SizedBox(width: 15,),             
                  Text(
                  allTranslations.text('L_SKLADNIKI_DANIA') + ':', 
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
            ),


            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                //shrinkWrap: true,
                padding: const EdgeInsets.only(left:20, right:20, top: 7),
                itemCount: detailIngredData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    //height: 250,
                    //color: Colors.amber[colorCodes[index]],
                    child: Column(
                      mainAxisSize:MainAxisSize.min, 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: <Widget>[
                        SizedBox(height: 3,),
                        Row(
                          children: <Widget>[
                            Text(
                              detailIngredData[index].ndNazwa,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                
                              ),
                            ),
                            Text(
                              ' ' + detailIngredData[index].fdForma,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: <Widget>[
                            Text(
                              detailIngredData[index].doKcal100 + ' ' + allTranslations.text('L_KCAL') + '/100' + allTranslations.text('L_G'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ),








          ]
        )
    );
  }
}