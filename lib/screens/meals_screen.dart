//lista dań w wybranej kategorii

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';
import 'package:connectivity/connectivity.dart'; //czy jest Internet

import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../models/meals.dart';
import '../models/meal.dart';
import '../models/mem.dart';
import '../models/mems.dart';
import '../models/rests.dart';
import '../models/podkat.dart';
import '../models/cart.dart';
import '../widgets/badge.dart';
import '../widgets/meal_item.dart';
import '../all_translations.dart';
import '../globals.dart' as globals;
import './cart_screen.dart';

class MealsScreen extends StatefulWidget {
  //stanowy bo usuwanie dań
  static const routeName = '/category-meals'; //nazwa trasy do tego ekranu

  //do modyfikowania listy posiłków przez ustawianie filtów
  //final List<Meal> availableMeals;

  //CategoryMealsScreen(this.availableMeals);

  @override
  _MealsScreenState createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  String reload =
      'false'; //czy załadować dane z serwera - przeładowanie danych?
  String initApp =
      'false'; //czy jest to inicjalizacja apki - pierwsze uruchomienie po zainstalowaniu?
  String language; //skrót aktualnego języka np. pl
  String reloadTemp = 'false';
  String initAppTemp = 'false';
  //final wersja = ['1','0','0','2','22.05.2020','nic']; //major, minor - wersja(zmiana w bazie), kolejna wersja bo wymaga tego iOS, numer wydania
  //1.0.0.2 22.05.2020 - pierwsza wersja, przegląanie dań, bez zamówień
  //1.0.1.3 28.07.2020 - zamówienia online
  //1.0.2.6 04.08.2020 - zmiana ikon dla iOS, poprawki w tłumaczeniu "g" i "kcal"
  //1.0.3.7 18.08.2020 - detekcja braku Internetu dla szczegółów dania
  //1.0.3.8 21.08.2020 - detekcja braku Internetu dla Regulamin, Polityka prywatnosci, Zamówienia
  //1.0.4.9 31.09.2020 - promocje, odpowiednie typy klawiatur przy wprowadzaniu danych, API 29 (w build.gradle)
  //1.0.5.10 04.09.2020 - wyszukiwarka, teksty celu w Info.plist
  //1.0.6.11 09.11.2020 - oznaczenie n/a dla wagi i kcal gdy nie ma składników podstawowych, "Brak dań w tej kategorii",
  //1.0.7.12 13.11.2020 - poprawki do 1.0.6.11, obsługa lupy na klawiaturze w wyszukiwarce, poprawki tłumaczeń
  //1.0.8.13 27.11.2020 - poprawki tłumaczeń gkategorii menu - promocji, taby menu na dole z nazwami, podkategoria "Promocje", wielkość RAZEM w koszyku
  //1.0.9.14 22.12.2020 - usunięty "Sposób zapłaty" przy odbiorze własnym, w szczegółach restauracji usunięte powielanie przy obracaniu telefonu, zmiany odstępów w "location", usunięcie czasu oczekiwania,
  //1.0.10.15 21.02.2021 - połączenie konta z apką, zapis ulubionych na serwerze, ostrzeganie o alergenach 
  //1.0.11.16 26.02.2021 - zmiana wartości statusów zamówienia na dwucyfrowe - zapomniałem to zrobić w poprzedniej wersji, tłumaczenia
  //1.0.12.17.08.11.2021 - dodanie map googla z lokalizacjami restauracji
  final wersja = ['1', '0', '12', '17', '08.11.2021', 'nic']; //wersja aplikacji

  String podkategoria1 =
      '291'; //wybrana podkategoria, domyślnie 291 czyli "Wszystkie" w kategorii 1
  String podkategoria2 =
      '292'; //wybrana podkategoria, domyślnie 292 czyli "Wszystkie" w kategorii 2
  String podkategoria3 =
      '293'; //wybrana podkategoria, domyślnie 293 czyli "Wszystkie" w kategorii 3
  String podkategoria4 =
      '294'; //wybrana podkategoria, domyślnie 294 czyli "Wszystkie" w kategorii 4
  String podkategoria5 =
      '295'; //wybrana podkategoria, domyślnie 295 czyli "Wszystkie" w kategorii 5
  String podkategoria6 =
      '296'; //wybrana podkategoria, domyślnie 296 czyli "Wszystkie" w kategorii 6
  String podkategoria7 =
      '297'; //wybrana podkategoria, domyślnie 297 czyli "Wszystkie" w kategorii 7
  String podkategoria8 =
      '298'; //wybrana podkategoria, domyślnie 298 czyli "Wszystkie" w kategorii 8
  String podkategoria9 =
      '299'; //wybrana podkategoria, domyślnie 299 czyli "Wszystkie" w kategorii 9
  String rodzaj = ''; //wybrany rodzaj dania np. Dania litewskie
  String categoryTitle;
  List<Mem> _memLok; //dane wybranej lokalizacji w tabeli memory - baza lokalna
  List<Mem>
      _memVer; //dane wersji aplikacji i bazy danych w tabeli memory - baza lokalna
  String _tytul = allTranslations.text('L_LISTA_DAN'); //tytuł tymczasowy
  //String _selectedItem = '';
  List<Meal> meals1;
  List<Meal> meals2;
  List<Meal> meals3;
  List<Meal> meals4;
  List<Meal> meals5;
  List<Meal> meals6;
  List<Meal> meals7;
  List<Meal> meals8;
  List<Meal> meals9;

  /// bieżący czas, w „sekundach od epoki”
  static int currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  @override
  void initState() {
    print('meals_scerrn: wejście do initState');
    //_setPrefers('reload', 'true');  //dane aktualne - nie trzeba przeładować danych
    //_setPrefers('initApp', 'true'); //inicjalizacja apki przeprowadzona
    //zainicjowanie stanu po zmianie np. usunięciu dania
    //.... przeniesiono do didChangeDependencies()
    //przeniesiono bo nie działa tu ModalRoute bo initState uruchamia się przed uruchomieniem tego widzetu i nie ma jeszcze kontekstu.
    //tzn. ze w tym momencie nie mozna pobrać danych o trasie. Kontext tu nie działa !!!
    super.initState();
  }

  @override
  void didChangeDependencies() {
    print('meals_scerrn: wejscie do Dependencies ms 1');

    print('meals_scerrn: _isInit = $_isInit');
    if (_isInit) {
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania danych
        _getId(); //pobranie Id telefonu i zapisanie w globals.deviceId - do identyfikacji uzytkownika apki
      });

      print(
          'meals_scerrn: wejscie do Dependencies - Init meals_screen - czas...');
      print(currentTimeInSeconds());
      fetchMemoryVer().then((_) {
        //pobranie danych o wersji apki
        if (_memVer.isNotEmpty) {
          if (_memVer[0].a == wersja[0] &&
              _memVer[0].b == wersja[1] &&
              _memVer[0].c == wersja[2]) {
            // jezeli jest zgodna wersja aplikacji to przejdz dalej za ifa
            print('meals_scerrn: zgodna _memVer[0].a =${_memVer[0].a}');
          } else {
            //jezeli niezgodna wersja apki to zmiana bazy w całości
            print('meals_scerrn: niezgodna _memVer[0].a =${_memVer[0].a}');
            reloadTemp = 'true'; //ustawienia tymczasowe
            initAppTemp = 'true'; //ustawienia tymczasowe
            _setPrefers('reload',
                'true'); //trzeba przeładować dane - ustawienie do zapamiętania
            _setPrefers('initApp',
                'true'); //potrzebna inicjalizacja apki - ustawienie do zapamiętania
            //_setPrefers('language', 'pl'); //potrzebna inicjalizacja apki - ustawienie do zapamiętania
          }
        } else {
          //jezeli nie ma rekordu memVer tzn. ze nie ma bazy
          print('meals_scerrn: niema memVer - brak bazy danych');
          reloadTemp = 'true'; //ustawienia tymczasowe
          initAppTemp = 'true'; //ustawienia tymczasowe
          _setPrefers('reload',
              'true'); //trzeba załadować dane - ustawienie do zapamiętania
          _setPrefers('initApp',
              'true'); //potrzebna inicjalizacja apki - ustawienie do zapamiętania
          //_setPrefers('language', 'pl'); //potrzebna inicjalizacja apki - ustawienie do zapamiętania
        }

        _getPrefers().then((_) {
          //pobranie zmiennych globalnych z pliku prefers
          print('meals_scerrn: initApp = $initApp');
          print('meals_scerrn: reload = $reload');
          print('meals_scerrn: language = $language');
          globals.language =
              language; //przepisanie języka z pliku Prefers do pamęci globalnej
          if (language == 'en' || language == 'ja' || language == 'zh')
            globals.separator = '.';
          else
            globals.separator = ',';

          //czy trzeba załadować/przeładować z serwera lub czy nie ma zmiennej 'reload'
          if (reloadTemp == 'true' || reload == 'true' || reload == '0') {
            print('meals_scerrn: trzeba załadować dane z serwera');

            //czy jest Internet
            _isInternet().then((inter) {
              if (inter != null && inter) {
                //jezeli jest Internet
                //czy jest to pierwsze uruchomienie apki
                if (initAppTemp == 'true' ||
                    initApp == 'true' ||
                    initApp == '0') {
                  // jezeli pierwsze uruchomienie to ładowanie danych domyślnych
                  print('meals_scerrn: pierwsze uruchomienie apki!!!!!!!!');
                  DBHelper.deleteBase().then((_) {
                    //kasowanie całej bazy danych bo będzie nowa
                    Mems.insertMemory('memLok', '14', 'wielkopolskie', '1',
                        'Konin', '31', 'Siesta'); //default '27','Borówka'
                    Mems.insertMemory('memVer', wersja[0], wersja[1], wersja[2],
                        wersja[3], wersja[4], wersja[5]); //default
                    Meals.fetchMealsFromSerwer(
                            'https://cobytu.com/cbt.php?d=f_dania&uz_id=&dev=${globals.deviceId}&woj_id=14&mia_id=1&rest=31&lang=$language')
                        .then((_) {
                      Rests.fetchRestsFromSerwer().then((_) {
                        Podkategorie.fetchPodkategorieFromSerwer(
                                'https://cobytu.com/cbt.php?d=f_podkategorie&uz_id=&woj_id=14&mia_id=1&rest=31&lang=$language')
                            .then((_) {
                          Provider.of<Meals>(context, listen: false)
                              .fetchAndSetMeals()
                              .then((_) {
                            //z bazy lokalnej
                            Provider.of<Podkategorie>(context, listen: false)
                                .fetchAndSetPodkategorie()
                                .then((_) {
                              //z bazy lokalnej
                              DBHelper.getRestWithId(globals.memoryLokE)
                                  .then((restaurant) {
                                globals.online = restaurant.asMap()[0][
                                    'online']; //'1'  - zamawianie online przez CoByTu.com
                                globals.dostawy = restaurant.asMap()[0][
                                    'dostawy']; //'1' - resta dostarcza z dowozem
                                globals.czyDostawa =
                                    1; //domyślny sposób dostarczenia zamówienia: "1" - dostawa
                                globals.sposobPlatnosci =
                                    1; //domyślny sposób płatności : "1" - gotówka
                                globals.cenaOpakowania =
                                    '0.00'; //cena za jedno opakowanie - domyślnie ???
                                globals.wybranaStrefa = 1; //domyślna strefa
                                _setPrefers('reload',
                                    'false'); //dane aktualne - nie trzeba przeładować danych
                                _setPrefers('initApp',
                                    'false'); //inicjalizacja apki przeprowadzona
                                setState(() {
                                  _tytul =
                                      'Konin'; //_tytul = (_memLok[0].e == '0') ? _memLok[0].d : _memLok[0].f; //nazwa miasta lub restauracji
                                  _isLoading =
                                      false; //zatrzymanie wskaznika ładowania danych
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                    //});
                    //});
                    //});
                  });
                } else {
                  //jezeli przeładowanie danych z serwera (bo np. zmiana lokalizacji)
                  print(
                      'meals_scerrn: przeładowanie danych - z serwera (bo np. zmiana lokalizacji)');
                  fetchMemoryLok().then((_) {
                    //pobranie aktualnie wybranej lokalizacji z bazy lokalnej
                    Meals.deleteAllMeals().then((_) {
                      //kasowanie tabeli dań w bazie lokalnej
                      Rests.deleteAllRests().then((_) {
                        //kasowanie tabeli restauracji w bazie lokalnej
                        Podkategorie.deleteAllPodkategorie().then((_) {
                          //kasowanie tabeli podkategorii w bazie lokalnej
                          Meals.fetchMealsFromSerwer(
                                  'https://cobytu.com/cbt.php?d=f_dania&uz_id=&dev=${globals.deviceId}&woj_id=${_memLok[0].a}&mia_id=${_memLok[0].c}&rest=${_memLok[0].e}&lang=$language')
                              .then((_) {
                            Rests.fetchRestsFromSerwer().then((_) {
                              Podkategorie.fetchPodkategorieFromSerwer(
                                      'https://cobytu.com/cbt.php?d=f_podkategorie&uz_id=&woj_id=${_memLok[0].a}&mia_id=${_memLok[0].c}&rest=${_memLok[0].e}&lang=$language')
                                  .then((_) {
                                Provider.of<Cart>(context, listen: false)
                                    .fetchAndSetCartItems(
                                        'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${_memLok[0].e}&lang=$language')
                                    .then((_) {
                                  //zawartość koszyka z www
                                  Provider.of<Meals>(context, listen: false)
                                      .fetchAndSetMeals()
                                      .then((_) {
                                    //z bazy lokalnej
                                    Provider.of<Podkategorie>(context, listen: false)
                                        .fetchAndSetPodkategorie()
                                        .then((_) {
                                      //z bazy lokalnej
                                      if (globals.memoryLokE != '0') {
                                        //jezeli wybrano restaurację
                                        DBHelper.getRestWithId(
                                                globals.memoryLokE)
                                            .then((restaurant) {
                                          globals.online = restaurant.asMap()[0]
                                              [
                                              'online']; //'1'  - zamawianie online przez CoByTu.com
                                          globals.dostawy = restaurant
                                                  .asMap()[0][
                                              'dostawy']; //'1' - resta dostarcza z dowozem
                                          globals.cenaOpakowania = restaurant
                                                  .asMap()[0][
                                              'opakowanie']; //cena za jedno opakowanie
                                          globals.wybranaStrefa =
                                              1; //domyślna strefa
                                        });
                                      }
                                      _setPrefers('reload',
                                          'false'); //dane aktualne - nie trzeba przeładować danych
                                      print(
                                          'https://cobytu.com/cbt.php?d=f_dania&uz_id=&woj_id=${_memLok[0].a}&mia_id=${_memLok[0].c}&rest=${_memLok[0].e}&lang=$language');

                                      setState(() {
                                        _tytul = (_memLok[0].e == '0')
                                            ? _memLok[0].d
                                            : _memLok[0]
                                                .f; //nazwa miasta lub restauracji
                                        _isLoading =
                                            false; //zatrzymanie wskaznika ładowania danych
                                      });
                                    });
                                  });
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                }
              } else {
                print('braaaaaak internetu');
                _showAlertAnuluj(
                    context,
                    allTranslations.text('L_BRAK_INTERNETU'),
                    allTranslations.text('L_URUCHOM_INTERNETU'));
              } //if (inter != null && inter) {
            }); //isInternet
          } else {
            //wystarczy załadowanie dań z bazy loklnej - nie było potrzeby przeładowania danych z serwera
            fetchMemoryLok().then((_) {
              //pobranie aktualnie wybranej lokalizacji z bazy lokalnej (zeby uzyskać nazwę restauracji jako tytuł ekranu)
              print(
                  'meals_scerrn: dane lokalne - załadowanie dań z bazy loklnej');
              //             Provider.of<Cart>(context)
              //                .fetchAndSetCartItems(
              //                    'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${_memLok[0].e}&lang=$language')
              //                .then((_) {
              //zawartość koszyka z www - przeniesiona nizej zeby nie blokować ładowania z bazy gdy nie ma internetu
              Provider.of<Meals>(context, listen: false).fetchAndSetMeals().then((_) {
                //z bazy lokalnej
                Provider.of<Podkategorie>(context, listen: false)
                    .fetchAndSetPodkategorie()
                    .then((_) {
                  //z bazy lokalnej
                  if (globals.memoryLokE != '0') {
                    //jezeli wybrano restaurację
                    DBHelper.getRestWithId(globals.memoryLokE)
                        .then((restaurant) {
                      globals.online = restaurant.asMap()[0][
                          'online']; //'1'  - zamawianie online przez CoByTu.com
                      globals.dostawy = restaurant.asMap()[0]
                          ['dostawy']; //'1' - resta dostarcza z dowozem
                      globals.cenaOpakowania = restaurant.asMap()[0]
                          ['opakowanie']; //cena za jedno opakowanie
                      globals.wybranaStrefa = 1; //domyślna strefa
                    });
                  }
                  setState(() {
                    _tytul = (_memLok[0].e == '0')
                        ? _memLok[0].d
                        : _memLok[0].f; //nazwa miasta lub restauracji
                    _isLoading = false; //zatrzymanie wskaznika ładowania dań
                  });

                  //zawartość koszyka z www - tutaj zeby nie blokować ładowania z bazy gdy nie ma internetu
                  Provider.of<Cart>(context, listen: false).fetchAndSetCartItems(
                      'https://cobytu.com/cbt.php?d=f_koszyk&uz_id=&dev=${globals.deviceId}&re=${_memLok[0].e}&lang=$language');
                });
              });
            });
            //        });
          }
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
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

  //pobieranie Id telefonu  - do identyfikacji apki jako uzytkownika
  Future<void> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      globals.deviceId = 'ios_' +
          iosDeviceInfo
              .identifierForVendor; // + '_' + iosDeviceInfo.model; // +'_' + wersja[0] + wersja[1] + wersja[2] + wersja[3]; // + '_' + iosDeviceInfo.model
      //return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      globals.deviceId = 'and_' +
          androidDeviceInfo.androidId; // + '_' + androidDeviceInfo.model;
      //wersja[0] + wersja[1] + wersja[2] + wersja[3]; //androidDeviceInfo.model
      //return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  //ustawienianie zmiennych globalnych
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }

  //odczyt zmiennych globalnych
  _getPrefers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      reload = prefs.getString('reload') ?? '0';
      initApp = prefs.getString('initApp') ?? '0';
      language = prefs.getString('language') ?? '0';
      //podkategoria = prefs.getString('podkategoria') ?? '0';
    });
    print('get reload=$reload');
    print('get language=$language');
  }

  //pobranie memory Ver z bazy lokalnej
  Future<void> fetchMemoryVer() async {
    final data = await DBHelper.getMemory('memVer');
    _memVer = data
        .map(
          (item) => Mem(
            nazwa: item['nazwa'],
            a: item['a'],
            b: item['b'],
            c: item['c'],
            d: item['d'],
            e: item['e'],
            f: item['f'],
          ),
        )
        .toList();
    return _memVer;
  }

  //pobranie memory Lok z bazy lokalnej
  Future<void> fetchMemoryLok() async {
    final data = await DBHelper.getMemory('memLok');
    _memLok = data
        .map(
          (item) => Mem(
            nazwa: item['nazwa'],
            a: item['a'],
            b: item['b'],
            c: item['c'],
            d: item['d'],
            e: item['e'],
            f: item['f'],
          ),
        )
        .toList();
    globals.memoryLokE =
        _memLok[0].e; //zapisanie id wybranej restauracji do zmiennej globalnej
    globals.memoryLokC =
        _memLok[0].c; //zapisanie id wybranego miasta do zmiennej globalnej
    return _memLok;
  }

  @override
  Widget build(BuildContext context) {
    //final snackBar = SnackBar(content: Text('Zapisano nową lokalizację'));
    //Scaffold.of(context).showSnackBar(snackBar);
    print('meals_scerrn: globals.deviceId = ${globals.deviceId}');
    globals.wersja =
        wersja[0] + '.' + wersja[1] + '.' + wersja[2] + '.' + wersja[3];
    //podkategorie + rodzaje
    var podkatData = Provider.of<Podkategorie>(context, listen: false);
    final podkat1 = podkatData.items.where((podk) {
      return podk.kaId.contains('1');
    }).toList();
    final podkat2 = podkatData.items.where((podk) {
      return podk.kaId.contains('2');
    }).toList();
    final podkat3 = podkatData.items.where((podk) {
      return podk.kaId.contains('3');
    }).toList();
    final podkat4 = podkatData.items.where((podk) {
      return podk.kaId.contains('4');
    }).toList();
    final podkat5 = podkatData.items.where((podk) {
      return podk.kaId.contains('5');
    }).toList();
    final podkat6 = podkatData.items.where((podk) {
      return podk.kaId.contains('6');
    }).toList();
    final podkat7 = podkatData.items.where((podk) {
      return podk.kaId.contains('7');
    }).toList();
    final podkat8 = podkatData.items.where((podk) {
      return podk.kaId.contains('8');
    }).toList();
    final podkat9 = podkatData.items.where((podk) {
      return podk.kaId.contains('9');
    }).toList();
    //print('podk ${podkat4[0].nazwa}');

    //dania
    var mealsData = Provider.of<Meals>(context, listen: false);

    if (podkategoria1 == '291')
      meals1 = mealsData.items.where((meal) {
        return meal.kategoria.contains('1');
      }).toList(); //dania dla wybranej kategorii i wersji podstawowej
    else if (int.parse(podkategoria1) < 290)
      meals1 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria1);
      }).toList();
    else
      meals1 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    if (podkategoria2 == '292')
      meals2 = mealsData.items.where((meal) {
        return meal.kategoria.contains('2');
      }).toList();
    else if (int.parse(podkategoria2) < 290)
      meals2 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria2);
      }).toList();
    else
      meals2 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    if (podkategoria3 == '293')
      meals3 = mealsData.items.where((meal) {
        return meal.kategoria.contains('3');
      }).toList();
    else if (int.parse(podkategoria3) < 290)
      meals3 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria3);
      }).toList();
    else
      meals3 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    //print('podkat=$podkategoria');
    if (podkategoria4 == '294')
      meals4 = mealsData.items.where((meal) {
        return meal.kategoria.contains('4');
      }).toList();
    else if (int.parse(podkategoria4) < 290)
      meals4 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria4);
      }).toList();
    else
      meals4 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    if (podkategoria5 == '295')
      meals5 = mealsData.items.where((meal) {
        return meal.kategoria.contains('5');
      }).toList();
    else if (int.parse(podkategoria5) < 290)
      meals5 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria5);
      }).toList();
    else
      meals5 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    if (podkategoria6 == '296')
      meals6 = mealsData.items.where((meal) {
        return meal.kategoria.contains('6');
      }).toList();
    else if (int.parse(podkategoria6) < 290)
      meals6 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria6);
      }).toList();
    else
      meals6 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    if (podkategoria7 == '297')
      meals7 = mealsData.items.where((meal) {
        return meal.kategoria.contains('7');
      }).toList();
    else if (int.parse(podkategoria7) < 290)
      meals7 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria7);
      }).toList();
    else
      meals7 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    if (podkategoria8 == '298')
      meals8 = mealsData.items.where((meal) {
        return meal.kategoria.contains('8');
      }).toList();
    else if (int.parse(podkategoria8) < 290)
      meals8 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria8);
      }).toList();
    else
      meals8 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();

    if (podkategoria9 == '299')
      meals9 = mealsData.items.where((meal) {
        return meal.kategoria.contains('9');
      }).toList();
    else if (int.parse(podkategoria9) < 290)
      meals9 = mealsData.items.where((meal) {
        return meal.podkat.contains(podkategoria9);
      }).toList();
    else
      meals9 = mealsData.items.where((meal) {
        return meal.rodzaj.contains(rodzaj);
      }).toList();
 print('uzLogin=${globals.uzLogin}');
    return Scaffold(
      //strona główna - menu
      body: DefaultTabController(
        length: 9,
        initialIndex: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_tytul), //nazwa restauracji
            //ikona koszyka na pasku górnym
            actions: globals.memoryLokE != '0'
                ? <Widget>[
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          showSearch(
                              context: context, delegate: FootItemsSearch());
                        }),
                    //id restauracji = '0' - tzn. Wszystkie w mieście
                    Consumer<Cart>(
                      builder: (_, cart, ch) => Badge(
                        child: ch,
                        value: cart.itemCount
                            .toString(), //globals.wKoszykuAll.toString(), //
                      ),
                      child: globals.online ==
                              '1' //'1' - zamówienia online przez CoByTu.com
                          ? IconButton(
                              icon: Icon(
                                Icons
                                    .shopping_cart, //koszyk - mozna zamawiać online
                              ),
                              onPressed: () {
                                //czy jest Internet
                                _isInternet().then((inter) {
                                  if (inter != null && inter) {
                                    Navigator.of(context)
                                        .pushNamed(CartScreen.routeName);
                                  } else {
                                    print('braaaaaak internetu');
                                    _showAlertAnuluj(
                                        context,
                                        allTranslations
                                            .text('L_BRAK_INTERNETU'),
                                        allTranslations
                                            .text('L_URUCHOM_INTERNETU'));
                                  }
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                Icons
                                    .room_service, //stolik - bez zamawiania online
                              ),
                              onPressed: () {
                                //czy jest Internet
                                _isInternet().then((inter) {
                                  if (inter != null && inter) {
                                    Navigator.of(context)
                                        .pushNamed(CartScreen.routeName);
                                  } else {
                                    print('braaaaaak internetu');
                                    _showAlertAnuluj(
                                        context,
                                        allTranslations
                                            .text('L_BRAK_INTERNETU'),
                                        allTranslations
                                            .text('L_URUCHOM_INTERNETU'));
                                  }
                                });
                              },
                            ),
                    ),
                  ]
                : <Widget>[
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          showSearch(
                              context: context, delegate: FootItemsSearch());
                        }),
                  ],

            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              tabs: <Widget>[
                Tab(
                  text: allTranslations.text('L_SNIADANIA'),
                ), //Tab(icon: Icon(Icons.category),text: 'Kategoria1',),
                Tab(
                  text: allTranslations.text('L_PRZYSTAWKI'),
                ),
                Tab(
                  text: allTranslations.text('L_ZUPY'),
                ),
                Tab(
                  text: allTranslations.text('L_SALATKI'),
                ),
                Tab(
                  text: allTranslations.text('L_DANIA_GLOWNE'),
                ),
                Tab(
                  text: allTranslations.text('L_DLA_DZIECI'),
                ),
                Tab(
                  text: allTranslations.text('L_DESERY'),
                ),
                Tab(
                  text: allTranslations.text('L_NAPOJE'),
                ),
                Tab(
                  text: allTranslations.text('L_ALKOHOLE'),
                ),
              ],
            ),
          ),
          //drawer:
          //MainDrawer(), //Drawer(child: Text('data'),), //ikona burgera z szufladą
          body: _isLoading //jezeli dane są ładowane
              ? Center(
                  child: CircularProgressIndicator(), //kółko ładowania danych
                )
              : TabBarView(children: <Widget>[
                  //wyświetlenie listy dań

                  //ŚNIADANIA
                  meals9.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat9.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria9 = podkat9[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat9[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria9 ==
                                                podkat9[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat9[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat9[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań
                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals9[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals9.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),

                  //PRZYSTAWKI
                  meals1.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat1.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria1 = podkat1[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat1[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria1 ==
                                                podkat1[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat1[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat1[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań
                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals1[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals1.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),

                  //ZUPY
                  meals2.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat2.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria2 = podkat2[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat2[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria2 ==
                                                podkat2[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat2[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat2[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań
                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals2[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals2.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),

                  //SAŁATKI
                  meals3.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat3.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria3 = podkat3[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat3[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria3 ==
                                                podkat3[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat3[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat3[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań

                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals3[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals3.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            height: 150,
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                              softWrap: true, //zawijanie tekstu
                              maxLines: 5,
                            ),
                          )
                        ]),

                  //DANIA GŁOWNE
                  meals4.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat4.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria4 = podkat4[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat4[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria4 ==
                                                podkat4[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat4[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat4[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań

                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals4[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals4.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),

                  // DLA DZIECI
                  meals5.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat5.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria5 = podkat5[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat5[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria5 ==
                                                podkat5[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat5[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat5[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań
                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals5[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals5.length,
                              ),
                            ),
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),

                  //DESERY
                  meals6.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat6.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria6 = podkat6[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat6[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria6 ==
                                                podkat6[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat6[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat6[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań
                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals6[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals6.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),

                  //NAPOJE
                  meals7.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat7.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria7 = podkat7[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat7[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria7 ==
                                                podkat7[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat7[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat7[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań
                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals7[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals7.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),

                  //ALKOHOLE
                  meals8.length > 0 //jezeli są dania w tej kategorii
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //podkategorie
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 1.0),
                              height:
                                  46, //MediaQuery.of(context).size.height * 0.35,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: podkat8.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      //width: MediaQuery.of(context).size.width * 0.6,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            podkategoria8 = podkat8[index]
                                                .id; //dla filtrowania po podkategorii
                                            rodzaj = podkat8[index]
                                                .nazwa; //dla filtrowania po rodzaju dania
                                          });
                                        },
                                        child: podkategoria8 ==
                                                podkat8[index].id
                                            ? Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat8[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17.0),
                                                  )),
                                                ),
                                              )
                                            : Card(
                                                color: Colors.white,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 1.0),
                                                  child: Center(
                                                      child: Text(
                                                    podkat8[index].nazwa,
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0),
                                                  )),
                                                ),
                                              ),
                                      ),
                                    );
                                  }),
                            ),
                            //lista dań
                            Expanded(
                              child: ListView.builder(
                                //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                                itemBuilder: (ctx, index) =>
                                    ChangeNotifierProvider.value(
                                  value: meals8[index],
                                  child: MealItem(),
                                ),
                                itemCount: meals8.length,
                              ),
                            )
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 50),
                            child: Text(
                              allTranslations.text('L_BRAK_DAN'),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ]),
                ]),
        ),
      ),
    );
  }
}

class FootItemsSearch extends SearchDelegate<Meals> {
  @override
  String get searchFieldLabel => allTranslations.text('L_SZUKAJ');
  @override
  @override
  TextStyle get searchFieldStyle =>
      TextStyle(fontFamily: 'Raleway', fontWeight: FontWeight.normal);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //powtórzony kod z "buildSuggestions" zeby nie ginął wynik po naciśnięciu lupy na wyświetlonej klawiaturze telefonu
    var myList = query.isEmpty
        ? Provider.of<Meals>(context, listen: false).items.toList()
        : Provider.of<Meals>(context, listen: false)
            .items
            .where((p) =>
                p.nazwa.toLowerCase().contains(query.toLowerCase()) ||
                p.opis.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return myList.isEmpty
        ? Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    allTranslations.text('L_BRAK_WYNIKOW'),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Expanded(
                  child: ListView.builder(
                    itemCount: myList.length,
                    //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (context, index) =>
                        ChangeNotifierProvider.value(
                      value: myList[index],
                      child: MealItem(),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var myList = query.isEmpty
        ? Provider.of<Meals>(context, listen: false).items.toList()
        : Provider.of<Meals>(context, listen: false)
            .items
            .where((p) =>
                p.nazwa.toLowerCase().contains(query.toLowerCase()) ||
                p.opis.toLowerCase().contains(query.toLowerCase()))
            .toList();
    return myList.isEmpty
        ? Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 50),
                  child: Text(
                    allTranslations.text('L_BRAK_WYNIKOW'),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Expanded(
                  child: ListView.builder(
                    itemCount: myList.length,
                    //ładowane są te elementy listy które widać na ekranie - lepsza wydajność
                    itemBuilder: (context, index) =>
                        ChangeNotifierProvider.value(
                      value: myList[index],
                      child: MealItem(),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
