import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../map/kurye_mapscreen.dart';
import '../../core/model/person/kurye.dart';

class KuryeSettingsScreen extends StatelessWidget {
  final Kurye kurye;
  KuryeSettingsScreen({Key? key, required this.kurye}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey1,
      appBar: AppBar(
        title: const Text("Ayarlar"),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Haritalara Git"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => KuryeMapScreenPage(
                    baslangicPosition: CameraPosition(target: kurye.enlemBoylam!, zoom: 14.5), kurye: kurye),
              ));
            },
          )
        ],
      ),
    );
  }
}
