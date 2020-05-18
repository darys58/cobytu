import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meals/all_translations.dart';
import 'meals_screen.dart';

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
    
    String _currentValue;
    
    switch(_currLang) { 
      case 'pl':  _currentValue = 'Polski'; break; 
      case 'en':  _currentValue = 'English'; break; 
      case 'cs':  _currentValue = 'Čeština'; break; 
      case 'de':  _currentValue = 'Deutsch'; break; 
      case 'es':  _currentValue = 'Español'; break; 
      case 'fr':  _currentValue = 'Français'; break; 
      case 'ru':  _currentValue = 'Pусский'; break; 
      case 'sv':  _currentValue = 'Svenska'; break; 
      case 'ja':  _currentValue = '日本語'; break; 
      case 'zh':  _currentValue = '中文'; break; 
      default: _currentValue = 'Polski'; break; 
      break; 
    } 


print('_currLang = $_currLang');
print('_currentValue = $_currentValue');
   // final String buttonText = language == 'pl' ? '=> English' : '=> Polski';
    List<String> lang = ['Polski','English','Čeština','Deutsch','Español','Français','Pусский','Svenska','日本語', '中文'];
    List<String> lang2 = ['Polski','Angielski','Czeski','Niemiecki','Hiszpański','Franciski','Rosyjski','Szwedzki','Japoński','Chiński (tradycyjny)'];
    //var ile = lang.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('L_WYBIERZ_JEZYK')), 
      ),
      body: 
        SingleChildScrollView(
          child: Column( 
           // mainAxisSize:MainAxisSize.min, 
            //crossAxisAlignment: CrossAxisAlignment.start, 
            //padding: EdgeInsets.all(8.0),
            children: <Widget>[
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[0]),
                subtitle: Text(lang2[0]),
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
                subtitle: Text(lang2[1]),
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
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[2]),
                subtitle: Text(lang2[2]),
                value: lang[2],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == 'Čeština' ? 'cs' : 'en');
                  setState(() {
                    _currentValue = val;
                    print('val _currentValue = $_currentValue');
                    _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                     Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                  });
                },
              ),
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[3]),
                subtitle: Text(lang2[3]),
                value: lang[3],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == 'Deutsch' ? 'de' : 'en');
                  setState(() {
                    _currentValue = val;
                    print('val  _currentValue = $_currentValue');
                    _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                     Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                  });
                },
              ),
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[4]),
                subtitle: Text(lang2[4]),
                value: lang[4],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == 'Español' ? 'es' : 'en');
                  setState(() {
                    _currentValue = val;
                    print('val _currentValue = $_currentValue');
                    _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                     Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                  });
                },
              ),
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[5]),
                subtitle: Text(lang2[5]),
                value: lang[5],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == 'Français' ? 'fr' : 'en');
                  setState(() {
                    _currentValue = val;
                    print('val en - _currentValue = $_currentValue');
                    _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                     Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                  });
                },
              ),
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[6]),
                subtitle: Text(lang2[6]),
                value: lang[6],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == 'Pусский' ? 'ru' : 'en');
                  setState(() {
                    _currentValue = val;
                    print('val en - _currentValue = $_currentValue');
                    _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                     Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                  });
                },
              ),
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[7]),
                subtitle: Text(lang2[7]),
                value: lang[7],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == 'Svenska' ? 'sv' : 'en');
                  setState(() {
                    _currentValue = val;
                    print('val en - _currentValue = $_currentValue');
                    _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                     Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                  });
                },
              ),
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[8]),
                subtitle: Text(lang2[8]),
                value: lang[8],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == '日本語' ? 'ja' : 'en');
                  setState(() {
                    _currentValue = val;
                    print('val en - _currentValue = $_currentValue');
                    _setPrefers('reload', 'true');  //konieczne załadowanie danych z serwera 
                     Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName));  //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
        
                  });
                },
              ),
              RadioListTile(
                groupValue: _currentValue,
                title: Text(lang[9]),
                subtitle: Text(lang2[9]),
                value: lang[9],
                onChanged: (val) async{
                  await allTranslations.setNewLanguage(val == '中文' ? 'zh' : 'en');
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