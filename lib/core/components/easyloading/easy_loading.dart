import 'dart:async';

import 'package:flutter/material.dart';

class EasyLoading {
  EasyLoading(context) {
    dialogContext = context;
  }
  // static late DialogRoute? route;
  late BuildContext dialogContext;

  Future<void> buildLoading() async {
    // route = DialogRoute(
    //     context: dialogContext,
    //     builder: (_) => Dialog(
    //           clipBehavior: Clip.hardEdge,
    //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //           child: const SizedBox(
    //             height: 100,
    //             child: Stack(
    //               children: [
    //                 Positioned.fill(
    //                     child: LinearProgressIndicator(
    //                   color: Colors.white,
    //                   backgroundColor: Color.fromRGBO(250, 250, 250, 1),
    //                 )),
    //                 Padding(
    //                   padding: EdgeInsets.all(25),
    //                   child: Center(child: Text("Yükleniyor...")),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //     barrierDismissible: false);
    // if (route != null) {
    //   await Navigator.of(dialogContext).push(route!);
    // }
    // print("build ediliyor..");
    // showDialog<void>(
    //   context: dialogContext,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     dialogContext = context;
    //     return const AlertDialog(
    //       content: Center(child: CircularProgressIndicator()),
    //     );
    //   },
    // );
  }

  void closeLoading() {
    try {
      // if (route == null) {
      //   print("Route boş");
      // }
      // if (route != null) {
      //   Navigator.of(dialogContext).removeRoute(route!);
      //   route = null;
      // }
      // Navigator.of(dialogContext).pop();
    } catch (e) {
      print(e);
    }
  }

  // static Future<Object?> showLoading(BuildContext context) async {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return const Dialog.fullscreen(
  //         child: Center(
  //           child: CircularProgressIndicator(),
  //         ),
  //       );
  //     },
  //   );
  // }

  // static void closeLoading(context) {
  //   Navigator.of(context, rootNavigator: true).pop();
  // }
}
