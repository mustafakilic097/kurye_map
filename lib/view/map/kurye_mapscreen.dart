import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/constants/enum/kurye_arac_enum.dart';
import 'package:kurye_map/core/viewmodel/bildirim_view_model.dart';
import 'package:kurye_map/core/viewmodel/kurye_view_model.dart';
import 'package:kurye_map/core/viewmodel/talep_view_model.dart';
import '../../core/model/person/customer.dart';
import '../../core/model/person/kurye.dart';
import '../../core/model/talep.dart';
import '../../core/model/map/directions_model.dart';
import '../../core/viewmodel/directions_view_model.dart';
import '../../core/model/map/distance_model.dart';
import '../../core/viewmodel/distance_view_model.dart';

class KuryeMapScreenPage extends ConsumerStatefulWidget {
  final CameraPosition? baslangicPosition;
  final Kurye? kurye;

  const KuryeMapScreenPage({Key? key, this.baslangicPosition, this.kurye}) : super(key: key);

  @override
  ConsumerState<KuryeMapScreenPage> createState() => _KuryeMapScreenPageState();
}

class _KuryeMapScreenPageState extends ConsumerState<KuryeMapScreenPage> with SingleTickerProviderStateMixin {
  var _initialCameraPosition = const CameraPosition(target: LatLng(36.8910682, 30.6391693), zoom: 15.5);
  late GoogleMapController _googleMapController;
  late AnimationController animationController = BottomSheet.createAnimationController(this);
  List<Talep> aktifSiparisler = [];
  List<Marker> customersMarker = [];
  Position? currentposition;
  Marker? _baslangic;
  var customerIcon;
  Marker? _hedef;
  Directions? _info;
  bool isLoad = true;
  bool trafficMode = false;
  bool longPressEnable = false;

  @override
  void initState() {
    super.initState();
    getBytesFromAsset('assets/customer.png', 175).then((onValue) {
      customerIcon = BitmapDescriptor.fromBytes(onValue);
    });
    if (widget.baslangicPosition != null) _initialCameraPosition = widget.baslangicPosition!;
    animationController.duration = const Duration(milliseconds: 800);
  }

  @override
  void dispose() {
    super.dispose();
    _googleMapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final customerRepository = ref.watch(customerRepositoryprovider);
    final talepRepository = ref.watch(talepprovider);
    final bildirimRepository = ref.watch(bildirimprovider);
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
            "Kurye Harita",
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
            trafficEnabled: trafficMode,
            padding: const EdgeInsets.all(20),
            markers: {
              if (_baslangic != null && longPressEnable) _baslangic!,
              if (_hedef != null && longPressEnable) _hedef!,
              if (customersMarker.isNotEmpty) ...customersMarker
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onLongPress: longPressEnable ? _addMarker : null,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _googleMapController = controller;
              locatePosition();
              aktifTalepGetir(talepRepository);
            },
            polylines: _info != null && longPressEnable
                ? {
                    Polyline(
                        polylineId: const PolylineId("overview_polyline"),
                        points: _info!.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                        color: Colors.purple,
                        width: 3)
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
                  child: Text("${_info!.totalDistance},${_info!.totalDuration}, ${widget.kurye!.arac.toString()}"),
                )),
          siparislerAltMenusu(talepRepository, bildirimRepository),
          trafficButton(),
          myLocationButton(),
          ortalaButton(),
          addRoadButton()
        ],
      ),
    );
  }

  Future<void> aktifTalepGetir(TalepRepository talepRepository) async {
    ref.read(talepprovider).kuryeAktifTalepleriGetir(kuryeId: FirebaseAuth.instance.currentUser!.uid).then((value) {
      if (value > 0) {
        Future.delayed(const Duration(seconds: 1), () async {
          await locatePosition();
        }).whenComplete(() => Future.delayed(const Duration(seconds: 0), () {
              setState(() {
                longPressEnable = true;
              });
              _addMarker(talepRepository.talepler[0].customerKonum).whenComplete(() => _info != null
                  ? _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(_info!.bounds, 100.0))
                  : _googleMapController.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition)));
            }));
      }
    });
  }

  Future<void> locatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission are disabled.')));
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location permission are denied forever.')));
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    LatLng latlng = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latlng, zoom: 14.5);
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    currentposition = position;
  }

  Future<void> _addMarker(LatLng basilanYer) async {
    if (currentposition == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Şu anki konum bulunamadı. Konumu açmayı deneyebilirsiniz.")));
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
          arac: widget.kurye!.arac);
      setState(() {
        _info = directions;
        isLoad = false;
      });
      return;
    }
  }

  // Future<void> _addCustomerMarker(List<Customer> customers)async{
  //   if(customers.length>0){
  //     for(var c in customers){
  //       if(c.enlemVeBoylam!=null){
  //         setState(() {
  //           customersMarker.add(Marker(
  //               markerId: MarkerId(c.kullaniciAdi),
  //               infoWindow: InfoWindow(title: c.kullaniciAdi),
  //               icon: customerIcon,
  //               position: c.enlemVeBoylam!
  //           ));
  //         });
  //       }
  //     }
  //   }
  //   return;
  // }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<Distance?> kuryeKonumHesapla(Kurye kurye, Customer customer, KuryeViewModel kuryeRepository) async {
    if (kurye.enlemBoylam == null) return null;
    if (customer.enlemBoylam == null) return null;
    var konum = await DistanceViewModel.getDistance(
        baslangic: customer.enlemBoylam!, hedef: kurye.enlemBoylam!, arac: KuryeArac.DRIVING);
    return konum;
  }

  Widget siparislerAltMenusu(TalepRepository siparisRepository, BildirimRepository bildirimRepository) {
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
                          color: Colors.blue.shade200,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                                top: 10,
                                right: 20,
                                child: IconButton(
                                  onPressed: () {
                                    print("yenileniyor");
                                    mystate(() {
                                      if (widget.kurye != null) {
                                        mystate(() {
                                          aktifSiparisler.clear();
                                          if (ref.read(talepprovider).kuryeAktifTalepVarMi(widget.kurye!)) {
                                            // aktifSiparisler.addAll(ref.read(talepprovider).kuryeAktifTalepleriGetir(widget.kurye!)!);
                                          }
                                        });
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.refresh),
                                  splashColor: Colors.black,
                                  color: Colors.blue,
                                )),
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
                                  "Siparişler",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ))),
                            Positioned.fill(
                              top: 50,
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  if (aktifSiparisler.isEmpty) {
                                    return const ListTile(title: Text("Şu anda aktif bir siparişiniz bulunmamaktadır"));
                                  }
                                  return ListTile(
                                    onTap: () {
                                      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                          CameraPosition(target: aktifSiparisler[index].customerKonum, zoom: 15)));
                                      Navigator.of(context).pop();
                                      _googleMapController
                                          .showMarkerInfoWindow(MarkerId(aktifSiparisler[index].customerId));
                                    },
                                    title: const Text(
                                      "aktifSiparisler[index].mesafeBilgisi.originAddress",
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      maxLines: 2,
                                    ),
                                    subtitle: Text(
                                        "Sipariş Süresi: ${"aktifSiparisler[index].mesafeBilgisi.totalDistance"}, ${"aktifSiparisler[index].mesafeBilgisi.totalDuration"}, Durum: ${aktifSiparisler[index].talepDurum}"),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                        content: SizedBox(
                                                      height: 150,
                                                      width: 100,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            const Text("Sipariş Teslim edildi mi?"),
                                                            Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  ElevatedButton(
                                                                      onPressed: () {
                                                                        // ref.read(talepprovider).talepBitir(aktifSiparisler[index],bildirimRepository,widget.kurye!.uid);
                                                                        mystate(() {
                                                                          longPressEnable = false;
                                                                          _baslangic = null;
                                                                          _hedef = null;
                                                                          _info = null;
                                                                          if (widget.kurye != null) {
                                                                            mystate(() {
                                                                              aktifSiparisler.clear();
                                                                              if (ref
                                                                                  .read(talepprovider)
                                                                                  .kuryeAktifTalepVarMi(
                                                                                      widget.kurye!)) {
                                                                                // aktifSiparisler.addAll(ref.read(talepprovider).kuryeAktifTalepleriGetir(widget.kurye!)!);
                                                                              }
                                                                            });
                                                                          }
                                                                        });
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: const Text("Evet")),
                                                                  ElevatedButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: const Text("Hayır"))
                                                                ])
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                                  });
                                            },
                                            icon: const Icon(Icons.local_grocery_store_outlined)),
                                        IconButton(
                                            onPressed: () {
                                              _addMarker(aktifSiparisler[index].customerKonum).whenComplete(() =>
                                                  _info != null
                                                      ? _googleMapController.animateCamera(
                                                          CameraUpdate.newLatLngBounds(_info!.bounds, 100.0))
                                                      : _googleMapController.animateCamera(
                                                          CameraUpdate.newCameraPosition(_initialCameraPosition)));
                                              setState(() {
                                                longPressEnable = true;
                                              });
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.fmd_good)),
                                      ],
                                    ),
                                  );
                                },
                                itemCount: aktifSiparisler.isNotEmpty ? aktifSiparisler.length : 1,
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
              color: Colors.blue.shade200,
            ),
            child: Center(
              child: Column(
                children: [
                  const Divider(
                    indent: 100,
                    endIndent: 100,
                    thickness: 3,
                    color: Colors.black45,
                  ),
                  Text("Siparişler", style: GoogleFonts.roboto(color: Colors.black45, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
        ));
  }

  Widget trafficButton() {
    return Positioned(
      top: 140,
      right: 5,
      child: FloatingActionButton(
        heroTag: "btn-1",
        tooltip: "Trafik Gösterimi",
        onPressed: () {
          setState(() {
            if (trafficMode) {
              trafficMode = false;
            } else {
              trafficMode = true;
            }
          });
        },
        backgroundColor: Colors.black45,
        child: trafficMode ? const Icon(Icons.traffic) : const Icon(Icons.traffic_outlined),
      ),
    );
  }

  Widget myLocationButton() {
    return Positioned(
        right: 5,
        top: 20,
        child: FloatingActionButton(
          heroTag: "btn-2",
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
          heroTag: "btn-3",
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
          backgroundColor: Colors.black45,
          child: longPressEnable ? const Icon(Icons.close) : const Icon(Icons.add_location),
        ));
  }

  Widget ortalaButton() {
    return Positioned(
      top: 200,
      right: 5,
      child: FloatingActionButton(
        heroTag: "btn-4",
        tooltip: "Ortala",
        onPressed: () {
          _info != null
              ? _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(_info!.bounds, 100.0))
              : _googleMapController.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
        },
        backgroundColor: Colors.black45,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
