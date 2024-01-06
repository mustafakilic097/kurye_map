import 'package:flutter/material.dart';
import '../../core/base/state/base_state.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);
  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends BaseState<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: ColoredBox(
      color: Color.fromRGBO(245, 255, 250, 1),
      child: Center(child: Icon(Icons.replay_circle_filled_sharp, size: 100, color: Colors.indigo)),
    ));
  }

  // Future<void> initializeAndForwardFirebase() async {
  //   await Firebase.initializeApp().then((value) {
  //     setState(() {
  //       isInitialized = true;
  //     });
  //     if (FirebaseAuth.instance.currentUser != null && uid != "-1") {
  //       try {
  //         Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => CustomerScreen(
  //                 userId: uid,
  //               ),
  //             ));
  //         // final String id = FirebaseAuth.instance.currentUser!.uid;
  //         // final users = [
  //         //   FirebaseFirestore.instance.collection("musteriler").doc(id),
  //         //   FirebaseFirestore.instance.collection("kuryeler").doc(id)
  //         // ];
  //         // for (var user in users) {
  //         //   await user.get().then((a) async {
  //         //     final userData = a.data();
  //         //     if (userData != null) {
  //         //       if (userData["rol"] == "kurye") {
  //         //         await Navigator.pushReplacement(
  //         //             context,
  //         //             MaterialPageRoute(
  //         //               builder: (context) => KuryeScreen(
  //         //                 uid: id,
  //         //               ),
  //         //             ));
  //         //       } else {
  //         //         await Navigator.pushReplacement(
  //         //             context,
  //         //             MaterialPageRoute(
  //         //               builder: (context) => CustomerScreen(uid: id),
  //         //             ));
  //         //       }
  //         //     }
  //         //   }).catchError((e) async {
  //         //     ScaffoldMessenger.of(context).clearSnackBars();
  //         //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         //       content: Text("Kayıt getirilirken hata oluştu! Tekrar deneyin, hata:$e"),
  //         //       backgroundColor: Colors.orange,
  //         //       behavior: SnackBarBehavior.floating,
  //         //     ));
  //         //     Navigator.of(context).pushReplacement(MaterialPageRoute(
  //         //         builder: (context) => const RetryScreen(
  //         //               routeWidget: LoadingScreen(),
  //         //             )));
  //         //   });
  //         // }
  //       } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text("Kayıt getirilirken hata oluştu! Tekrar deneyin, hata:$e"),
  //           backgroundColor: Colors.orange,
  //           behavior: SnackBarBehavior.floating,
  //         ));
  //         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
  //       }
  //     } else {
  //       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
  //     }
  //   });
  // }
}
