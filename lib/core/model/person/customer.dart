import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/components/valid_email.dart';

class Customer {
  final String _uid;
  String ad;
  String soyad;
  String telefon;
  String _eposta;
  String parola;
  LatLng? enlemBoylam;
  String rol;

  String get eposta => _eposta;
  String get uid => _uid;

  set eposta(String value) {
    //Burada girilen epostanın geçerli bir adres olup olmadığı kontrol ediliyor
    if (ValidEmail.isValidEmail(value)) {
      _eposta = value;
    } else {
      throw Exception("Geçersiz Eposta Adresi!");
    }
  }

  // Set<Kurye>? enYakinKuryeler = {};//TODO CACHE bunu local'de oluştur veritabanında tutturma(oluyorsa)
  // int? enYakinKuryeIndex = 0;//bu tamamen silinecek. Her seferinde yeniden arayacağımız için ve redIdler olduğu için

  Customer(
      {required String uid,
      required this.ad,
      required this.soyad,
      required this.telefon,
      required this.parola,
      required String eposta,
      this.enlemBoylam,
      required this.rol})
      : _eposta = eposta,
        _uid = uid;

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "ad": ad,
      "soyad": soyad,
      "telefon": telefon,
      "eposta": eposta,
      "parola": parola,
      "rol": "musteri",
      "enlemBoylam": enlemBoylam
    };
  }

  static Customer fromMap(Map<String, dynamic> map) {
    final GeoPoint geoPoint = map["enlemBoylam"];
    return Customer(
        uid: map["uid"],
        ad: map["ad"],
        soyad: map["soyad"],
        telefon: map["telefon"],
        eposta: map["eposta"],
        parola: map["parola"],
        rol: map["rol"],
        enlemBoylam: LatLng(geoPoint.latitude, geoPoint.longitude));
  }

  static Customer get blank =>
      Customer(uid: "", ad: "Yükleniyor", soyad: "", telefon: "", parola: "", eposta: "", rol: "musteri");
}
