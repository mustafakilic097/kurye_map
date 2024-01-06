import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kurye_map/view/auth/login_screen.dart';

import '../../core/components/easyloading/easy_loading.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController ad = TextEditingController();

  TextEditingController soyad = TextEditingController();

  TextEditingController telefon = TextEditingController();

  TextEditingController eposta = TextEditingController();

  TextEditingController parola = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 75,
            width: double.infinity,
            color: const Color.fromRGBO(245, 255, 250, 1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Kaydol",
                  style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold, color: Color.fromRGBO(141, 181, 150, 1))),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromRGBO(141, 181, 150, 1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 75,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Ad",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                          height: 40,
                                          child: DecoratedBox(
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 10, bottom: 5),
                                                child: TextField(
                                                    controller: ad,
                                                    decoration: const InputDecoration(border: InputBorder.none)),
                                              ))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          "Soyad",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                          height: 40,
                                          child: DecoratedBox(
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 10, bottom: 5),
                                                child: TextField(
                                                    controller: soyad,
                                                    decoration: const InputDecoration(border: InputBorder.none)),
                                              ))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Telefon Numarası",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                                width: 225,
                                height: 40,
                                child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, bottom: 1),
                                      child: TextField(
                                          controller: telefon,
                                          decoration: const InputDecoration(
                                            hintText: "05__ ___ __ __",
                                            border: InputBorder.none,
                                          )),
                                    ))),
                          ],
                        ),
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "E-posta",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                                width: 225,
                                height: 40,
                                child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, bottom: 1),
                                      child: TextField(
                                          controller: eposta,
                                          decoration: const InputDecoration(
                                              hintText: "ornek@gmail.com",
                                              border: InputBorder.none,
                                              labelStyle: TextStyle(fontWeight: FontWeight.bold))),
                                    ))),
                          ],
                        ),
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Parola belirleyin",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                                width: 225,
                                height: 40,
                                child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                        color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, bottom: 1),
                                      child: TextField(
                                          controller: parola,
                                          decoration: const InputDecoration(
                                              hintText: "*************",
                                              border: InputBorder.none,
                                              labelStyle: TextStyle(fontWeight: FontWeight.bold))),
                                    ))),
                          ],
                        ),
                        const Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Parolayı tekrar girin",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(
                                width: 225,
                                height: 40,
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10, bottom: 1),
                                      child: TextField(
                                          decoration: InputDecoration(
                                              hintText: "*************",
                                              border: InputBorder.none,
                                              labelStyle: TextStyle(fontWeight: FontWeight.bold))),
                                    ))),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0, left: 8, right: 8, bottom: 8),
                          child: SizedBox(
                            height: 35,
                            width: 200,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Color.fromRGBO(146, 129, 122, 1),
                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                              child: MaterialButton(
                                splashColor: Colors.indigo,
                                onPressed: () async {
                                  await EasyLoading(context).buildLoading();
                                  await registerUser(context).then((value) async {
                                    EasyLoading(context).closeLoading();
                                  }).catchError((e) async {
                                    EasyLoading(context).closeLoading();
                                  });

                                  // if(ad.text!=null&&soyad.text!=null&&telefon.text!=null&&eposta!=null&&parola!=null) {
                                  //
                                  // }
                                  // else{
                                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Değerleri kontrol ederek tekrar deneyin!")));
                                  // }
                                },
                                child: Text(
                                  "Kaydol",
                                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> registerUser(context) async {
    return await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: eposta.text, password: parola.text)
        .catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kayıt oluşturulurken hata oluştu! Tekrar deneyin, hata:$e"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return e;
    }).then((m) {
      final musteriler = FirebaseFirestore.instance.collection("musteriler").doc(m.user!.uid);
      final musteri = {
        "uid": m.user!.uid,
        "ad": ad.text,
        "soyad": soyad.text,
        "telefon": telefon.text,
        "eposta": eposta.text,
        "parola": parola.text,
        "rol": "musteri"
      };
      return musteriler.set(musteri, SetOptions(merge: true)).then((value) async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Kayıt başarıyla gerçekleştirildi"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Kayıt oluşturulurken hata oluştu! Tekrar deneyin, hata:$error"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ));
      });
    });
    //Burayı doğrulama ekranına atıp ordan doğruladıktan sonra auth'ada eklendilkten sonra üyeliği tamamlama işlemi yapabilriz.
  }
}
