library cobytu.globals;

//int wKoszykuAll = 0;//ilość wsystkich dań w koszyku
int wKoszyku = 0; //ile razy wybrane danie znajduje się w koszyku w koszyku
String deviceId; //Id telefonu - identyfikator apki/uzytkownika
String wersja; //wersja apki
String memoryLokE = '31'; //id wybranej restauracji
String memoryLokC = '1'; //id miasta
String language; //język
String separator; // '.' lub ',' ustawiany w meal_item.dart
String cenaOpakowania; //cena jednego opakowania
String dostawy; //'0' brak dostaw, '1' - restauracja dostarcza z dowozem
String online; //'0' brak, '1' - zamawianie online przez CoByTu.com
int czyDostawa; //wybrany przez uzytkownika sposób dostarczenia zamówienia
int sposobPlatnosci; //wybrany przez uzytkownika sposób płatności
int wybranaStrefa; ////wybrany przez uzytkownika strefa dostawy
String adres; //adres dostawy
String numer;
String kod;
String miasto;
String imie;
String nazwisko;
String telefon;
String email; //email dostawy
String kodMobile; //kod wysyłany do połączenia konta na www.cobytu.com z apką
String uzLogin; //login uzytkownika - jezeli jest połączenie apki z kontem na www.cobytu.com
