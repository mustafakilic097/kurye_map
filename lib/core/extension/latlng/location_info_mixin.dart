import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/constants/app/app_constants.dart';

mixin GetLocationInfo {
  Future<String> getLocationInfo(LatLng konum) async {
    String baseUrl = AppConstants.LOCATION_INFO_BASE_URL;

    final response =
        await Dio().get(baseUrl, queryParameters: {"lat": konum.latitude, "lon": konum.longitude, "format": "jsonv2"});
    if (response.statusCode == 200) {
      return response.data["display_name"].toString();
    }
    return "adres getirilemedi";
  }
}
