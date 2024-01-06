import 'package:dio/dio.dart' show DioError;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:get/utils.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../constants/app/app_constants.dart';
import '../constants/enum/kurye_arac_enum.dart';
import '../init/network/network_manager.dart';
import '../model/map/distance_model.dart';
import '../model/person/kurye.dart';

//OK
class DistanceViewModel {
  //OK => Verilen başlangıçtan hedefe belirtilen araçla ulaşma bilgisini döndüren method
  static Future<Distance?> getDistance(
      {required LatLng baslangic, required LatLng hedef, required KuryeArac arac}) async {
    try {
      // İnternet bağlantısı var mı diye kontrol ediliyor.
      bool con = await InternetConnectionChecker().hasConnection;
      if (!con) throw Exception("İnternet bağlantısı yok !!");
      // API servisine isteğin gönderilmesi
      final data = await NetworkManager.instance.googleMapsApiGet({
        //Başlangıç konumu
        "origins": "${baslangic.latitude}, ${baslangic.longitude}",
        //Hedef konum
        "destinations": "${hedef.latitude}, ${hedef.longitude}",
        //Hangi araçla ulaşım sağlanacak
        "mode": arac == KuryeArac.WALKING
            ? "walking"
            : arac == KuryeArac.BICYCLING
                ? "bicycling"
                : "driving",
        // Google Maps API Key
        "key": AppConstants.GOOGLE_API_KEY
      });
      // Gelen verinin Distance'a çevirilmesi ve döndürülmesi
      return Distance.fromMap(data);
    } on DioError catch (e) {
      // API isteği sırasında çıkan hatalar için geriye döndürülen mesaj
      throw Exception("Google Maps API tarafında hata var! Hata:${e.message}");
    } on Exception catch (e) {
      // Diğer türlü throw edilen hatalar için geriye döndürülen mesaj
      Get.printError(info: e.toString());
      return null;
    }
  }

  //OK => Verilen başlangıçtan tüm hedeflere belirtilen araçla ulaşma bilgisini döndüren method
  static Future<List<Distance>?> getMultiDistance(
      {required LatLng baslangic, required List<Kurye> kuryeler, required KuryeArac arac}) async {
    try {
      // İnternet bağlantı kontrolü
      bool con = await InternetConnectionChecker().hasConnection;
      // İnternet bağlantısı yoksa döndürülen hata mesajı
      if (!con) throw Exception("İnternet bağlantısı yok!");

      // Tüm kuryelerin konumlarının API'n istediği formatta yazılması işlemi
      String kuryelerHedefString = "";
      for (var i = 0; i < kuryeler.length; i++) {
        if (kuryeler[i].enlemBoylam == null) {
          kuryeler[i].enlemBoylam = const LatLng(0, 0);
        }
        kuryelerHedefString += "${kuryeler[i].enlemBoylam!.latitude}, ${kuryeler[i].enlemBoylam!.longitude}";
        if (i != kuryeler.length - 1) kuryelerHedefString += "|";
      }
      // Başlangıç konumu,kuryelerin konumları ve araç bilgisinin API servisine istek olarak gönderilmesi
      final data = await NetworkManager.instance.googleMapsApiGet({
        // Başlangıç müşteri konumu
        "origins": "${baslangic.latitude}, ${baslangic.longitude}",
        // Tüm kuryelerin konumlarının istenen String formatında yazılmış hali
        "destinations": kuryelerHedefString,
        // Kuryenin ulaşım aracı
        "mode": arac == KuryeArac.WALKING
            ? "walking"
            : arac == KuryeArac.BICYCLING
                ? "bicycling"
                : "driving",
        // Google Maps API key
        "key": AppConstants.GOOGLE_API_KEY
      });
      // gelen tüm map datasının Distance listesine dönüştürülmesi
      return Distance.fromMultiMap(data);
    } on DioError catch (e) {
      // API isteği sırasında çıkan hatalar için geriye döndürülen mesaj
      throw Exception("Google Maps API tarafında hata var! Hata:${e.message}");
    } on Exception catch (e) {
      // Diğer türlü throw edilen hatalar için geriye döndürülen mesaj
      Get.printError(info: e.toString());
      return null;
    }
  }
}
