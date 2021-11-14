import 'dart:convert'; //obsługa json'a
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meals/all_translations.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart'; //czy jest Internet
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/meals_screen.dart';
import '../models/detailRest.dart';
import '../models/pleace.dart';
import '../models/mem.dart';
import '../models/mems.dart';
import '../helpers/db_helper.dart'; //dostęp do bazy lokalnej
import '../models/rests.dart';
import '../globals.dart' as globals;

class MapScreen extends StatefulWidget {
  final PlaceLocation initalLocation;
  final bool isSelecting;

  MapScreen(
      {this.initalLocation =
          const PlaceLocation(latitude: 52.21383443, longitude: 18.25481668),
      this.isSelecting = false}); //w [] wartość opcjonalna

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  var _isInit = true; //czy inicjowanie ekranu?
  var _isLoading = false; //czy ładowanie danych?
  List<Mem> _memLok; //dane wybranej lokalizacji w tabeli memory - baza lokalna
  //String _currentValue; //domyślna restauracja
  final Set<Marker> markers = new Set(); //markers for google map
  List<DetailRest> _mealRestsData = []; //szczegóły restauracji
  String _currLang = allTranslations.currentLanguage; //aktualny język

  //static const LatLng showLocation = const LatLng(52.21383443, 18.25481668); //location to show in map

  @override
  void didChangeDependencies() {
    if (_isInit) {
      //wejście inicjalizujące - przy kadzym wejściu do ekranu
      setState(() {
        _isLoading = true; //uruchomienie wskaznika ładowania dań
      });
      print('map_screen didChangeDependencies ');
      fetchMemoryLok().then((_) {
        //pobranie ustawień  memLok z "memory"

        //pobranie restauracji dla miasta wybranego w location_screen
        Provider.of<Rests>(context, listen: false)
            .fetchAndSetRests(
                globals.miastoDlaMapy) // miasto wybrane w "location_screen"
            .then((_) {
          //z bazy lokalnej

          setState(() {
            _isLoading = false; //zatrzymanie wskaznika ładowania restauracji
          });
        }); //dostawca restauracji
        setState(() {
          _isLoading = false; //zatrzymanie wskaznika ładowania restauracji
        });
      });
    }

    _isInit = false;
    //Provider.of<Rests>(context, listen: false).fetchAndSetRests(); //dostawca restauracji
    super.didChangeDependencies();
  }

  //zapisywanie zmiennych w SharedPreferences (zmienne widoczne globalnie)
  _setPrefers(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('set $key = $value');
  }

  //pobranie memory z bazy lokalnej
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
    return _memLok;
  }

//pobranie (z serwera www) restauracji wybranej na mapie
  Future<List<DetailRest>> fetchDetailRestsFromSerwerForMap(
      String idRest) async {
    var url =
        'https://cobytu.com/cbt.php?d=f_resta&rest=$idRest&lang=$_currLang';
    print(url);
    try {
      final response = await http.get(url);
      print(json.decode(response.body));

      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return [];
      }

      //czyszczenie listy przed ponownym pobraniem danych
      _mealRestsData = [];

      //final List<MealRest> loadedRests = [];
      extractedData.forEach((restId, restData) {
        _mealRestsData.add(DetailRest(
          id: restId,
          logo: restData['re_logo'],
          nazwa: restData['re_nazwa'],
          obiekt: restData['re_obiekt'],
          adres: restData['re_adres'],
          kod: restData['re_kod'],
          miasto: restData['re_miasto'],
          woj: restData['re_woj'],
          tel1: restData['re_tel1'],
          tel2: restData['re_tel2'],
          email: restData['re_email'],
          www: restData['re_www'],
          gps: restData['re_gps'],
          otwarteA: restData['re_otwarte_a'],
          otwarteB: restData['re_otwarte_b'],
          otwarteC: restData['re_otwarte_c'],
          cena: restData['cena'],
          dostawy: restData['re_tel_dos'],
          online: restData['re_online'],
          parking: restData['re_parking'],
          podjazd: restData['re_podjazd'],
          wynos: restData['re_na_wynos'],
          karta: restData['re_p_karta'],
          zabaw: restData['re_s_zabaw'],
          letni: restData['re_o_letni'],
          klima: restData['re_klima'],
          wifi: restData['re_wifi'],
          modMenu: restData['re_mod_menu'],
        ));
      });
      // _items = loadedRests;
      print('dane restauracji w MealRests = ${_mealRestsData[0].nazwa}');
      //notifyListeners();
      return _mealRestsData;
    } catch (error) {
      throw (error);
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
    print('mapa - budowanie ekranu');
    //final restsData = Provider.of<Rests>(context);
    //List<Rest> rests = restsData.items.toList();
    //print("nazwa z głównej =================");
    //print(mealRestsData[0].nazwa);

    final selectedRest = Provider.of<Rests>(context, listen: false).findById(globals
        .restauracjaDlaMapy); //dane restauracji tyczasowo wybranej w "location_screen"
    print('mapa pozycja rest - ${globals.restauracjaDlaMapy} ');

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(allTranslations.text('L_LOKALIZACJA')),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              double.parse(selectedRest.latitude),
              double.parse(selectedRest.longitude),
            ),
            zoom: 16,
          ),
          markers: getmarkers(),
        ));
  }

  //szuflada wysuwana od dołu
  Widget getBottomSheet(String s) {
    print("*****dane restauracji********");
    print(_mealRestsData[0].dostawy);
    print(_mealRestsData[0].online);
    print(s);
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 32),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _mealRestsData[0].nazwa, //nazwa restauracji
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                              _mealRestsData[0].kod +
                                  " " +
                                  _mealRestsData[0].miasto +
                                  ", ",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          //Icon(
                          //  Icons.star,
                          // color: Colors.yellow,
                          //),
                          SizedBox(
                            width: 5,
                          ),
                          Text(_mealRestsData[0].adres,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14))
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      //SizedBox(height: 15,),
                      Text(
                        allTranslations.text('L_GODZINY_OTWARCIA'),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3, //interlinia
                          color: Colors.black87,
                          //color: Theme.of(context).primaryColor,
                        ),
                      ),
                      //SizedBox(height: 5,),
                      Row(
                children: <Widget>[
                      Text(
                        _mealRestsData[0].otwarteB,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.3, //interlinia
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          //color: Theme.of(context).primaryColor,
                        ),
                      ),

                      SizedBox(
                          width: 20,
                        ),
              
                      _mealRestsData[0].dostawy == '1'
                        ? Image.asset('assets/images/dostawa.png')
                        : SizedBox(width: 20),
    
                      SizedBox(width: 15),    
                        
                      _mealRestsData[0].online == '1'
                        ? Image.asset('assets/images/cart.png')
                        : SizedBox(width: 20),

                      //SizedBox(height: 5,),
                      /*    if(_mealRestsData[0].otwarteC != '')
                          Text(_mealRestsData[0].otwarteC,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.3, //interlinia
                              color: Colors.black87,
                              //color: Theme.of(context).primaryColor,
                            ),
                          ),
                      */
                      ]),
                      //Text("Memorial Park",
                      //style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),

              //gps
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.map,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(_mealRestsData[0].gps)
                ],
              ),
              SizedBox(
                height: 10,
              ),
/*
              //dostawa
              _mealRestsData[0].dostawy == '1'
                  ? Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
                        Image.asset('assets/images/dostawa.png'),
                        SizedBox(width: 20),
                        Text("dostawa dań do klienta")
                      ],
                    )
                  : SizedBox(width: 1),

              //on-line
              _mealRestsData[0].online == '1'
                  ? Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
                        Image.asset('assets/images/cart.png'),
                        SizedBox(width: 20),
                        Text("zamawianie on-line przez CoByTu.com")
                      ],
                    )
                  : SizedBox(width: 1),
*/
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.call,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(
                    width: 20,
                  ),

                  /*    TextButton(
                   child: const Text('Enabled'),
                    onPressed: () {},
                    
                  ),
             */
                  Text(_mealRestsData[0].tel1 + "   " + _mealRestsData[0].tel2)
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
                child: Icon(Icons.navigation),
                onPressed: () {
                  //czy jest internet
                  _isInternet().then((inter) {
                    if (inter != null && inter) {
                      final _selRest =
                          Provider.of<Rests>(context, listen: false).findById(
                              _mealRestsData[0]
                                  .id); //dane restauracji wybranej z mapy
                      Mems.insertMemory(
                        'memLok', //nazwa
                        _selRest.wojId, //a
                        _selRest.woj, //b
                        _selRest.miaId, //c
                        _selRest.miasto, //d
                        _selRest.id, //e - '0' lub id restauracji
                        _mealRestsData[0]
                            .nazwa, //f - "Wszystkie" lub nazwa restauracji
                      );
                      _setPrefers('reload',
                          'true'); //konieczne załadowanie danych z serwera
                      globals.wybranaStrefa = 1; //domyślna strefa
                      globals.cenaOpakowania =
                          _selRest.opakowanie; //cena za jedno opakowanie
                      Navigator.of(context).pushNamedAndRemoveUntil(MealsScreen.routeName,ModalRoute.withName(MealsScreen.routeName)); //przejście z usunięciem wszystkich wczesniejszych tras i ekranów
                    } else {
                      print('braaaaaak internetu');
                      _showAlertAnuluj(
                          context,
                          allTranslations.text('L_BRAK_INTERNETU'),
                          allTranslations.text('L_URUCHOM_INTERNETU'));
                    }
                  });
                }),
          ),
        )
      ],
    );
  }

  //utworzenie wielu markerów
  Set<Marker> getmarkers() {
    //markers to place on map
    final restsData =
        Provider.of<Rests>(context, listen: false); //dane wszystkich restauracji w mieście
    //List<Rest> rests = restsData.items.toList();

    setState(() {
      for (var i = 0; i < restsData.items.length; i++) {
        markers.add(
          Marker(
            markerId:
                MarkerId(restsData.items[i].id), //id markera = id restauracji
            position: LatLng(
              double.parse(
                  restsData.items[i].latitude), //zmienna typu double ze stringa
              double.parse(restsData.items[i].longitude),
            ),
            infoWindow: InfoWindow(
                title: restsData.items[i].nazwa, //nazwa restauracji
                onTap: () {
                  _isInternet().then((inter) {
                    if (inter != null && inter) {
                      fetchDetailRestsFromSerwerForMap(restsData.items[i].id)
                          .then((_) {
                        globals.restauracjaDlaMapy = restsData.items[i].id;
                        print(
                            'pobranie szczegółów dla restauracji o id pobranym ze markera - ${restsData.items[i].id}');

                  /*      if ((restsData.items[i].dostawy == "1") &&
                            (restsData.items[i].online == "1")) {
                          var bottomSheetController = scaffoldKey.currentState
                              .showBottomSheet((context) => Container(
                                    child: getBottomSheet(
                                        restsData.items[i].nazwa),
                                    height: 300,
                                    color: Colors.transparent,
                                  ));
                          print(bottomSheetController);
                        } else {
                          if ((restsData.items[i].dostawy == "1") ||
                              (restsData.items[i].online == "1")) {
                            var bottomSheetController = scaffoldKey.currentState
                                .showBottomSheet((context) => Container(
                                      child: getBottomSheet(
                                          restsData.items[i].nazwa),
                                      height: 275,
                                      color: Colors.transparent,
                                    ));
                            print(bottomSheetController);
                          }
                        }
*/

                          var bottomSheetController = scaffoldKey.currentState
                              .showBottomSheet((context) => Container(
                                    child: getBottomSheet(
                                        restsData.items[i].nazwa),
                                    height: 250,
                                    color: Colors.transparent,
                                  ));
                          print(bottomSheetController);
                        

                        setState(() {
                          _isLoading =
                              false; //zatrzymanie wskaznika ładowania dań
                          //mealRestsData  = _mealRestsData ;
                        });
                      });
                    } else {
                      print('braaaaaak internetu');
                      _showAlertAnuluj(
                          context,
                          allTranslations.text('L_BRAK_INTERNETU'),
                          allTranslations.text('L_URUCHOM_INTERNETU'));
                    }
                  });
                },
                snippet: restsData.items[i].adres //tekst pod nazwą
                ),
            icon: BitmapDescriptor.defaultMarker, //Icon for Marker
          ),
        );

        print(restsData.items[i].nazwa);
        print(restsData.items[i].latitude);
      }
    });

    return markers;
  }
}
