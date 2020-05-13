import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meals.dart';
import '../widgets/meal_item.dart';
import '../all_translations.dart';
import 'languages.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings'; 
  
  @override
  Widget build(BuildContext context) {
    

     
      return Scaffold(
        appBar: AppBar(
          title: const Text('Więcej'), //const jezeli nie będzie aktualizowany tytul
        ),
        body: ListView(
          children:  <Widget>[           
            GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed(LanguagesScreen.routeName); 
              },
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.translate),
                  title: Text('Język'),
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