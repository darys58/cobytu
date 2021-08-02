import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';

//DO USUNIĘCIA!!! widget ekranu z kawałkiem mapy na której mozna pokazać "Moją lokalizację"  - nie uzywane!


class LocationInput extends StatefulWidget {
  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl; //adres URL wskazujący podgląd migawki mapy z Google

  Future<void> _getCurrentUserLocation() async {
    //kurs lekcja 305
    final locData = await Location().getLocation();
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitude: locData.latitude, longitude: locData.longitude);
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
    //print(locData.latitude);
    //print(locData.longitude);
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => MapScreen(
                isSelecting: true,
              )),
    );
    if (selectedLocation == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 170,
          width: double.infinity, //cała szerokość pojemnika
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _previewImageUrl == null
              ? Text(
                  'Nie wybrano lokalizacji',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.location_on,
              ),
              label: Text('Moja lokalizacja'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _selectOnMap, //_getCurrentUserLocation,
            )
          ],
        )
      ],
    );
  }
}
