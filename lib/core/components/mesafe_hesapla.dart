import "dart:math" as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MesafeMetrik {
  static double mesafeKmHesaplama(LatLng baslangic, LatLng hedef) {
    var theta = baslangic.longitude - hedef.longitude;
    var distance = 60 *
        1.1515 *
        (180 / math.pi) *
        math.acos(math.sin(baslangic.latitude * (math.pi / 180)) * math.sin(hedef.latitude * (math.pi / 180)) +
            math.cos(baslangic.latitude * (math.pi / 180)) *
                math.cos(hedef.latitude * (math.pi / 180)) *
                math.cos(theta * (math.pi / 180)));
    return double.parse((distance * 1.609344).toStringAsFixed(2));
  }
}
