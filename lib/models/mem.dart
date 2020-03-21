import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)


class Mem {
  final String nazwa;       //memLok
  final String a;          //wojId
  final String b;          //woj
  final String c;          //miaId
  final String d;          //mia
  final String e;          //restId
  final String f;          //resta


  Mem({
      @required this.nazwa, 
      this.a, 
      this.b, 
      this.c, 
      this.d, 
      this.e, 
      this.f,
  });
}