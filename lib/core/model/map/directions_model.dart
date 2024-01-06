import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions{
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  Directions({required this.bounds,required this.polylinePoints,required this.totalDistance,required this.totalDuration});

  static Directions? fromMap(Map<String,dynamic> map){
    //Rota var mı yokmu
    if((map["routes"] as List).isEmpty) return null;

    //İlk rotayı al
    final data =Map<String,dynamic>.from(map["routes"][0]);

    //Sınırları al
    final northeast = data["bounds"]["northeast"];
    final southwest = data["bounds"]["southwest"];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest["lat"],southwest["lng"]),
      northeast: LatLng(northeast["lat"],northeast["lng"])
    );

    //mesafe ve zamanı al
    String distance = "";
    String duration = "";
    if((data["legs"] as List).isNotEmpty){
      final legs = data["legs"][0];
      distance = legs["distance"]["text"];
      duration = legs["duration"]["text"];
    }
    return Directions(
      bounds: bounds,
      polylinePoints: PolylinePoints().decodePolyline(data["overview_polyline"]["points"]),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}