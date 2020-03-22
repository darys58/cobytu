//import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import './mem.dart';

class Mems {
 
  
   List<Mem> _items = [];

   List<Mem> get items{ //getter który zwraca kopię zmiennej _item
    return [..._items]; 
  }

  //zapisanie rekordu memory do bazy lokalnej
  static Future<void> insertMemory(String nazwa,String a,String b,String c,String d,String e,String f)async{
     await DBHelper.insert('memory',{
       'nazwa': 'memLok',
       'a': a,
       'b': b,
       'c': c,
       'd': d,
       'e': e,
       'f': f,
     });
  }

  

}