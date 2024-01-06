import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kurye_map/view/auth/register_screen.dart';

import '../../core/base/state/base_state.dart';
import '../../core/components/easyloading/easy_loading.dart';
import '../home/customer_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseState<LoginScreen> {
  late TextEditingController eposta;
  late TextEditingController sifre;
  late String userUid;
  bool kuryeMi = false;
  @override
  void initState() {
    eposta = TextEditingController();
    sifre = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    eposta.dispose();
    sifre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          height: 175,
          color: const Color.fromRGBO(245, 255, 250, 1),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                Text("Hoşgeldin!",
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold, color: Color.fromRGBO(141, 181, 150, 1)))),
              ],
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "E-Posta",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                          width: 250,
                          height: 40,
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, bottom: 1),
                                child: TextField(
                                    controller: eposta,
                                    decoration:
                                        const InputDecoration(hintText: "ornek@example.com", border: InputBorder.none)),
                              ))),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Şifre",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                          width: 250,
                          height: 40,
                          child: DecoratedBox(
                              decoration: const BoxDecoration(
                                  color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, bottom: 1),
                                child: TextField(
                                    controller: sifre,
                                    decoration: const InputDecoration(
                                        hintText: "*************",
                                        border: InputBorder.none,
                                        labelStyle: TextStyle(fontWeight: FontWeight.bold))),
                              ))),
                      Padding(
                        padding: const EdgeInsets.only(left: 130, top: 8),
                        child: TextButton(
                            onPressed: () {
                              print("şifremi unuttum");
                            },
                            child: const Text("Şifremi unuttum",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(height: 75),
                      SizedBox(
                        height: 35,
                        width: 120,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(146, 129, 122, 1),
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          child: MaterialButton(
                            splashColor: Colors.indigo,
                            onPressed: () async {
                              // await EasyLoading.buildLoading(context);
                              // await Future.delayed(
                              //   const Duration(seconds: 5),
                              //   () {
                              //     EasyLoading.closeLoading();
                              //   },
                              // );
                              await kayitKontrol().then((bool f) async {
                                if (!f) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text("Kayıt getirilemedi! Tekrar deneyin"),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                  EasyLoading(context).closeLoading();
                                  return;
                                }
                                //Burada hangi ekrana gideceğini değiştirerek paneller arası geçiş yapılabilir
                                EasyLoading(context).closeLoading();
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomerScreen(),
                                    ));
                                // if (f) {
                                //   final users = [
                                //     FirebaseFirestore.instance.collection("musteriler").doc(userUid),
                                //     FirebaseFirestore.instance.collection("kuryeler").doc(userUid)
                                //   ];
                                //   for (var user in users) {
                                //     await user.get().then((a) async {
                                //       final userData = a.data();
                                //       if (userData != null) {
                                //         await EasyLoading.dismiss().then((value) async {
                                //           if (userData["rol"] == "kurye") {
                                //             await Navigator.pushReplacement(
                                //                 context,
                                //                 MaterialPageRoute(
                                //                   builder: (context) => KuryeScreen(
                                //                     uid: userUid,
                                //                   ),
                                //                 ));
                                //           } else {
                                //             await Navigator.pushReplacement(
                                //                 context,
                                //                 MaterialPageRoute(
                                //                   builder: (context) => CustomerScreen(uid: userUid),
                                //                 ));
                                //           }
                                //         });
                                //       }
                                //     }).catchError((e) async {
                                //       await EasyLoading.dismiss();
                                //       await Navigator.of(context).pushReplacement(
                                //           MaterialPageRoute(builder: (context) => const LoginScreen()));
                                //     });
                                //   }
                                // } else {
                                //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                //     content: Text("Kayıt getirilemedi! Tekrar deneyin"),
                                //     backgroundColor: Colors.orange,
                                //     behavior: SnackBarBehavior.floating,
                                //   ));
                                // }
                              }).catchError((e) async {
                                EasyLoading(context).closeLoading();
                              });
                            },
                            child: Text(
                              "Giriş Yap",
                              style: GoogleFonts.merriweatherSans(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 35,
                          width: 100,
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(112, 112, 112, 1),
                                borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: MaterialButton(
                              splashColor: Colors.indigo,
                              onPressed: () async {
                                await Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
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
    ));
  }

  Future<bool> kayitKontrol() async {
    final result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: eposta.text, password: sifre.text)
        .catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Hata:$e"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      return e;
    }).then((UserCredential user) {
      setState(() {
        userUid = user.user!.uid;
      });
      if (user.user != null) {
        return true;
      } else {
        return false;
      }
    });
    return result;
  }
}
