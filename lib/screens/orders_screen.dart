import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

      Provider.of<Orders>(context, listen: false).fetchOrdersFromSerwer().then((_) {
        //pobranie zamówień z serwera www

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
    //print('zamowienia = ${orders[0].typText}');
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('L_ZAMOWIENIA')),
      ),
      body: _isLoading //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          : orders[0].id != 'brak' //jezeli są zamówienia to wyświetl je
              ? ListView.builder(
                  //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                  itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                    //dostawca (wersja bez kontekstu)
                    value: orders[index],
                    child: OrderOne(),
                  ),
                  itemCount: orders.length,
                )
              : Center(
                  child: Column(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        allTranslations.text('L_BRAK_ZAMOWIEN'),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  ]),
                ),
    );
  }
}
