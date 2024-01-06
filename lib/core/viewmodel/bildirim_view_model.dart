import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/bildirim.dart';
import '../model/person/customer.dart';

class BildirimRepository extends ChangeNotifier{
  List<Bildirim> kuryeBildirimler = [];
  List<Bildirim> customerBildirimler = [];

  Future<void> kuryeBildirimPasifle({required String uid,required int bildirimIndex}) async {
    final f = FirebaseFirestore.instance.collection("bildirimler");
    final a = await f.where("aliciId",isEqualTo: uid).where("bildirimAktif",isEqualTo: true).get();
    a.docs[bildirimIndex].reference.update({"bildirimAktif": false});
  }

  Future<bool> bildirimGonder(Bildirim bildirim,context) async {
    final f = FirebaseFirestore.instance.collection("bildirimler");
    final data = bildirim.toMap();
    final result = f.add(data)
    .then((value) => true)
    .catchError((e) {
      f.add(data)
      .then((value) => true)
      .catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bildirim gönderilemedi. İnternetini kontrol eder misin?"),backgroundColor: Colors.amber,));
        return false;
      });
      return false;
    });
    return result;
  }

  Future<void> kuryeTalepIptalBildirimiGonder({required String gonderenId, required String aliciId,context}) async {
    final f = FirebaseFirestore.instance.collection("bildirimler");
    final data = Bildirim(gonderenId: gonderenId, aliciId: aliciId, gonderenRol: "system", aliciRol: "musteri", bildirimIcerik: "Yakınında kurye bulunamadı ya da tüm kuryeler bunu iptal etti.", bildirimAktif: true, gonderenKonum: const LatLng(0, 0)).toMap();
    f.add(data)
    .then((value) => null)
    .catchError((e) {
      f.add(data)
      .then((value) => null)
      .catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bildirim gönderilemedi. İnternetini kontrol eder misin?"),backgroundColor: Colors.amber,));
      });
    });
  }

  Future<int> kuryeBildirimlerGetir(String kuryeId) async {
    kuryeBildirimler.clear();
    notifyListeners();
    final f = FirebaseFirestore.instance.collection("bildirimler");
    final a = await f
    .where("bildirimAktif",isEqualTo: true)
    .where("aliciId",isEqualTo: kuryeId)
    .get()
    .then((value) {
      final data = value.docs.map((e) => Bildirim.fromMap(e.data())).toList();
      kuryeBildirimler = data;
      notifyListeners();
      return data.length;
    })
    .catchError((e) {print("hata var aloo hata:$e");return 0;});
    return a;
  }

  bool customerBildirimVarmi(Customer customer){
    // bool result = false;
    // if(customerBildirimler.length<=0) return false;
    // for(var kb in customerBildirimler){
    //   if(kb.customerId==customer.uid) {
    //     result = true;
    //     break;
    //   }
    // }
    // return result;
    return false;
  }

  Future<int> customerBildirimlerGetir(String customerId) async {
    customerBildirimler.clear();
    notifyListeners();
    final f = FirebaseFirestore.instance.collection("bildirimler");
    final a = await f
        .where("bildirimAktif",isEqualTo: true)
        .where("aliciId",isEqualTo: customerId)
        .get()
    .then((value) {
      final data = value.docs.map((e) => Bildirim.fromMap(e.data())).toList();
      customerBildirimler = data;
      notifyListeners();
      return data.length;
    })
    .catchError((e) {print("hata var aloo hata:$e");return 0;});
    return a;
  }
}

final bildirimprovider = ChangeNotifierProvider((ref) => BildirimRepository());