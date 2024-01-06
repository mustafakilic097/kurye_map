import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Kurye {
  String uid;
  String ad;
  String soyad;
  String telefon;
  String eposta;
  String parola;
  LatLng? enlemBoylam;
  String arac;
  String rol;
  bool aktifMi;

  Kurye({required this.uid,required this.ad,required this.soyad, required this.telefon,required this.eposta, required this.parola,this.enlemBoylam,required this.arac,required this.rol,required this.aktifMi});

  static Kurye fromMap(Map<String,dynamic> map){
    if(map["enlemBoylam"]==null){
      return Kurye(uid: map["uid"],ad: map["ad"],soyad: map["soyad"],telefon: map["telefon"],eposta: map["eposta"],parola: map["parola"],rol: map["rol"], arac: map["arac"],aktifMi: map["aktifMi"]);
    }
    else{
      GeoPoint geoPoint = map["enlemBoylam"];
      return Kurye(uid: map["uid"],ad: map["ad"],soyad: map["soyad"],telefon: map["telefon"],eposta: map["eposta"],parola: map["parola"],rol: map["rol"], arac: map["arac"],aktifMi: map["aktifMi"],enlemBoylam: LatLng(geoPoint.latitude, geoPoint.longitude));
    }
  }
}