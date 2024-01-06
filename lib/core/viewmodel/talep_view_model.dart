import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/talep.dart';

import '../model/person/customer.dart';
import '../model/person/kurye.dart';

class TalepRepository extends ChangeNotifier {
  List<Talep> talepler = [];

  Future<void> talepEkle(Talep talep, context) async {
    final f = FirebaseFirestore.instance.collection("talepler");
    await f
        .add(talep.toMap())
        .then((value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Talep Eklendi ✔"),
              backgroundColor: Colors.green,
            )))
        .catchError((e) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Talep Eklenemedi. İnternet Bağlantınızı kontrol edin! 😕"),
            backgroundColor: Colors.orange)));
  }

  Future<void> kuryeTalepPasifle(String uid, context, talepIndex) async {
    try {
      final f = FirebaseFirestore.instance.collection("talepler");
      final a = await f.where("kuryeId", isEqualTo: uid).get();
      a.docs[talepIndex].reference.update({"talepAktif": false});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Talepler bitirilemedi. İnternetinizi kontrol edip tekrar deneyin."),
        backgroundColor: Colors.orange,
      ));
    }
  }

  Future<void> kuryeTumTalepleriPasifle(String uid, context) async {
    try {
      final f = FirebaseFirestore.instance.collection("talepler");
      final a = await f.where("kuryeId", isEqualTo: uid).get();
      for (int i = 0; i < a.docs.length; i++) {
        a.docs[i].reference.set({"talepAktif": false}, SetOptions(merge: true));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Talepler bitirilemedi. İnternetinizi kontrol edip tekrar deneyin."),
        backgroundColor: Colors.orange,
      ));
    }
  }

  Future<int> kuryeAktifTalepleriGetir({required String kuryeId}) async {
    talepler.clear();
    notifyListeners();
    final f = FirebaseFirestore.instance.collection("talepler");
    final a = await f.where("talepAktif", isEqualTo: true).where("kuryeId", isEqualTo: kuryeId).get().then((value) {
      final data = value.docs.map((e) => Talep.fromMap(e.data())).toList();
      talepler = data;
      notifyListeners();
      return data.length;
    }).catchError((e) {
      print("hata var aloo hata1:$e");
      return 0;
    });
    return a;
  }

  Future<int> customerAktifTalepleriGetir({required String customerId}) async {
    talepler.clear();
    notifyListeners();
    final f = FirebaseFirestore.instance.collection("talepler");
    final a =
        await f.where("talepAktif", isEqualTo: true).where("customerId", isEqualTo: customerId).get().then((value) {
      final data = value.docs.map((e) => Talep.fromMap(e.data())).toList();
      talepler = data;
      notifyListeners();
      return data.length;
    }).catchError((e) {
      print("hata var aloo hata2:$e");
      return 0;
    });
    return a;
  }

  bool kuryeAktifTalepVarMi(Kurye kurye) {
    bool result = false;
    for (var s in talepler) {
      if (s.kuryeId == kurye.uid) {
        if (s.talepAktif == true) {
          result = true;
          break;
        }
      }
    }
    return result;
  }

  bool customerAktifTalepVarMi(Customer customer) {
    bool result = false;
    for (var s in talepler) {
      if (s.customerId == customer.uid) {
        if (s.talepAktif == true) {
          result = true;
          break;
        }
      }
    }
    return result;
  }

  void talepDurumGuncelle(String talepId, String durum) {
    // for(var s in talepler){
    //   if(s.talepId==talepId){
    //     s.talepDurum = durum;
    //     notifyListeners();
    //     return;
    //   }
    // }
  }
}

final talepprovider = ChangeNotifierProvider((ref) => TalepRepository());
