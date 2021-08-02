const GOOGLE_API_KEY =
    'AIzaSyDfdDEdwtQNSCdrCIqTmK7-ZNPmHSdc22M'; //klucz z https://console.cloud.google.com/google/maps-apis/credentials?project=vibrant-circlet-319011 projekt cobytu

class LocationHelper { //nieuzywane, potrzebne przy ustawianiu swojej lokalizacji
  static String generateLocationPreviewImage({
    double latitude,
    double longitude,
  }) {
    print('spreparowanie zapytania https do googla');
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }
}
