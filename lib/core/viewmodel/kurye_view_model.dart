import "package:google_maps_flutter/google_maps_flutter.dart" show LatLng;
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore, GeoPoint, Query;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart' show ChangeNotifierProvider;

import '../components/mesafe_hesapla.dart';
import '../model/person/customer.dart';
import '../model/person/kurye.dart';

//OK
class KuryeViewModel extends ChangeNotifier {
  // Aktif olan tüm kuryelerin listesi
  List<Kurye> aktifKuryeler = [];
  // Müşteriye yakın olan tüm kuryelerin listesi
  List<Kurye> yakinKuryeler = [];
  // Müşteriye yakın olan tüm kuryelerin mesafelerinin listesi
  List<double> yakinMesafeler = [];

  //OK
  Future<int> tumAktifKuryeSayisi() async {
    // Tüm aktif kuryelerin sayısını döndüren istek
    return await FirebaseFirestore.instance
        .collection("kuryeler")
        .where("aktifMi", isEqualTo: true)
        .count()
        .get()
        .then((value) => value.count)
        .catchError((e) => e);
  }

  //OK
  Future<int> yakindakiAktifKuryeleriGetir({required LatLng customerKonum, List<String>? redIds}) async {
    int aktifKuryeSayisi = 0;
    // Firebase'de arayacağımız kurye Query'si tanumı.
    final Query<Map<String, dynamic>> kuryelerRef;
    if (redIds != null) {
      // Aktif olan ve redIds içinde bulunmayan kuryeleri getiren Query
      kuryelerRef = kuryelerRef = FirebaseFirestore.instance
          .collection("kuryeler")
          .where("aktifMi", isEqualTo: true)
          .where("uid", whereNotIn: redIds);
    } else {
      // Aktif olan tüm kuryeleri getiren Query
      kuryelerRef = kuryelerRef = FirebaseFirestore.instance.collection("kuryeler").where("aktifMi", isEqualTo: true);
    }
    // Bu koşullara göre veritabanına istek gönderiliyor.
    final a = await kuryelerRef.get().then((value) async {
      //Yakındaki kuryeler için eski veriler sıfırlanıyor.
      yakinKuryeler.clear();
      yakinMesafeler.clear();
      // gelen verinin Kurye formatında listeye çevirilimesi işlemi
      final List<Kurye> kuryelerList = value.docs.map((e) => Kurye.fromMap(e.data())).toList();
      // Sahte kurye ve mesafe listeleri açıyoruz.
      List<Kurye> resultKuryeler = [];
      List<double> resultMesafeler = [];
      // Bu listeye gelen kurye listesindeki verilerden mesafesine göre filtreleme yapıyoruz
      for (var kurye in kuryelerList) {
        // Kuryeler arasında konum bilgisi ekli olmayanları işleme almıyoruz.
        if (kurye.enlemBoylam != null) {
          // Burada iki enlem boylam bilgisi verilerek Km bilgisini hesaplıyoruz
          var mesafe = MesafeMetrik.mesafeKmHesaplama(customerKonum, kurye.enlemBoylam!);
          // 20 km'ye kadar yakında olan tüm kuryeleri sahte listemize ekliyoruz.
          // Eklediğimiz kadar aktifKuryeSayisi'nı arttırıyoruz.
          if (mesafe < 20) {
            aktifKuryeSayisi++;
            resultKuryeler.add(kurye);
            resultMesafeler.add(mesafe);
          }
        }
      }
      // gelen sahte listeyi önce sıralayıp sonra orjinal global değişken olan yakinKuryeler, yakinMesafeler'e ekliyoruz.
      mesafeKuryeSirala(resultKuryeler, resultMesafeler);
      return Future.value(aktifKuryeSayisi);
    }).catchError((e) {
      //Bir hata alınırsa geriye döndürülecek mesaj
      throw Exception("Kuryeler getirilirken bir sorun oluştu. hata:$e");
    });
    return a;
  }

  //OK
  Future<void> mesafeKuryeSirala(List<Kurye> resultKuryeler, List<double> resultMesafeler) async {
    var itemMoved = false;
    do {
      itemMoved = false;
      for (int i = 0; i < resultKuryeler.length - 1; i++) {
        if (resultMesafeler[i] > resultMesafeler[i + 1]) {
          //i=0->1000m i=1->500m
          var lowerValue = resultMesafeler[i + 1]; //lowerValue = 500m
          resultMesafeler[i + 1] = resultMesafeler[i]; //i=1->1000m
          resultMesafeler[i] = lowerValue; //i=0->500m
          itemMoved = true;

          //i=0->Ahmet(1000m) i=1->Gökhan(500m)
          var lowerKurye = resultKuryeler[i + 1]; //lowerKurye = Gökhan(500m)
          resultKuryeler[i + 1] = resultKuryeler[i]; // Gökhan(500m) -> Ahmet(1000m)
          resultKuryeler[i] = lowerKurye; // Ahmet(1000m) -> Gökhan(500m)
        }
      }
    } while (itemMoved);
    yakinKuryeler = resultKuryeler.length > 5 ? resultKuryeler.getRange(0, 5).toList() : resultKuryeler;
    yakinMesafeler = resultMesafeler.length > 5 ? resultMesafeler.getRange(0, 5).toList() : resultMesafeler;
    notifyListeners();
  }

  //OK
  Future<void> aktifKuryeleriGetir() async {
    // Aktif olan tüm kuryeleri getiren Query
    final kuryelerRef = FirebaseFirestore.instance.collection("kuryeler").where({"aktifMi": true});
    // girilen Query için veritabanına istek gönderilmesi
    await kuryelerRef.get().then((value) {
      // gelen verilerin kurye listesine dönüştürülmesi
      final kuryelerList = value.docs.map((e) => Kurye.fromMap(e.data())).toList();
      // aktifKuryeler listesine bu listenin eklenmesi
      aktifKuryeler.clear();
      aktifKuryeler.addAll(kuryelerList);
      notifyListeners();
    }).catchError((e) {
      // Hata alınması durumunda döndürülen mesaj
      throw Exception("Aktif olan kurye bilgileri getirilirken bir sorun oluştu. Hata:$e");
    });
  }

  //OK
  Future<bool> kuryeAktiflestir(String kuryeId) async {
    // Verilen id'ye göre veritabanındaki kuryeyi arayan Query
    final kuryeRef = FirebaseFirestore.instance.collection("kuryeler").doc(kuryeId);
    // Girilen query için veritabınına aktifMi alanına true gönderen update isteği.
    // Eğer update işlemi yapılırken hata olursa false dönerek aktifleşmediğinin bilgisini iletir
    return await kuryeRef.update({"aktifMi": true}).then((v) => true).catchError((e) => false);
  }

  //OK
  Future<bool> kuryePasiflestir(String kuryeId) async {
    // Verilen id'ye göre veritabanındaki kuryeyi arayan Query
    final kuryeRef = FirebaseFirestore.instance.collection("kuryeler").doc(kuryeId);
    // Girilen query için veritabınına aktifMi alanına true gönderen update isteği
    // Eğer update işlemi yapılırken hata olursa false dönerek aktifleşmediğinin bilgisini iletir
    return await kuryeRef.update({"aktifMi": false}).then((v) => true).catchError((e) => false);
  }

  //OK
  Future<bool> kuryeKonumGuncelle({required String kuryeId, required LatLng kuryeKonum}) async {
    // Verilen id'ye göre veritabanındaki kuryeyi arayan Query
    final kuryeRef = FirebaseFirestore.instance.collection("kuryeler").doc(kuryeId);
    // Verilen enlem boylam bilgisini firebase'de saklamak için GeoPoint'e çevirme işlemi
    final kuryeGeoPoint = GeoPoint(kuryeKonum.latitude, kuryeKonum.longitude);
    // Girilen Query için veritabınındaki enlemBoylam bilgisini update isteğiyle değiştirme
    // Eğer update işlemi yapılırken hata olursa false dönerek konumun değişmediğinin bilgisini iletir
    return await kuryeRef.update({"enlemBoylam": kuryeGeoPoint}).then((v) => true).catchError((e) => false);
  }

  Future<String>? siparisBildirimYazisiOlustur({required Kurye kurye, required Customer customer}) async {
    Future<String> result = Future<String>.value("Birazdan ordayım kardeşim");
    //kurye konumunu buldur ve onun için bir sipariş yazısı oluştur
    // if(kurye.kuryeKonum!=null){
    //   result = Future<String>.value("Kurye yolda. Yaklaşık olarak ${kurye.kuryeKonum!.totalDuration} içerisinde adresinizde olacaktır.");
    //   return result;
    // }
    // else{
    //   var k = DistanceRepository().getDistance(baslangic: customer.enlemVeBoylam!, hedef: kurye.enlemVeBoylam!, arac: kurye.arac);
    //   var m = k.then((value){
    //     result = Future<String>.value("Kurye yolda. Yaklaşık olarak ${kurye.kuryeKonum!.totalDuration} içerisinde adresinizde olacaktır.");
    //     return result;
    //   });
    //   return m;
    // }
    return result;
  }
}

final kuryeViewModelProvider = ChangeNotifierProvider(
  (ref) => KuryeViewModel(),
);
