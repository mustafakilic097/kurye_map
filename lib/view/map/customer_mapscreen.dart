import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/viewmodel/kurye_view_model.dart';
import '../../core/model/person/customer.dart';
import '../../core/model/person/kurye.dart';
import '../../core/model/map/directions_model.dart';
import '../../core/viewmodel/directions_view_model.dart';

class CustomerMapScreenPage extends ConsumerStatefulWidget {
  final CameraPosition? baslangicPosition;
  final Customer customer;
  final String? takipId;
  const CustomerMapScreenPage({Key? key, this.baslangicPosition, required this.customer, this.takipId})
      : super(key: key);

  @override
  ConsumerState<CustomerMapScreenPage> createState() => _CustomerMapScreenPageState();
}

class _CustomerMapScreenPageState extends ConsumerState<CustomerMapScreenPage> with SingleTickerProviderStateMixin {
  late GoogleMapController _googleMapController;
  var _initialCameraPosition = const CameraPosition(target: LatLng(36.8910682, 30.6391693), zoom: 15.5);
  late AnimationController animationController;
  List<Marker> kuryelerMarker = [];
  Marker? _baslangic;
  Marker? _hedef;
  Directions? _info;
  var kuryeIcon;
  Position? currentposition;

  LatLng? currentTakipPosition;
  Marker? takipMarker;
  bool longPressEnable = false;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    getBytesFromAsset('assets/kurye.png', 128).then((onValue) {
      kuryeIcon = BitmapDescriptor.fromBytes(onValue);
    });
    if (widget.baslangicPosition != null) _initialCameraPosition = widget.baslangicPosition!;
    animationController = BottomSheet.createAnimationController(this);
    animationController.duration = const Duration(milliseconds: 800);
    if (widget.takipId != null) {
      //TODO burası map oluştuktan sonra çalışması gerekiyor controller için
      Future.delayed(const Duration(seconds: 3), () {
        loadTakipPosition(widget.takipId!);
        currentTakipPosition != null
            ? _googleMapController
                .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentTakipPosition!, zoom: 15)))
            : null;
      });
      timer = Timer.periodic(
        const Duration(seconds: 5),
        (t) {
          loadTakipPosition(widget.takipId!);
          currentTakipPosition != null
              ? _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(target: currentTakipPosition!, zoom: 15)))
              : null;
        },
      );
    }
    // Future.delayed(Duration(seconds: 0),() {
    //   ref.read(kuryeRepositoryprovider).aktifKuryeleriGetir(context);
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _googleMapController.dispose();
    timer.cancel();
    print("dispose edildi");
  }

  @override
  Widget build(BuildContext context) {
    final kuryeRepository = ref.watch(kuryeViewModelProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black45),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.white54, Colors.white70, Colors.white38]),
            ),
            child: const Stack(children: [
              Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Divider(
                    thickness: 2,
                    color: Colors.black45,
                    height: 2,
                  ))
            ]),
          ),
          title: Text(
            "Haritalar",
            style: GoogleFonts.roboto(color: Colors.black45, fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_baslangic != null)
              TextButton(
                  onPressed: () {
                    if (_baslangic != null) {
                      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: _baslangic!.position, zoom: 15, tilt: 50)));
                    }
                  },
                  child: const Text(
                    "Başlangıç",
                    style: TextStyle(color: Colors.black),
                  )),
            if (_hedef != null)
              TextButton(
                  onPressed: () {
                    if (_hedef != null) {
                      _googleMapController.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(target: _hedef!.position, zoom: 15, tilt: 50)));
                    }
                  },
                  child: const Text("Hedef", style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            padding: const EdgeInsets.all(20),
            markers: {
              if (_baslangic != null && longPressEnable) _baslangic!,
              if (_hedef != null && longPressEnable) _hedef!,
              if (kuryelerMarker.isNotEmpty) ...kuryelerMarker,
              if (takipMarker != null) takipMarker!
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onLongPress: longPressEnable ? _addMarker : null,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _googleMapController = controller;
              locatePosition();

              // _addKuryeMarker(kuryeRepository.aktifKurye);
            },
            polylines: _info != null && longPressEnable
                ? {
                    Polyline(
                      polylineId: const PolylineId("overview_polyline"),
                      points: _info!.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                      color: Colors.purple,
                      visible: longPressEnable,
                      width: 3,
                    )
                  }
                : Set<Polyline>.identity(),
          ),
          if (_info != null)
            Positioned(
                top: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.black45,
                      boxShadow: [BoxShadow(color: Colors.white, blurRadius: 5)]),
                  child: Text("${_info!.totalDistance},${_info!.totalDuration}, ${"walking"}"),
                )),
          kuryelerAltMenusu(kuryeRepository),
          myLocationButton(),
          addRoadButton(),
          ortalaButton()
        ],
      ),
    );
  }

  Future<void> loadTakipPosition(String id) async {
    final f = FirebaseFirestore.instance.collection("kuryeler").doc(id);
    await f.get().then((kurye) async {
      final data = kurye.data()!;
      GeoPoint konum = (data["enlemBoylam"] as GeoPoint);
      setState(() {
        currentTakipPosition = LatLng(konum.latitude, konum.longitude);
        takipMarker = Marker(
            markerId: const MarkerId("takipKurye"),
            position: currentTakipPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
            infoWindow: const InfoWindow(title: "Kurye"));
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kayıt getirilirken hata oluştu! Tekrar deneyin, hata:$e"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      Future.error("Hata var allooooo");
    });
  }

  Future<bool> checkPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
    } else {
      return true;
    }
    return true;
  }

  void locatePosition() async {
    final f = await checkPermission();
    if (f) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      LatLng latlng = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition = CameraPosition(target: latlng, zoom: 14.5);
      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      currentposition = position;
    } else {
      print("Konum bulunamıyor");
    }
  }

  Future<void> _addMarker(LatLng basilanYer) async {
    if (currentposition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şu anki konum bulunamadı.")));
      return;
    } else if (currentposition != null) {
      setState(() {
        _baslangic = Marker(
            markerId: const MarkerId("origin"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: "Başlangıç"),
            position: LatLng(currentposition!.latitude, currentposition!.longitude));
        _hedef = null;
        _info = null;
      });
      setState(() {
        _hedef = Marker(
            markerId: const MarkerId("destination"),
            infoWindow: const InfoWindow(title: "Hedef"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: basilanYer);
      });
      final directions = await DirectionsRepository().getDirections(
          baslangic: LatLng(currentposition!.latitude, currentposition!.longitude),
          hedef: _hedef!.position,
          arac: "walking");
      setState(() {
        _info = directions;
      });
      return;
    }
  }

  Future<void> _addKuryeMarker(List<Kurye> kuryeler) async {
    if (kuryeler.isNotEmpty) {
      for (var k in kuryeler) {
        if (k.enlemBoylam != null) {
          setState(() {
            kuryelerMarker.add(Marker(
                markerId: MarkerId(k.ad),
                infoWindow: InfoWindow(title: k.ad, snippet: k.arac),
                icon: kuryeIcon,
                position: k.enlemBoylam!));
          });
        }
      }
    }
    return;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Widget kuryelerAltMenusu(KuryeViewModel kuryeRepository) {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: GestureDetector(
          onVerticalDragDown: (d) {
            showModalBottomSheet(
                isScrollControlled: true,
                transitionAnimationController: animationController,
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
                    return Container(
                      height: 300,
                      color: const Color(0xFF737373),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                            color: Colors.blue.shade200),
                        child: Stack(
                          children: [
                            const Positioned(
                              top: 10,
                              right: 0,
                              left: 0,
                              child: Divider(
                                indent: 100,
                                endIndent: 100,
                                thickness: 3,
                                color: Colors.black45,
                              ),
                            ),
                            Positioned(
                                top: 20,
                                right: 0,
                                left: 0,
                                child: Center(
                                    child: Text(
                                  "Kuryeler",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ))),
                            Positioned(
                                top: 10,
                                right: 0,
                                child: IconButton(
                                    onPressed: () async {
                                      //TODO print("5 tane kurye getir");
                                      if (widget.customer.enlemBoylam != null) {
                                        await ref
                                            .read(kuryeViewModelProvider)
                                            .yakindakiAktifKuryeleriGetir(customerKonum: widget.customer.enlemBoylam!);
                                      }
                                    },
                                    icon: const Icon(Icons.refresh))),
                            Positioned.fill(
                              top: 50,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  if (kuryeRepository.yakinKuryeler.isEmpty) {
                                    return const ListTile(
                                        title: Text(
                                            "Aktif ve yakında olan hiçbir kurye bulunamadı. Belki de tatildeler 😋"));
                                  }
                                  return ListTile(
                                    onTap: () {
                                      kuryeRepository.yakinKuryeler[index].enlemBoylam != null
                                          ? _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: kuryeRepository.yakinKuryeler[index].enlemBoylam!, zoom: 15)))
                                          : null;
                                      Navigator.of(context).pop();
                                      _googleMapController
                                          .showMarkerInfoWindow(MarkerId(kuryeRepository.yakinKuryeler[index].ad));
                                    },
                                    title: Text(kuryeRepository.yakinKuryeler[index].ad),
                                    //TODO gösterilen kurye için expansion tile yap. Talep göndermek için buton koy. İsterse kurye bilgilerinden kurye konumnunu görebilsin(belki)
                                    // subtitle: aktifKuryeler[index].kuryeKonum!=null?Text("Yakınlık: ${kuryeRepository.aktifKurye[index].kuryeKonum!.totalDuration}, ${kuryeRepository.aktifKurye[index].kuryeKonum!.totalDistance}, Durum: ${kuryeRepository.aktifKurye[index].arac}"):const Text("Konum: bilinmiyor"),
                                  );
                                },
                                itemCount:
                                    kuryeRepository.yakinKuryeler.isNotEmpty ? kuryeRepository.yakinKuryeler.length : 1,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
                });
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                color: Colors.blue.shade200),
            child: Center(
              child: Column(
                children: [
                  const Divider(
                    indent: 100,
                    endIndent: 100,
                    thickness: 3,
                    color: Colors.black45,
                  ),
                  Text(
                    "Kuryeler",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget myLocationButton() {
    return Positioned(
        right: 5,
        top: 20,
        child: FloatingActionButton(
          heroTag: "cbtn-3",
          tooltip: "Benim Konumum",
          onPressed: () {
            locatePosition();
          },
          backgroundColor: Colors.black45,
          child: const Icon(Icons.my_location),
        ));
  }

  Widget addRoadButton() {
    return Positioned(
        right: 5,
        top: 80,
        child: FloatingActionButton(
          backgroundColor: Colors.black45,
          heroTag: "cbtn-2",
          tooltip: "Yol Tarifi",
          onPressed: () {
            if (!longPressEnable) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text("Yol tarifi istediğiniz yere uzun basın...")));
              setState(() {
                longPressEnable = true;
              });
            } else {
              setState(() {
                longPressEnable = false;
                _baslangic = null;
                _hedef = null;
                _info = null;
              });
            }
          },
          child: longPressEnable ? const Icon(Icons.close) : const Icon(Icons.add_location),
        ));
  }

  Widget ortalaButton() {
    return Positioned(
      top: 140,
      right: 5,
      child: FloatingActionButton(
        backgroundColor: Colors.black45,
        heroTag: "cbtn-1",
        onPressed: () {
          _info != null
              ? _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(_info!.bounds, 100.0))
              : _googleMapController.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
