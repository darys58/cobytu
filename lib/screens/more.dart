import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../all_translations.dart';
import 'languages.dart';


class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings'; 


  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    

     
      return Scaffold(
        appBar: AppBar(
          title: Text(allTranslations.text('L_WIECEJ')), 
        ),
        body: ListView(
          children:  <Widget>[           
            //język
            GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed(LanguagesScreen.routeName); 
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.translate),
                  title: Text(allTranslations.text('L_JEZYK')),
                  trailing: Icon(Icons.more_vert),
                ),
              ),
            ),
            //polityka prywatności
            GestureDetector(
              onTap: (){             
                  _launchURL('https://www.cobytu.com/index.php?d=polityka&mobile=1');
               // Navigator.of(context).pushNamed(LanguagesScreen.routeName); 
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.security),
                  title: Text(allTranslations.text('L_POLITYKA')),
                  trailing: Icon(Icons.more_vert),
                ),
              ),
            ),

            //regulamin
            GestureDetector(
              onTap: (){             
                  _launchURL('https://www.cobytu.com/index.php?d=regulamin&mobile=1');
               // Navigator.of(context).pushNamed(LanguagesScreen.routeName); 
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.library_books),
                  title: Text(allTranslations.text('L_REGULAMIN')),
                  trailing: Icon(Icons.more_vert),
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
        )
      );
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
/*


        Center( 
          
            child:Text(
              'Brak ulubionych',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
         ) 
  */