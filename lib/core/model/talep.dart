import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Talep{
  String kuryeId;
  String customerId;
  String talepDurum;
  LatLng customerKonum;
  bool talepAktif;

  Talep({required this.talepDurum,required this.kuryeId,required this.customerId,required this.customerKonum,required this.talepAktif});

  static Talep fromMap(Map<String, dynamic> map) {
    final konum = LatLng((map["customerKonum"] as GeoPoint).latitude, (map["customerKonum"] as GeoPoint).longitude);
    return Talep(talepDurum: map["talepDurum"], kuryeId: map["kuryeId"], customerId: map["customerId"], customerKonum: konum, talepAktif: map["talepAktif"]);
  }
  Map<String,dynamic> toMap(){
    final Map<String, dynamic> map = {
      "kuryeId":kuryeId,
      "customerId":customerId,
      "talepDurum":talepDurum,
      "customerKonum":GeoPoint(customerKonum.latitude, customerKonum.longitude),
      "talepAktif":talepAktif,
    };
    return map;
  }

}