import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)

//dane dania dla szczegółów dania

class DetailMeal {
  final String id;                  //da_id: String
  final String nazwa;               //da_nazwa: String
  final String opis;                //da_opis: String
  final String cena;                //cena: String
  final String czas;                //da_czas: String
  final int waga;                   //waga: Int
  final int kcal;                   //kcal: Int
  final int lubi;                   //da_lubi: Int
  final int stolik;                 //na_stoliku: Int
  final List<dynamic> alergeny;      //alergeny:[String] //wszystkie alergeny (a nie zalogowanego)
  final String srednia;             //da_srednia: String
  final String cenaPodst;           //cena_podst: String
  final String wagaPodst;           //da_waga_podst: String
  final String kcalPodst;           //da_kcal_podst: String
  final List<dynamic> werListId;     //da_id_lista_wer:[String]    //lista id dań poszczególnych wersji
  final List<dynamic> werList;       //da_wersja_lista:[String]    //lista nazw wersji dania
  final List<dynamic> warUlub;       //do_wariant: [String]        //dodatek wariantowy 1 i 2 ulubiony
  final List<dynamic> warList1;      //do_wariant_lista1: [String]
  final List<dynamic> warList2;      //do_wariant_lista2: [String]
  final List<dynamic> dodat;         //do_dodat: [String]
  final List<dynamic> podstId;       //do_podst_id: [String]
  final List<dynamic> warUlubId;     //do_wariant_id: [String]     //id dodatku wariantowego 1 i 2 ulubionego
  final List<dynamic> warList1Id;    //do_wariant_lista1_id: [String]
  final List<dynamic> warList2Id;    //do_wariant_lista2_id: [String]
  final List<dynamic> dodatId;       //do_dodat_id: [String]
  final List<dynamic> warList1Waga;  //do_wariant_lista1_waga: [String]
  final List<dynamic> warList2Waga;  //do_wariant_lista2_waga: [String]
  final List<dynamic> dodatWaga;     //do_dodat_waga: [String]
  final List<dynamic> warList1Kcal;  //do_wariant_lista1_kcal: [String]
  final List<dynamic> warList2Kcal;  //do_wariant_lista2_kcal: [String]
  final List<dynamic> dodatKcal;     //do_dodat_kcal: [String]
  final List<dynamic> warList1Cena;  //do_wariant_lista1_cena: [String]
  final List<dynamic> warList2Cena;  //do_wariant_lista2_cena: [String]
  final List<dynamic> dodatCena;     //do_dodat_cena: [String]

  DetailMeal({
    @required this.id,
    @required this.nazwa,
    @required this.opis,
    @required this.cena,
    @required this.czas,
    @required this.waga,
    @required this.kcal,
    @required this.lubi,
    @required this.stolik,
    @required this.alergeny,
    @required this.srednia,
    @required this.cenaPodst,
    @required this.wagaPodst,
    @required this.kcalPodst,
    @required this.werListId, 
    @required this.werList,
    @required this.warUlub,
    @required this.warList1,
    @required this.warList2,
    @required this.dodat,
    @required this.podstId,
    @required this.warUlubId,
    @required this.warList1Id,
    @required this.warList2Id,
    @required this.dodatId,
    @required this.warList1Waga,
    @required this.warList2Waga,
    @required this.dodatWaga,
    @required this.warList1Kcal,
    @required this.warList2Kcal,
    @required this.dodatKcal,
    @required this.warList1Cena,
    @required this.warList2Cena,
    @required this.dodatCena,
   
   }); 
}