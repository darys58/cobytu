import 'package:flutter/foundation.dart'; //zeby mozna było ustawić ze argumenty są wymagane (dekorator @required)

//składniki dania dla szczegółów dania

class DetailIngred{
  final String doId;          //do_id
  final String rdId;          //do_rd_id
  final String ndNazwa;       //nd_nazwa
  final String fdForma;       //fd_forma
  final String daId;          //dd_da_id
  final String doKcal100;     //do_kcal100
  final String udLubi;        //ud_lubi
  

 DetailIngred({
    @required this.doId,
    @required this.rdId,
    @required this.ndNazwa,      
    @required this.fdForma,
    @required this.daId,
    @required this.doKcal100,
    @required this.udLubi,

  });


}