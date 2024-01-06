import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<String> getLocationInfo(LatLng konum) async {
  final String _baseUrl = "https://nominatim.openstreetmap.org/reverse";

  final response = await Dio().get(
      _baseUrl,
      queryParameters: {
        "lat":konum.latitude,
        "lon":konum.longitude,
        "format":"jsonv2"
      }
  );
  if(response.statusCode==200){
    return response.data["display_name"].toString();
  }
  return "adres getirilemedi";
}