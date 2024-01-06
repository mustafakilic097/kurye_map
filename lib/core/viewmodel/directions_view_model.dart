import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/constants/app/app_constants.dart';

import '../model/map/directions_model.dart';

class DirectionsRepository{
  DirectionsRepository({Dio? dio}):_dio=dio ?? Dio();
  static String _baseUrl = "https://maps.googleapis.com/maps/api/directions/json?";
  final Dio _dio;

  Future<Directions?> getDirections({required LatLng baslangic,required LatLng hedef, required String arac}) async{
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${baslangic.latitude},${baslangic.longitude}',
        'destination':'${hedef.latitude},${hedef.longitude}',
        'key': AppConstants.GOOGLE_API_KEY,
        'mode':arac,
        'avoidHighways':true,
        'avoidTolls':true,
      }
      );
    if(response.statusCode==200){
      return Directions.fromMap(response.data);
    }
    return null;
  }

}