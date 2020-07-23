import 'dart:convert'; //obsługa json'a
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;


class CartItem {
  final String id;      //ko_id
  final String daId;    //da_id
  final String nazwa;   //da_nazwa
  final String opis;    //da_opis
   int ile;        //ko_ile
   String cena;    //ko_cena
  final String waga;    //ko_waga
  final String kcal;    //ko_kcal

  CartItem({
    @required this.id, 
    this.daId, 
    @required this.nazwa, 
    this.opis, 
    @required this.ile,
    @required this.cena,
    this.waga,
    this.kcal,
    });
}

class Cart with ChangeNotifier{
  List<CartItem> _items = [];

  List<CartItem> get items {
    return [..._items];
  }

  //ilość produktów w koszyku
  int get itemCount {
    int ilosc = 0;
    for(var i = 0; i < _items.length; i++){
      ilosc = ilosc + _items[i].ile;
    }
    return ilosc;  //_items == null ? 0 :  _items.length   jezeli koszyk jest pusty wstaw 0
  }

  //pobieranie dań w koszyku z serwera www
  Future<void> fetchAndSetCartItems(String url) async{
    //const url = 'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=re=&lang=pl';
     print(url);
     try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return _items = [];
      }
      final List<CartItem>loadedCartItems = [];

      extractedData.forEach((cartItemId, cartItemData) {
        loadedCartItems.add(CartItem(
          id: cartItemId,   //ko_id
          daId:cartItemData['da_id'],   
          nazwa: cartItemData['da_nazwa'],    
          opis: cartItemData['da_opis'],    
          ile: cartItemData['ko_ile'],      
          cena: cartItemData['ko_cena'],    
          waga: cartItemData['ko_waga'],   
          kcal: cartItemData['ko_kcal'], 
        ));
      });

      if (loadedCartItems[0].id != 'brak ') _items = loadedCartItems;
      else _items = [];
      notifyListeners();
     } catch (error) {
      throw (error);
    }
   
  }
  /*  rezygnacja z funkcji addItem - zastąpienie przez aktualizacje z www przez wywołanie
  Provider.of<Cart>(context).fetchAndSetCartItems('https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${globals.memoryLok_e}&lang=pl');  //aktualizacja zawartości koszyka z www             
  w szczegłłach dania

  //dodawanie do koszyka / przy odejmowaniu dania dodaje danie z ile = -1 (tymczasowo w szczegółach dania, tylko do obliczania ilości dań pokazywanej na ikonie koszyka)
  void addItem(String daId, String nazwa, int ile, String cena) {
    _items.add(CartItem(
      id: 'temp',            //DateTime.now().toString(), 
      daId: daId,    
      nazwa: nazwa,  
      opis: 'temp',
      ile: ile,
      cena: cena,
      waga: 'temp',
      kcal: 'temp',  
      ),
    );
    print('po dodaniu = $_items');    
    notifyListeners();
  }
*/
}

/*

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final String price;

  CartItem({@required this.id, @required this.title, @required this.quantity, @required this.price});
}

class Cart with ChangeNotifier{
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  //ilość produktów w koszyku
  int get itemCount {
    int ilosc = 0;
    for(var i = 0; i < _items.length; i++){
      ilosc = ilosc + _items.values.toList()[i].quantity;
    }
    return ilosc;  //_items == null ? 0 :  _items.length   jezeli koszyk jest pusty wstaw 0
  }

  //dodawanie do koszyka
  void addItem(String productId, String price, String title,) {
    if (_items.containsKey(productId)){
      //zmiana ilości
      _items.update(productId, (existingCartItem) => CartItem(
        id: existingCartItem.id, 
        title: existingCartItem.title,  
        price: existingCartItem.price, 
        quantity: existingCartItem.quantity + 1,
        ),
      );
    } else { //jezeli nie ma takiego samego - dodaj nowe
      _items.putIfAbsent(productId, () => CartItem(
        id: DateTime.now().toString(), 
        title: title, 
        price: price, 
        quantity: 1, 
        ),
      );
    }
    notifyListeners();
  }

}
*/