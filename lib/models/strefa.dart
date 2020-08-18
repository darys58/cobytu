//import 'dart:convert'; //obsługa json'a
import 'package:flutter/foundation.dart';
//import 'package:http/http.dart' as http;

class Strefa {
  final String numer; //str_numer
  final String czynne; //czynne
  final String zamOd; //zamow_od
  final String zamDo; //zamow_do
  final String zakres; //str_zakres
  final String wartMin; //str_wart_min
  final String koszt; //str_koszt
  final String wartMax; //str_wart_max
  final String bonus; //str_wat_bonus
  final String platne; //re_platne_dos

  Strefa({
    @required this.numer,
    this.czynne,
    this.zamOd,
    this.zamDo,
    this.zakres,
    this.wartMin,
    this.koszt,
    this.wartMax,
    this.bonus,
    this.platne,
  });
}