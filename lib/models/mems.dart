//import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej


class Mems {

  //zapisanie rekordu memory do bazy lokalnej
  static Future<void> insertMemory(String nazwa,String a,String b,String c,String d,String e,String f)async{
     await DBHelper.insert('memory',{
       'nazwa': nazwa,
       'a': a,
       'b': b,
       'c': c,
       'd': d,
       'e': e,
       'f': f,
     });
  }

  

}