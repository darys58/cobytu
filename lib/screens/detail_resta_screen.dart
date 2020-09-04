//ekran szczegółów dania
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/meals.dart';
import '../models/detailRest.dart';
import '../all_translations.dart';

class DetailRestaScreen extends StatefulWidget {
  static const routeName = '/detail_resta';

  @override
  _DetailRestaScreenState createState() => _DetailRestaScreenState();
}

class _DetailRestaScreenState extends State<DetailRestaScreen> {
List<DetailRest> _mealRestsData = []; //szczegóły restauracji
bool _isVisible = false;
String _currLang = allTranslations.currentLanguage; //aktualny język
  
void showToast() {
  setState(() {
    _isVisible = !_isVisible;
  });
}

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
    var url = 'https://cobytu.com/cbt.php?d=f_danie_resta&danie=$idDania&lang=$_currLang';
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
          dostawy: restData['re_tel_dos'], 
          online: restData['re_online'], 
          parking: restData['re_parking'], 
          podjazd: restData['re_podjazd'], 
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
  
//wywoływanie połączeń uruchamianych ikonami
Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Nie mozna połaczyć z  $url';
    }
  }

  facilities (String text){
    return Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey,
          //color: Theme.of(context).primaryColor,
        ),
      );
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
       body: Column(
          children: <Widget>[
//tekst na szarym tle - Danie dostępne w restauracji:         
            Container(
              height: 50,
              color: Colors.grey[300],
              width: MediaQuery.of(context).size.width,
              child: Row(             
                children: <Widget>[
                  SizedBox(width: 15,),             
                  Text(allTranslations.text('L_DANIE_DOSTEPNE') + ':', 
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
                padding: const EdgeInsets.only(left:20, right:20),
                itemCount: _mealRestsData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    //height: 250,
                    //color: Colors.amber[colorCodes[index]],
                    child: Column(
                      mainAxisSize:MainAxisSize.min, 
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: <Widget>[
 //nazwa restauracji                       
                        SizedBox(height: 15,), 
                        Text(_mealRestsData[index].nazwa,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                            //color: Theme.of(context).primaryColor,
                          ),
                        ),
//adres restauracji
                        SizedBox(height: 5,),  
                        Text(_mealRestsData[index].miasto + ', ' + _mealRestsData[index].adres,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            //color: Theme.of(context).primaryColor,
                          ),
                        ),
 //godziny otwarcia                        
                        SizedBox(height: 15,),  
                        Text(_mealRestsData[index].otwarteA,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.3, //interlinia
                            color: Colors.black87,
                            //color: Theme.of(context).primaryColor,
                          ),
                        ),  
                        //SizedBox(height: 5,),  
                        Text(_mealRestsData[index].otwarteB,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.3, //interlinia
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            //color: Theme.of(context).primaryColor,
                          ),
                        ),
                        //SizedBox(height: 5,),  
                        if(_mealRestsData[index].otwarteC != '')
                          Text(_mealRestsData[index].otwarteC,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.3, //interlinia
                              color: Colors.black87,
                              //color: Theme.of(context).primaryColor,
                            ),
                          ),
                        //Center(child: Text('Entry ${entries[index]}')),
//ikony połączeń                     
                      Padding(//odstępy dla wiersza z ikonami
                        padding: EdgeInsets.only(top: 5),
                        child: Row( //rząd z informacjami o posiłku
                          mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, //główna oś wyrównywania - odstępy              
                          children: <Widget>[ 
                            IconButton(
                              icon: Icon(
                                Icons.phone
                              ),
                              onPressed: (){
                                _launchURL('tel:${_mealRestsData[index].tel1}');//numer bez spacji !!!
                                //launch('tel:${_mealRestsData[index].tel1}');
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.email
                              ),
                              onPressed: (){
                                _launchURL('mailto:${_mealRestsData[index].email}');
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.public
                              ),
                              onPressed: (){
                                _launchURL('http://${_mealRestsData[index].www}');
                              },
                            ),
                   /*         IconButton(
                              icon: Icon(
                                Icons.map
                              ),
                              onPressed: (){
                                //meal.toggleFavoriteStatus();
                              },
                            ),
                     */       IconButton(
                              icon: Icon(
                                Icons.more
                              ),
                              onPressed: (){
                                showToast();
                              },
                            ),
                          ],
                        ),
                      ),
                      Visibility (
                        visible: _isVisible,
                        //child: Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, 
                                children: <Widget>[
                                  Text(
                                    allTranslations.text('L_UDOGODNIENIA') + ':',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      //color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  
                                  if ('${_mealRestsData[index].online}' =='1') Divider(),
                                  if ('${_mealRestsData[index].online}' =='1')facilities(allTranslations.text('L_ONLINE')),
                                  if ('${_mealRestsData[index].dostawy}' =='1') Divider(),
                                  if ('${_mealRestsData[index].dostawy}' =='1')facilities(allTranslations.text('L_DOSTAWY')),
                                  if ('${_mealRestsData[index].wifi}' =='1') Divider(),
                                  if ('${_mealRestsData[index].wifi}' =='1')facilities(allTranslations.text('L_WIFI_TAK')),
                                  if ('${_mealRestsData[index].parking}' =='1') Divider(),
                                  if ('${_mealRestsData[index].parking}' =='1')facilities(allTranslations.text('L_PARKING_TAK')),
                                  if ('${_mealRestsData[index].klima}' =='1') Divider(),
                                  if ('${_mealRestsData[index].klima}' =='1')facilities(allTranslations.text('L_KLIMA_TAK')),
                                  if ('${_mealRestsData[index].karta}' =='1') Divider(),
                                  if ('${_mealRestsData[index].karta}' =='1')facilities(allTranslations.text('L_KARTA_TAK')),
                                  if ('${_mealRestsData[index].letni}' =='1') Divider(),
                                  if ('${_mealRestsData[index].letni}' =='1')facilities(allTranslations.text('L_OGRODEK_TAK')),
                                  if ('${_mealRestsData[index].wynos}' =='1') Divider(),
                                  if ('${_mealRestsData[index].wynos}' =='1')facilities(allTranslations.text('L_WYNOS_TAK')),
                                  if ('${_mealRestsData[index].zabaw}' =='1') Divider(),
                                  if ('${_mealRestsData[index].zabaw}' =='1')facilities(allTranslations.text('L_STREFA_TAK')),
                                  if ('${_mealRestsData[index].podjazd}' =='1') Divider(),
                                  if ('${_mealRestsData[index].podjazd}' =='1')facilities(allTranslations.text('L_NIEPELNO_TAK')),
                                  //Divider(),
                                  SizedBox(height: 5,),
                                ],
                              ),
                            ),
                          ),
                       // )
                        // Divider()
                      )
                      











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