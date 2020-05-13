import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'meals_screen.dart';
import '../widgets/meal_item.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../all_translations.dart';

class LanguagesScreen extends StatefulWidget {
  static const routeName = '/languages-meals'; 

  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

 //zapisywanie zmiennych w SharedPreferences (zmienne widoczne globalnie)
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }

class _LanguagesScreenState extends State<LanguagesScreen> {
   String _currLang = allTranslations.currentLanguage;
  

  @override
  Widget build(BuildContext context) {
    
    String _currentValue = _currLang == 'pl' ?  'Polski' : 'English';
print('_currLang = $_currLang');
print('_currentValue = $_currentValue');
   // final String buttonText = language == 'pl' ? '=> English' : '=> Polski';
    List<String> lang = ['Polski', 'English'];
    //var ile = lang.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Języki'), //const jezeli nie będzie aktualizowany tytul
      ),
      body:
            Column( 
          //padding: EdgeInsets.all(8.0),
          children: <Widget>[
            RadioListTile(
              groupValue: _currentValue,
              title: Text(lang[0]),
              subtitle: Text(lang[0]),
              value: lang[0],
              onChanged: (val) async{
                await allTranslations.setNewLanguage(val == 'Polski' ? 'pl' : 'en');
                setState(() {
                  _currentValue = val;
                  print('val pl - _currentValue = $_currentValue');
                  _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                   Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                });
              },
            ),
            RadioListTile(
              groupValue: _currentValue,
              title: Text(lang[1]),
              subtitle: Text(lang[1]),
              value: lang[1],
              onChanged: (val) async{
                await allTranslations.setNewLanguage(val == 'English' ? 'en' : 'pl');
                setState(() {
                  _currentValue = val;
                  print('val en - _currentValue = $_currentValue');
                  _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                   Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                });
              },
            ),
          ],
          //scrollDirection: Axis.vertical,
        ),
      );
    
  }
}

/* RaisedButton(
    child: Text(buttonText),
    onPressed: () async {
      await allTranslations.setNewLanguage(language == 'pl' ? 'en' : 'pl');
      setState((){
        Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
                      
      });
    },
  ),
*/