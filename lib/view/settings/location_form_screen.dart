import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kurye_map/core/base/state/base_state.dart';

class LocationFormScreen extends StatefulWidget {
  const LocationFormScreen({Key? key}) : super(key: key);

  @override
  BaseState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends BaseState<LocationFormScreen> {
  String adres = "";
  @override
  Widget build(BuildContext context) {
    // final customerRepository = ref.watch(customerViewModelProvider);
    // final kuryeRepository = ref.watch(kuryeViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konum Ekle"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 200,
                color: Colors.black45,
                child: Text("Konumunuzu bulabilmem için lütfen telefonunuzun konum servisini açın",
                    textAlign: TextAlign.center, style: GoogleFonts.roboto(color: Colors.white, fontSize: 20)),
              ),
              ElevatedButton(
                onPressed: () async {
                  // await checkPermission().then((value) async {
                  //   if (value) {
                  //     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
                  //         .then((Position value) async {
                  //       if (widget.rol == "musteri") {
                  //         await EasyLoading(context).buildLoading();
                  //         await customerRepository
                  //             .customerLocationUpdate(
                  //           customerLoc: LatLng(value.latitude, value.longitude),
                  //         )
                  //             .catchError((e) async {
                  //           EasyLoading(context).closeLoading();
                  //           throw Exception("Konum eklenemedi(musteriKonumEkle function)");
                  //         });
                  //         getLocationInfo(LatLng(value.latitude, value.longitude)).then((value) async {
                  //           setState(() => adres = value);
                  //           EasyLoading(context).closeLoading();
                  //         });
                  //         EasyLoading(context).closeLoading();
                  //       } else if (widget.rol == "kurye") {
                  //         await kuryeRepository
                  //             .kuryeKonumGuncelle(
                  //           kuryeId: widget.uid,
                  //           kuryeKonum: LatLng(value.latitude, value.longitude),
                  //         )
                  //             .catchError((e) async {
                  //           EasyLoading(context).closeLoading();
                  //           throw Exception("Konum eklenemedi(kuryeKonumEkle function)");
                  //         });
                  //         getLocationInfo(LatLng(value.latitude, value.longitude)).then((value) async {
                  //           setState(() => adres = value);
                  //           EasyLoading(context).closeLoading();
                  //         });
                  //         EasyLoading(context).closeLoading();
                  //       }
                  //     });
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konum izni alınamadı")));
                  //   }
                  // }).catchError((e) {
                  //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  //       content: Text(
                  //           "Konumunu kontrol etmede sorun yaşıyorum. Gerekli izinleri verdiğinize ve servisin açık olduğundan emin olup tekrar deneyin.")));
                  // });
                },
                child: const Text("Otomatik Konum Ekle"),
              ),
              ElevatedButton(onPressed: 1 == 2 ? () {} : null, child: const Text("Manuel Konum Ekle")),
              Container(
                alignment: Alignment.center,
                height: 200,
                color: Colors.black45,
                child: adres != ""
                    ? Text("Bulunan adresiniz\n $adres",
                        textAlign: TextAlign.center, style: GoogleFonts.roboto(color: Colors.white, fontSize: 20))
                    : const Text("Bulunan adresiniz: bekleniyor..."),
              ),
            ],
          ),
        ),
      ),
    );
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
}
