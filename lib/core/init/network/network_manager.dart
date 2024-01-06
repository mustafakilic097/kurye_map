import 'package:dio/dio.dart';

import '../../constants/app/app_constants.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._init();
  static NetworkManager get instance => _instance;
  late Dio _dio;
  NetworkManager._init() {
    _dio = Dio();
    // MARK add interceptor
  }

  Future<Map<String, dynamic>> googleMapsApiGet(Map<String, String> queryParameters) async {
    final response = await _dio.get(AppConstants.GOOGLE_MAPS_API_BASE_URL, queryParameters: queryParameters);
    if (response.statusCode != 200) throw Exception("Data getirilemedi");
    return response.data;
  }
}
