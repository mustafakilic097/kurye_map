class Distance{
  final String totalDistance;
  final double totalDistanceValue;
  final String totalDuration;
  final double totalDurationValue;
  final String originAddress;
  final String destinationAddress;

  Distance({required this.totalDistance, required this.totalDuration,required this.originAddress, required this.destinationAddress, required this.totalDistanceValue,required this.totalDurationValue});

  static Distance? fromMap(Map<String,dynamic> map){
    if(!(map["status"]=="OK")) return null;

    var distance = "";
    var duration = "";
    var originAddress = "";
    var destinationAddress = "";
    double distanceValue = double.infinity;
    double durationValue = double.infinity;
    if((map["origin_addresses"] as List).isNotEmpty){
      originAddress = map["origin_addresses"][0];
    }
    if((map["destination_addresses"] as List).isNotEmpty){
      destinationAddress = map["destination_addresses"][0];
    }
    if((map["rows"] as List).isNotEmpty){
      distance = map["rows"][0]["elements"][0]["distance"]["text"];
      duration = map["rows"][0]["elements"][0]["duration"]["text"];
      distanceValue = double.tryParse(map["rows"][0]["elements"][0]["distance"]["value"].toString())!;
      distanceValue = double.tryParse(map["rows"][0]["elements"][0]["duration"]["value"].toString())!;
    }
    return Distance(
      totalDistance: distance,
      totalDuration: duration,
      originAddress: originAddress,
      destinationAddress: destinationAddress,
      totalDistanceValue: distanceValue,
      totalDurationValue: durationValue
    );
  }

  static List<Distance>? fromMultiMap(Map<String,dynamic> map){
    if(!(map["status"]=="OK")) return null;
    int lngth = 0;
    List<String> distance = [];
    List<String> duration = [];
    List<String> originAddress = [];
    List<String> destinationAddress = [];
    List<double> distanceValue = [];
    List<double> durationValue = [];

    if((map["destination_addresses"] as List).isNotEmpty){
      for(var d in (map["destination_addresses"] as List)){
        originAddress.add(map["origin_addresses"][0]);
        destinationAddress.add(d);
      }
    }
    if((map["rows"] as List).isNotEmpty){
      var a = map["rows"][0]["elements"] as List;
      for(int i=0;i<a.length;i++){
        lngth = a.length;
        distance.add(a[i]["distance"]["text"]);
        duration.add(a[i]["duration"]["text"]);
        distanceValue.add(double.tryParse(a[i]["distance"]["value"].toString())!);
        durationValue.add(double.tryParse(a[i]["duration"]["value"].toString())!);
      }
    }
    List<Distance> result = [];
    for(int i=0;i<lngth;i++){
      result.add(Distance(totalDistance: distance[i], totalDuration: duration[i], originAddress: originAddress[i], destinationAddress: destinationAddress[i], totalDistanceValue: distanceValue[i], totalDurationValue: durationValue[i]));
    }
    return result;
  }

}