import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //obsługa json'a

import '../globals.dart' as globals;
import '../all_translations.dart';
import '../models/order.dart';
import '../widgets/order_one.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders'; 

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
 //List<Zamowienie> _zamowienia = []; 
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  
  @override
  void didChangeDependencies() {
    //print('init szczegóły');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });
      
      Provider.of<Orders>(context).fetchOrdersFromSerwer().then((_) { //pobranie zamówień z serwera www
               
        setState(() {
          _isLoading = false; //zatrzymanie wskaznika ładowania danych
        });
      });                        

    }  
    _isInit = false;
    super.didChangeDependencies();  
  } 

  

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context, listen: false);
    List<OrderItem> orders = orderData.items.toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Zamówienia'),
      
      ),
      body: _isLoading  //jezeli dane są ładowane
        ? Center(
            child: CircularProgressIndicator(), //kółko ładowania danych
          )
        ://Text(order.items[0].typText),
        ListView.builder(//ładowane są te elementy listy które widać na ekranie - lepsza wydajność
          itemBuilder: (ctx, index) => ChangeNotifierProvider.value( //dostawca (wersja bez kontekstu)
          value: orders[index],
          child: OrderOne(),
          ),
          itemCount: orders.length,
      ),
    );
  }
}
