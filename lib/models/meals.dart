//dane dań
import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import './meal.dart';

class Meals with ChangeNotifier{  //klasa Meals jest zmiksowana z klasą ChangeNotifier która pozwala ustalać tunele komunikacyjne przy pomocy obiektu context
  List<Meal> _items = [ //lista dań, dostępna tylko wewnątrz tej klasy, będzie się zmieniać, podkreślenie oznacza ze jest to wartość prywatna klasy
  /*  Meal(
      id: '2160',            
      nazwa: 'Kurczak z zielonym pieprzem',   
      opis: 'Pier\u015b z kurczaka w sosie \u015bmietanowym z zielonym pieprzem',      
      idwer: '0',        
      wersja: '',       
      foto: 'https://www.cobytu.com/foto/124/filet_z_pieprzem1_4026_m.jpg',         
      gdzie: 'Siesta',        
      kategoria: '4',     
      podkat: ['106','110'],  
      srednia: '0.00',       
      alergeny: ' mleko',      
      cena:'25.00',           
      czas: '25',         
      waga: '500',        
      kcal: '675',         
      lubi: '83',          
      fav: '0',           
      stolik: '0',
    ),
    Meal(
      id: '2341',            
      nazwa: 'Awokado Kaburamaki',   
      opis: 'Pier\u015b z kurczaka w sosie \u015bmietanowym z zielonym pieprzem',      
      idwer: '0',        
      wersja: '',       
      foto: 'https://www.cobytu.com/foto/124/filet_z_pieprzem1_4026_m.jpg',         
      gdzie: 'Siesta',        
      kategoria: '4',     
      podkat: ['106','110'],  
      srednia: '0.00',       
      alergeny: ' mleko',      
      cena:'25.00',           
      czas: '25',         
      waga: '500',        
      kcal: '675',         
      lubi: '83',          
      fav: '0',           
      stolik: '0',
    ),
    Meal(
      id: '374',            
      nazwa: '\u0141oso\u015b z grilla',   
      opis: 'Pier\u015b z kurczaka w sosie \u015bmietanowym z zielonym pieprzem',      
      idwer: '0',        
      wersja: '',       
      foto: 'https://www.cobytu.com/foto/15/losos_grillowany_0809_1_m.jpg',         
      gdzie: 'Siesta',        
      kategoria: '4',     
      podkat: ['106','107'],  
      srednia: '0.00',       
      alergeny: ' mleko',      
      cena:'25.00',           
      czas: '25',         
      waga: '500',        
      kcal: '675',         
      lubi: '83',          
      fav: '0',           
      stolik: '0',
    ),
    */
  ];  
  List<Meal> get items{ //getter który zwraca kopię zmiennej _items
    return [..._items]; //... - operator rozprzestrzeniania
  }

  //metoda szukająca dania o danym id - przeniesiona z meal_detail_screen.dart
  Meal findById(String id) {
    return _items.firstWhere((ml) => ml.id ==  id);
  }

  //pobranie bazy dań z serwera www
  static Future<void> fetchMealsFromSerwer(String url) async {
    //const url = 'https://cobytu.com/cbt.php?d=f_dania&uz_id=&woj_id=14&mia_id=1&rest=&lang=pl';
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
    
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      
      extractedData.forEach((mealId, mealData) {
        //zapis dania do bazy
        DBHelper.insert('dania', {
        'id': mealId,
        'nazwa': mealData['da_nazwa'], 
        'opis': mealData['da_opis'],     
        'idwer': mealData['da_id_wer'],        
        'wersja': mealData['da_wersja'],       
        'foto': mealData['da_foto'],    //'https://www.cobytu.com/foto/' +       
        'gdzie': mealData['da_gdzie'],        
        'kategoria': mealData['da_kategoria'],     
        'podkat': mealData['da_podkategoria'],    //  ['106','107'],  
        'srednia': mealData['da_srednia'],      
        'alergeny': mealData['alergeny'],      
        'cena': mealData['cena'],            
        'czas': mealData['da_czas'],          
        'waga': mealData['waga'],         
        'kcal': mealData['kcal'],         
        'lubi': mealData['ud0_da_lubi'],           
        'fav': mealData['fav'],           
        'stolik': mealData['na_stoliku'], 
        });
      });
      
    } catch (error) {
      throw (error);
    }
  }

//pobranie dań z bazy lokalnej
  Future<void> fetchAndSetMeals()async{
    final dataList = await DBHelper.getData('dania');
    _items = dataList
      .map(
        (item) => Meal(
          id: item['id'],          
          nazwa: item['nazwa'], 
          opis: item['opis'],     
          idwer: item['idwer'],        
          wersja: item['wersja'],       
          foto: 'https://www.cobytu.com/foto/' + item['foto'],          
          gdzie: item['da_gdzie'],        
          kategoria: item['kategoria'],     
          podkat: item['podkat'],    //  ['106','107'],  
          srednia: item['srednia'],      
          alergeny: item['alergeny'],      
          cena: item['cena'],            
          czas: item['czas'],          
          waga: item['waga'],         
          kcal: item['kcal'],         
          lubi: item['lubi'],           
          fav: item['fav'],           
          stolik: item['stolik'], 
           ),
      
      ).toList();
      notifyListeners();
  }
  
  //usuwanie wszystkich dań z bazy lokalnej
  static Future<void> deleteAllMeals()async{
     await DBHelper.deleteTable('dania');

  }

  static Future<void> updateFavorite(id, fav)async{
     await DBHelper.updateFav(id, fav);

  }

}
/*
import 'meal.dart';

 var MEALS = [
  Meal(
    id: '2160',            
    nazwa: 'Kurczak z zielonym pieprzem',   
    opis: 'Pier\u015b z kurczaka w sosie \u015bmietanowym z zielonym pieprzem',      
    idwer: '0',        
    wersja: '',       
    foto: 'https://www.cobytu.com/foto/124/filet_z_pieprzem1_4026_m.jpg',         
    gdzie: 'Siesta',        
    kategoria: '4',     
    podkat: ['106','110'],  
    srednia: '0.00',       
    alergeny: ' mleko',      
    cena:'25.00',           
    czas: '25',         
    waga: '500',        
    kcal: '675',         
    lubi: '83',          
    fav: '0',           
    stolik: '0',
  ),
  Meal(
    id: '2341',            
    nazwa: 'Awokado Kaburamaki',   
    opis: 'Pier\u015b z kurczaka w sosie \u015bmietanowym z zielonym pieprzem',      
    idwer: '0',        
    wersja: '',       
    foto: 'https://www.cobytu.com/foto/124/filet_z_pieprzem1_4026_m.jpg',         
    gdzie: 'Siesta',        
    kategoria: '4',     
    podkat: ['106','110'],  
    srednia: '0.00',       
    alergeny: ' mleko',      
    cena:'25.00',           
    czas: '25',         
    waga: '500',        
    kcal: '675',         
    lubi: '83',          
    fav: '0',           
    stolik: '0',
  ),
  Meal(
    id: '374',            
    nazwa: '\u0141oso\u015b z grilla',   
    opis: 'Pier\u015b z kurczaka w sosie \u015bmietanowym z zielonym pieprzem',      
    idwer: '0',        
    wersja: '',       
    foto: 'https://www.cobytu.com/foto/15/losos_grillowany_0809_1_m.jpg',         
    gdzie: 'Siesta',        
    kategoria: '4',     
    podkat: ['106','107'],  
    srednia: '0.00',       
    alergeny: ' mleko',      
    cena:'25.00',           
    czas: '25',         
    waga: '500',        
    kcal: '675',         
    lubi: '83',          
    fav: '0',           
    stolik: '0',
  ),
];
*/

  //"id":"2341","foto":"co.jpg","gdzie":"Egao Sushi","kategoria":"4","podkategoria":"107,155","nazwa":"Awokado Kaburamaki","opis":"Sushi wielosk\u0142adnikowe. Sk\u0142ad: awokado na zewn\u0105trz, ser, orzechy nerkowca, grillowany \u0142oso\u015b, og\u00f3rek","id_wer":"0","wersja":"4 sztuki","srednia":"0.00","alergeny":" mleko","cena":"24.00","czas":"20","waga":"220","kcal":"491","ud0_lubi":"84","fav":"0","na_stoliku":"0"}

  //{"id":"374","foto":"15\/losos_grillowany_0809_1_m.jpg","gdzie":"Kresowianka","kategoria":"4","podkategoria":"106,107","nazwa":"\u0141oso\u015b z grilla","opis":"Grillowany \u0142oso\u015b podawany z cukini\u0105 z grilla","id_wer":"0","wersja":"","srednia":"4.00","alergeny":" ryby","cena":"28.00","czas":"20","waga":"150","kcal":"246","ud0_lubi":"92","fav":"0","na_stoliku":"0"}