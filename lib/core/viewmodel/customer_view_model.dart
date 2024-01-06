import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore, GeoPoint;
import 'package:flutter/material.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart' show ChangeNotifierProvider;
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../constants/enum/kurye_arac_enum.dart';
import '../init/auth/auth.dart';
import '../model/map/distance_model.dart';
import '../model/person/customer.dart';
import '../model/person/kurye.dart';
import 'distance_view_model.dart';

//OK
class CustomerViewModel extends ChangeNotifier {
  Customer _currentCustomer = Customer.blank;
  Customer get currentCustomer => _currentCustomer;

  //OK => Müşteri bilgilerinin database'den getirilmesini sağlar
  Future<Customer> getCustomer() async {
    // Firebase'de Auth() servisinden gelen kullanıcı id'sine göre musteri bilgilerini getirme
    final customerRef = FirebaseFirestore.instance.collection("musteriler").doc(Auth().currentUser?.uid ?? "-1");
    // Veritabanına isteğin gönderilmesi
    await customerRef.get().then((customer) async {
      // Gelen data boşsa hata döndürür
      if (customer.data() == null) {
        throw Exception("Kullanıcı getirilemedi!!");
      }
      // Gelen datayı Customer sınıfına çevirme ve bunu currentCustomer'a atma
      _currentCustomer = Customer.fromMap(customer.data()!);
    });
    notifyListeners();
    return currentCustomer;
  }

  //OK => Müşterinin konum bilgisinin güncellenmesini sağlar
  Future<bool> customerLocationUpdate({required LatLng customerLoc}) async {
    // Firebase'de Auth() servisinden gelen kullanıcı id'sine göre musteri bilgilerinin referansı
    final customerRef = FirebaseFirestore.instance.collection("musteriler").doc(Auth().currentUser?.uid ?? "-1");
    // Gelen konum bilgisini Firebase'e atmak için GeoPoint türüne çeviriyoruz
    final customerGeoPoint = GeoPoint(customerLoc.latitude, customerLoc.longitude);
    // Tanımlanan referansa ait database'de müşterinin enlemBoylam bilgisinin güncellenmesi isteği
    // Başarılı olursa true hata olursa false döner
    return await customerRef.update({"enlemBoylam": customerGeoPoint}).then((value) => true).catchError((e) => false);
  }

  //OK => Verilen müşteri konumu ile kurye listesinin yakınlık durumunu API'dan alır ve buna göre sıralar
  Future<List<Kurye>?> tumKuryeYakinlikHesapla({required LatLng customerLoc, required List<Kurye> kuryeler}) async {
    // İnternet bağlantı durumu
    bool con = await InternetConnectionChecker().hasConnection;
    // İnternet bağlantısı yoksa döndürülen hata
    if (!con) {
      throw Exception("İnternet bağlantısı yok !");
    }
    // Verilen tüm kuryelerin müşteriye olan uzaklığının detayları için API servisine istek gönderen method
    await DistanceViewModel.getMultiDistance(baslangic: customerLoc, kuryeler: kuryeler, arac: KuryeArac.DRIVING)
        .then((List<Distance>? distanceList) {
      // Gelen yakınlık bilgisi boş dönerse bu bloktan çık
      if (distanceList == null) return null;
      if (distanceList.isEmpty) return null;

      // Gelen yakınlık bilgisi ile kuryeleri sıralama algoritması
      var itemMoved = false;
      do {
        itemMoved = false;
        for (int i = 0; i < distanceList.length - 1; i++) {
          if (distanceList[i].totalDistanceValue > distanceList[i + 1].totalDistanceValue) {
            //i=0->1000m i=1->500m
            var lowerValue = distanceList[i + 1]; //lowerValue = 500m
            distanceList[i + 1] = distanceList[i]; //i=1->1000m
            distanceList[i] = lowerValue; //i=0->500m
            itemMoved = true;

            //i=0->Ahmet(1000m) i=1->Gökhan(500m)
            var lowerKurye = kuryeler[i + 1]; //lowerKurye = Gökhan(500m)
            kuryeler[i + 1] = kuryeler[i]; // Gökhan(500m) -> Ahmet(1000m)
            kuryeler[i] = lowerKurye; // Ahmet(1000m) -> Gökhan(500m)
          }
        }
      } while (itemMoved);
    });
    // İşleme giren kuryeleri tekrardan geriye döndürür
    return kuryeler;
  }
}

final customerViewModelProvider = ChangeNotifierProvider(
  (ref) => CustomerViewModel(),
);
