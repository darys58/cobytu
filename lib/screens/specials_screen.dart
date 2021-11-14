import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../all_translations.dart';
import '../models/specials.dart';
import '../widgets/special_one.dart';

class SpecialsScreen extends StatefulWidget {
  static const routeName = '/specials';

  @override
  _SpecialsScreenState createState() => _SpecialsScreenState();
}

class _SpecialsScreenState extends State<SpecialsScreen> {
  //List<Zamowienie> _zamowienia = [];
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?

  @override
  void didChangeDependencies() {
    print('init promocje');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
      });

      Provider.of<Specials>(context, listen: false).fetchSpecialsFromSerwer().then((_) {
        //pobranie promocji z serwera www

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
    final specialData = Provider.of<Specials>(context, listen: false);
    List<SpecialItem> specials = specialData.items.toList();
    //print('zamowienia = ${orders[0].typText}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('L_PROMOCJE')),
      ),
      body: _isLoading //jezeli dane są ładowane
          ? Center(
              child: CircularProgressIndicator(), //kółko ładowania danych
            )
          : specials[0].id != 'brak' //jezeli są zamówienia to wyświetl je
              ? ListView.builder(
                  //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                  itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
                    //dostawca (wersja bez kontekstu)
                    value: specials[index],
                    child: SpecialOne(),
                  ),
                  itemCount: specials.length,
                )
              : Center(
                  child: Column(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        allTranslations.text('L_PROMOCJE_BRAK'),
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
