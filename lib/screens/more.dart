import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../all_translations.dart';
import 'languages.dart';
import 'orders_screen.dart';
import 'specials_screen.dart';
import 'package:connectivity/connectivity.dart'; //czy jest Internet

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showAlertAnuluj(BuildContext context, String nazwa, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nazwa),
        content: Column(
          //zeby tekst był wyśrodkowany w poziomie
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(allTranslations.text('L_ANULUJ')),
          ),
        ],
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      barrierDismissible:
          false, //zeby zaciemnione tło było zablokowane na kliknięcia
    );
  }

  //sprawdzenie czy jest internet
  Future<bool> _isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("Connected to Mobile Network");
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("Connected to WiFi");
      return true;
    } else {
      print("Unable to connect. Please Check Internet Connection");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(allTranslations.text('L_WIECEJ_M')),
        ),
        body: ListView(
          children: <Widget>[
//język
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(LanguagesScreen.routeName);
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.translate),
                  title: Text(allTranslations.text('L_JEZYK')),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),

//zamówienia
            GestureDetector(
              onTap: () {
                //czy jest internet
                _isInternet().then((inter) {
                  if (inter != null && inter) {
                    Navigator.of(context).pushNamed(OrdersScreen.routeName);
                  } else {
                    print('braaaaaak internetu');
                    _showAlertAnuluj(
                        context,
                        allTranslations.text('L_BRAK_INTERNETU'),
                        allTranslations.text('L_URUCHOM_INTERNETU'));
                  }
                });
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.list),
                  title: Text(allTranslations.text('L_ZAMOWIENIA')),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),

//promocje
            GestureDetector(
              onTap: () {
                //czy jest internet
                _isInternet().then((inter) {
                  if (inter != null && inter) {
                    print('wiecej - specialsScreen');
                    Navigator.of(context).pushNamed(SpecialsScreen.routeName);
                  } else {
                    print('braaaaaak internetu');
                    _showAlertAnuluj(
                        context,
                        allTranslations.text('L_BRAK_INTERNETU'),
                        allTranslations.text('L_URUCHOM_INTERNETU'));
                  }
                });
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text(allTranslations.text('L_PROMOCJE')),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),
//polityka prywatności
            GestureDetector(
              onTap: () {
                //czy jest internet
                _isInternet().then((inter) {
                  if (inter != null && inter) {
                    _launchURL(
                        'https://www.cobytu.com/index.php?d=polityka&mobile=1');
                    // Navigator.of(context).pushNamed(LanguagesScreen.routeName);
                  } else {
                    print('braaaaaak internetu');
                    _showAlertAnuluj(
                        context,
                        allTranslations.text('L_BRAK_INTERNETU'),
                        allTranslations.text('L_URUCHOM_INTERNETU'));
                  }
                });
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.security),
                  title: Text(allTranslations.text('L_POLITYKA')),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),

//regulamin
            GestureDetector(
              onTap: () {
                //czy jest internet
                _isInternet().then((inter) {
                  if (inter != null && inter) {
                    _launchURL(
                        'https://www.cobytu.com/index.php?d=regulamin&mobile=1');
                    // Navigator.of(context).pushNamed(LanguagesScreen.routeName);
                  } else {
                    print('braaaaaak internetu');
                    _showAlertAnuluj(
                        context,
                        allTranslations.text('L_BRAK_INTERNETU'),
                        allTranslations.text('L_URUCHOM_INTERNETU'));
                  }
                });
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text(allTranslations.text('L_REGULAMIN')),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ),

            /* Card(child: ListTile(title: Text('One-line ListTile'))),
            Card(
              child: ListTile(
                leading: FlutterLogo(),
                title: Text('One-line with leading widget'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('One-line with trailing widget'),
                trailing: Icon(Icons.more_vert),
              ),
            ), 
        
            Card(
              child: ListTile(
                title: Text('One-line dense ListTile'),
                dense: true,
              ),
            ),
            Card(
              child: ListTile(
                leading: FlutterLogo(size: 56.0),
                title: Text('Two-line ListTile'),
                subtitle: Text('Here is a second line'),
                trailing: Icon(Icons.more_vert),
              ),
            ),
            Card(
              child: ListTile(
                leading: FlutterLogo(size: 72.0),
                title: Text('Three-line ListTile'),
                subtitle: Text(
                  'A sufficiently long subtitle warrants three lines.'
                ),
                trailing: Icon(Icons.more_vert),
                isThreeLine: true,
              ),
           ),
       */
          ],
        ));
  }
}
/*
final String language = allTranslations.currentLanguage;
final String buttonText = language == 'pl' ? '=> English' : '=> Français'; 

child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text(buttonText),
              onPressed: () async {
                await allTranslations.setNewLanguage(language == 'pl' ? 'en' : 'pl');
                setState((){
                  //lll
               });
              },
            ),
            Text(allTranslations.text('ulubione')),
          ],
        ),*/
