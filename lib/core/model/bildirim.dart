import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Bildirim {
  String _gonderenId;
  String _aliciId;
  String _gonderenRol;
  String _aliciRol;
  LatLng _gonderenKonum;
  String _bildirimIcerik;
  bool _bildirimAktif;
  List<String>? _redIdler;

  String get gonderenId => _gonderenId;
  set gonderenId(String value) {
    _gonderenId = value;
  }

  String get aliciId => _aliciId;
  set aliciId(String value) {
    _aliciId = value;
  }

  String get gonderenRol => _gonderenRol;
  set gonderenRol(String value) {
    _gonderenRol = value;
  }

  String get aliciRol => _aliciRol;
  set aliciRol(String value) {
    _aliciRol = value;
  }

  LatLng get gonderenKonum => _gonderenKonum;
  set gonderenKonum(LatLng value) {
    _gonderenKonum = value;
  }

  String get bildirimIcerik => _bildirimIcerik;
  set bildirimIcerik(String value) {
    _bildirimIcerik = value;
  }

  bool get bildirimAktif => _bildirimAktif;
  set bildirimAktif(bool value) {
    _bildirimAktif = value;
  }

  List<String>? get redIdler => _redIdler;
  set redIdler(List<String>? value) {
    _redIdler = value;
  }

  Bildirim(
      {required String gonderenId,
      required String aliciId,
      required String gonderenRol,
      required String aliciRol,
      required String bildirimIcerik,
      required bool bildirimAktif,
      List<String>? redIdler,
      required LatLng gonderenKonum})
      : _redIdler = redIdler,
        _bildirimAktif = bildirimAktif,
        _bildirimIcerik = bildirimIcerik,
        _gonderenKonum = gonderenKonum,
        _aliciRol = aliciRol,
        _gonderenRol = gonderenRol,
        _aliciId = aliciId,
        _gonderenId = gonderenId;

  Map<String, dynamic> toMap() {
    return {
      "gonderenId": gonderenId,
      "aliciId": aliciId,
      "gonderenRol": gonderenRol,
      "aliciRol": aliciRol,
      "bildirimIcerik": bildirimIcerik,
      "bildirimAktif": bildirimAktif,
      "gonderenKonum": GeoPoint(gonderenKonum.latitude, gonderenKonum.longitude),
      "redIdler": redIdler
    };
  }

  static Bildirim fromMap(Map<String, dynamic> map) {
    LatLng konum = LatLng((map["gonderenKonum"] as GeoPoint).latitude, (map["gonderenKonum"] as GeoPoint).longitude);
    return Bildirim(
        gonderenId: map["gonderenId"],
        aliciId: map["aliciId"],
        gonderenRol: map["gonderenRol"],
        aliciRol: map["aliciRol"],
        bildirimIcerik: map["bildirimIcerik"],
        bildirimAktif: map["bildirimAktif"],
        redIdler: map["redIdler"] as List<String>?,
        gonderenKonum: konum);
  }
}
