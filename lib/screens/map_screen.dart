import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/pleace.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text('mapa'),
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.initalLocation.latitude,
              widget.initalLocation.longitude,
            ),
            zoom: 16,
          ),
          markers: {
            Marker(
              markerId: MarkerId('m1'),
              position: LatLng(
                widget.initalLocation.latitude,
                widget.initalLocation.longitude,
              ),
              infoWindow: InfoWindow(
                  title: 'Rogatka',
                  onTap: () {
                    var bottomSheetController = scaffoldKey.currentState
                        .showBottomSheet((context) => Container(
                              child:
                                  getBottomSheet("52.21383443, 18.25481668"),
                              height: 250,
                              color: Colors.transparent,
                            ));
                    print(bottomSheetController);
                  },
                  snippet: "dodatkowy text"
                )
              ),

              Marker(
              markerId: MarkerId('m2'),
              position: LatLng(
                52.23383443,
                widget.initalLocation.longitude,
              ),
              infoWindow: InfoWindow(
                  title: 'Borówka',
                  onTap: () {
                    var bottomSheetController = scaffoldKey.currentState
                        .showBottomSheet((context) => Container(
                              child:
                                  getBottomSheet("52.20649828, 18.25458093"),
                              height: 250,
                              color: Colors.transparent,
                            ));
                    print(bottomSheetController);
                  },
                  snippet: "dodatkowy text"
                )
              ),

              
          },
        ));
  }

  Widget getBottomSheet(String s) {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 32),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Hytech City Public School \n CBSC",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: <Widget>[
                          Text("4.5",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                          Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text("970 Folowers",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14))
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Memorial Park",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.map,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("$s")
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    Icons.call,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text("040-123456")
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
                child: Icon(Icons.navigation), onPressed: () {}),
          ),
        )
      ],
    );
  }
}
