import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../widgets/cart_one.dart';
import '../globals.dart' as globals;
import '../all_translations.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  String _separator;
  String _cenaRazem;
  String _wagaRazem;
  String _kcalRazem;

  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
      print('wysłanie po koszyk');
      Provider.of<Cart>(context).fetchAndSetCartItems('https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLok_e}&lang=pl').then((_) {   //zawartość koszyka z www             
        
        print('odebranie koszyka'); 
        setState(() {
          _isLoading = false; //zatrzymanie wskaznika ładowania danych
        });
      });                     

    }  
    _isInit = false;
    super.didChangeDependencies();  
  } 

  @override
  Widget build(BuildContext context){
    final cart = Provider.of<Cart>(context);
    print ('cartttttttt = ${cart.items}');
    double razemC = 0;
    int razemW = 0;
    int razemK = 0;
    for (var i = 0; i < cart.items.length; i++) {
      razemC = razemC + double.parse(cart.items[i].cena) ;
      razemW = razemW + int.parse(cart.items[i].waga);
      razemK = razemK + int.parse(cart.items[i].kcal);
    }
    _cenaRazem = razemC.toStringAsFixed(2);
    _wagaRazem = razemW.toString();
    _kcalRazem = razemK.toString();
    print ('cenaRazem = $_cenaRazem');
    return Scaffold (
      appBar: AppBar(
        title: Text('Koszyk'),
      ),
      body: _isLoading  //jezeli dane są ładowane
        ? Center(
            child: CircularProgressIndicator(), //kółko ładowania danych
          )
        : Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(child: ListView.builder(
                itemCount: cart.items.length + 1, 
                itemBuilder: (ctx, i) { 
                  print(cart.items[0].id);
                  if(cart.items[0].id != 'brak'){
                    if (i < cart.items.length){
                      return CartOne( //kolejne zamówione dania
                        i,
                        cart.items[i].id, 
                        cart.items[i].daId, 
                        cart.items[i].nazwa, 
                        cart.items[i].opis, 
                        cart.items[i].ile,
                        cart.items[i].cena,
                        cart.items[i].waga,
                        cart.items[i].kcal,
                      );
                    }else{ //
                      return Column(
                        children: <Widget>[
                          Card( //RAZEM + przyciski               
                            margin: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 4,
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              height: 40.0,
                              child: Row(//polubienie - Kazdy element wiersz jest wierszemonym z ikony i tekstu                            
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[                        
                                  Text(
                                    'RAZEM',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ), 
                                  ),
                                  //razem: cena, waga, kcal
                                  Row(//Kazdy element wiersz jest wierszemonym 
                                  mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[ //elementy rzędu które sa widzetami
                                      Row( //cena dania
                                        children: <Widget>[
                                          Text(
                                            _separator == '.' ? _cenaRazem  : _cenaRazem.replaceAll('.', ','),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ), //meal.cena, //interpolacja ciągu znaków
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ), //odległość miedzy ceną a PLN
                                          Text(
                                            allTranslations.text('L_PLN'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ), //interpolacja ciągu znaków
                                          ), 
                                          SizedBox(
                                            width: 25,
                                          ), 
                                        ],
                                      ),
                                      
                                      Row(// waga- 
                                        children: <Widget>[
                                          SizedBox(
                                            width: 2,
                                          ), //odległość miedzy ikoną i tekstem
                                          Text(
                                            _wagaRazem + ' ' + allTranslations.text('L_G'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ), 
                                          ), 
                                          SizedBox(
                                            width: 25,
                                          ),//interpolacja ciągu znaków
                                        ],
                                      ),
                                      Row(// kcal - Kazdy element wiersza jest wierszem zlozonym z ikony i tekstu                               
                                        children: <Widget>[
                                          SizedBox(
                                            width: 2,
                                          ), //odległość miedzy ikoną i tekstem
                                          Text(
                                            _kcalRazem + ' ' + allTranslations.text('L_KCAL'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ), 
                                          ), //interpolacja ciągu znaków
                                          SizedBox(
                                            width: 25,
                                          ),
                                        ],
                                      ),                 
                                    ],
                                  ),
                                  
                                ],
                              ),
                            ),
                          ),
                          
                          Container(
                            height: 70,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              
                              children: <Widget>[
                                
                                MaterialButton(
                                  shape: const StadiumBorder(),
                                  onPressed: (){}, 
                                  child: Text ('Zamawiam z dostawą'),
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  disabledColor: Colors.grey,
                                  disabledTextColor: Colors.white,
                                  
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }else{ //od if(cart.items[0].id != 'brak') - czy koszyk jest pusty
                    if(i == 0) //bo jest jeszcze i==1 i wtedy wyświetla dwa razy to samo
                    return Column(                      
                      children: <Widget>[
                        Container( 
                          padding: const EdgeInsets.only(top: 50),
                          child:Text(
                            allTranslations.text('L_KOSZYK_PUSTY'),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ) 
                      ]
                    );
                  }
                }
              ),
            ),
 
          ],
      ),
        ),
    );
  }
} 