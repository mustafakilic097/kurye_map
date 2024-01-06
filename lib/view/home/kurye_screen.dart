import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/constants/enum/kurye_arac_enum.dart';
import 'package:kurye_map/view/map/kurye_mapscreen.dart';
import 'package:kurye_map/core/model/bildirim.dart';
import 'package:kurye_map/core/model/person/kurye.dart';
import '../../core/components/easyloading/easy_loading.dart';
import '../../core/model/talep.dart';
import 'package:kurye_map/core/viewmodel/customer_view_model.dart';
import 'package:kurye_map/core/viewmodel/kurye_view_model.dart';
import 'package:kurye_map/core/viewmodel/talep_view_model.dart';
import 'package:kurye_map/view/settings/kurye_settings_screen.dart';
import 'package:kurye_map/view/auth/login_screen.dart';
import 'package:kurye_map/view/request/talep_screen.dart';
import 'package:kurye_map/core/components/info_location.dart';
import 'package:kurye_map/core/components/mesafe_hesapla.dart';
import '../../core/model/map/distance_model.dart';
import '../../core/viewmodel/distance_view_model.dart';
import '../../core/viewmodel/bildirim_view_model.dart';
import '../notification/bildirim_screen.dart';

class KuryeScreen extends ConsumerStatefulWidget {
  final String uid;
  const KuryeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return KuryeScreenState();
  }
}

class KuryeScreenState extends ConsumerState<KuryeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Kurye kurye;
  bool kuryeAktifmi = false;
  bool isLoaded = false;
  int talepSayisi = 0;
  int bildirimSayisi = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadUser().then((value) {
      setState(() {
        kurye = value;
        isLoaded = true;
      });
      if (ref.read(talepprovider).kuryeAktifTalepVarMi(kurye)) {
        //TODO aktif bildirim ve talepler için bir banner aç.
        // aktifSiparisler.addAll(ref.read(talepprovider).customerAktifTalepleriGetir(customer)!);
      }
      if (kurye.enlemBoylam != null) {
        Future.delayed(const Duration(seconds: 0), () async {
          await ref.read(talepprovider).kuryeAktifTalepleriGetir(kuryeId: widget.uid).then((value) {
            setState(() {
              talepSayisi = value;
            });
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Aktif talepler getirilirken sorun oluştu. İnternet bağlantını kontrol eder misin?"),
                backgroundColor: Colors.orange));
          });
        });
      } else {
        print("Kullanıcının konum bilgisi yok");
      }
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kayıt getirilirken hata oluştu! Tekrar deneyin, hata:$e ${widget.uid}"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
    });
    Future.delayed(const Duration(seconds: 0), () => bildirimleriHazirla());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final musteriRepository = ref.watch(customerRepositoryprovider);
    final bildirimRepository = ref.watch(bildirimprovider);
    final talepRepository = ref.watch(talepprovider);
    final kuryeRepository = ref.watch(kuryeViewModelProvider);
    return !isLoaded
        ? const Scaffold(/*hata*/)
        : Scaffold(
            key: _scaffoldKey,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AppBar(
                  leading: null,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.black45),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(color: Color.fromARGB(100, 15, 72, 102)),
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
                    "Kurye Paneli",
                    style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KuryeSettingsScreen(
                                  kurye: kurye,
                                ),
                              ));
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 30,
                        )),
                    IconButton(
                        onPressed: () async {
                          await EasyLoading(context).buildLoading();
                          await FirebaseAuth.instance.signOut();
                          await EasyLoading(context).buildLoading();
                          await Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                        icon: const Icon(Icons.exit_to_app))
                  ]),
            ),
            body: ColoredBox(
              color: const Color.fromRGBO(230, 239, 255, 1),
              child: RefreshIndicator(
                onRefresh: () async {
                  if (kurye.enlemBoylam != null) {
                    await ref
                        .read(bildirimprovider)
                        .kuryeBildirimlerGetir(widget.uid)
                        .then((value) => setState(() => bildirimSayisi = value));
                    Future.delayed(const Duration(seconds: 0), () async {
                      await ref.read(talepprovider).kuryeAktifTalepleriGetir(kuryeId: widget.uid).then((value) {
                        setState(() {
                          talepSayisi = value;
                        });
                      }).catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Aktif talepler getirilirken sorun oluştu. İnternet bağlantını kontrol eder misin?"),
                            backgroundColor: Colors.orange));
                      });
                    });
                  } else {
                    print("Kullanıcının konum bilgisi yok");
                  }
                },
                child: Column(
                  children: [
                    SizedBox(
                      height: 225,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "${kurye.ad} ${kurye.soyad}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.primaries[6]),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TalepScreen(
                                                    rol: 'kurye',
                                                    uid: widget.uid,
                                                    kurye: kurye,
                                                  )));
                                    },
                                    icon: const Icon(Icons.history),
                                    iconSize: 35,
                                    color: Colors.black,
                                  ),
                                  const Text("Talepler")
                                ],
                              ),
                              Container(
                                  child: Container(
                                width: 120,
                                height: 120,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/customer.png',
                                  fit: BoxFit.cover,
                                ),
                              )),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => BildirimScreen(
                                                    rol: 'kurye',
                                                    uid: widget.uid,
                                                    kurye: kurye,
                                                  )));
                                    },
                                    icon: const Icon(Icons.notifications_none),
                                    iconSize: 35,
                                    color: Colors.black,
                                  ),
                                  const Text("Bildirimler")
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Konum Takibi"),
                              Switch(
                                  value: kuryeAktifmi,
                                  onChanged: (value) async {
                                    if (value) {
                                      await locatePosition().then((value) {
                                        if (value) {
                                          setState(() => kuryeAktifmi = value);
                                          timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
                                            await locatePosition();
                                          });
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        timer != null ? timer!.cancel() : null;
                                        kuryeAktifmi = false;
                                      });
                                    }
                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    const Text("Aktif Talep"),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F4866),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 4,
                              color: Color(0x33000000),
                              offset: Offset(0, 2),
                            )
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 16, 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width - 100,
                                      child: Text(
                                          talepRepository.talepler.isNotEmpty
                                              ? "Durum: ${talepRepository.talepler[0].talepDurum}"
                                              : "...",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ))),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                    child: Text(
                                      talepRepository.talepler.isNotEmpty ? "Talep Aktif" : "Şu anda aktif talep yok",
                                      style: GoogleFonts.roboto(
                                        color: const Color(0xFF7C8791),
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              !(talepRepository.talepler.isNotEmpty)
                                  ? const Text("")
                                  : IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                backgroundColor: Colors.indigo,
                                                child: SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                buildTalepBitirDialog(
                                                                    0, talepRepository.talepler[0], context);
                                                              },
                                                              child: const Text("Talebi Bitir")),
                                                          const SizedBox(width: 25),
                                                          const SizedBox(width: 25),
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(context).push(MaterialPageRoute(
                                                                    builder: (context) => KuryeMapScreenPage(
                                                                        baslangicPosition: CameraPosition(
                                                                            target: kurye.enlemBoylam!, zoom: 14.5),
                                                                        kurye: kurye)));
                                                              },
                                                              child: const Text("Yol Tarifi")),
                                                        ],
                                                      ),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            showDialog(
                                                                context: _scaffoldKey.currentContext!,
                                                                builder: (context) {
                                                                  return Dialog(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(15),
                                                                      child: FutureBuilder(
                                                                          future: getLocationInfo(talepRepository
                                                                              .talepler[0].customerKonum),
                                                                          builder: (context, snapshot) {
                                                                            if (snapshot.hasData) {
                                                                              return SizedBox(
                                                                                height: 200,
                                                                                child: Column(
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text("Adres",
                                                                                        style: GoogleFonts.roboto(
                                                                                            color: Colors.indigo,
                                                                                            fontSize: 18)),
                                                                                    const SizedBox(height: 5),
                                                                                    Text(
                                                                                      snapshot.data!,
                                                                                      style: GoogleFonts.roboto(
                                                                                          fontWeight: FontWeight.bold),
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              return const SizedBox(
                                                                                height: 200,
                                                                                child: Center(
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Text("Adres getiriliyor......"),
                                                                                      CircularProgressIndicator(),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }
                                                                          }),
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                          child: const Text("Konum Detayları")),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 30),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Text("Aktif Bildirimler"),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          var kb = bildirimRepository.kuryeBildirimler;
                          if (kb.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F4866),
                                  boxShadow: const [
                                    BoxShadow(
                                      blurRadius: 4,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 16, 16),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              width: MediaQuery.of(context).size.width - 100,
                                              child: Text("...",
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: GoogleFonts.roboto(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ))),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                            child: Text(
                                              "Şuanda bildirim yok",
                                              style: GoogleFonts.roboto(
                                                color: const Color(0xFF7C8791),
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F4866),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 4,
                                    color: Color(0x33000000),
                                    offset: Offset(0, 2),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 16, 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width - 100,
                                            child: Text(kb[index].bildirimIcerik,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ))),
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                          child: Text(
                                            kb[index].gonderenRol,
                                            style: GoogleFonts.roboto(
                                              color: const Color(0xFF7C8791),
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: _scaffoldKey.currentContext!,
                                            builder: (context) {
                                              return Dialog(
                                                backgroundColor: Colors.indigo,
                                                child: SizedBox(
                                                  height: 200,
                                                  width: 200,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                showDialog(
                                                                    context: _scaffoldKey.currentContext!,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title: const Text("Uyarı"),
                                                                        content: const Text(
                                                                            "Talebi eklemek istediğinize emin misiniz ?"),
                                                                        actions: [
                                                                          TextButton(
                                                                              onPressed: () async {
                                                                                Navigator.pop(context);
                                                                                await EasyLoading(context)
                                                                                    .buildLoading();
                                                                                final b = bildirimRepository
                                                                                    .kuryeBildirimler[index];
                                                                                Talep kabulTalep = Talep(
                                                                                    talepDurum:
                                                                                        "Kurye kabul etti. Birazdan yola çıkacak",
                                                                                    kuryeId: widget.uid,
                                                                                    customerId: b.gonderenId,
                                                                                    customerKonum: b.gonderenKonum,
                                                                                    talepAktif: true);
                                                                                Bildirim kabulBildirim = Bildirim(
                                                                                    gonderenId: widget.uid,
                                                                                    aliciId: b.gonderenId,
                                                                                    gonderenRol: "kurye",
                                                                                    aliciRol: "musteri",
                                                                                    bildirimIcerik:
                                                                                        "Kurye kabul etti. Birazdan yola çıkacak",
                                                                                    bildirimAktif: true,
                                                                                    gonderenKonum: b.gonderenKonum);
                                                                                await talepKabulEt(kabulTalep,
                                                                                        kabulBildirim, index)
                                                                                    .then((value) async {
                                                                                  EasyLoading(context).closeLoading();
                                                                                  setState(() {
                                                                                    bildirimRepository.kuryeBildirimler
                                                                                        .removeAt(index);
                                                                                  });
                                                                                }).catchError((e) async {
                                                                                  EasyLoading(context).closeLoading();
                                                                                });
                                                                              },
                                                                              child: const Text("Tamam")),
                                                                          TextButton(
                                                                              onPressed: () async {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: const Text("İptal"))
                                                                        ],
                                                                      );
                                                                    });
                                                              },
                                                              child: const Text("Talebi Kabul et")),
                                                          const SizedBox(width: 25),
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                showDialog(
                                                                    context: _scaffoldKey.currentContext!,
                                                                    builder: (context) {
                                                                      return AlertDialog(
                                                                        title: const Text("Uyarı"),
                                                                        content: const Text(
                                                                            "Talep bildirimini reddetmek istediğinize emin misiniz ?"),
                                                                        actions: [
                                                                          TextButton(
                                                                              onPressed: () async {
                                                                                Navigator.pop(context);
                                                                                await EasyLoading(context)
                                                                                    .buildLoading();
                                                                                final b = bildirimRepository
                                                                                    .kuryeBildirimler[index];
                                                                                await talepReddet(
                                                                                        kuryeRepository, b, index)
                                                                                    .then((value) async {
                                                                                  EasyLoading(context).closeLoading();
                                                                                  setState(() {
                                                                                    bildirimRepository.kuryeBildirimler
                                                                                        .removeAt(index);
                                                                                  });
                                                                                }).catchError((e) async {
                                                                                  ScaffoldMessenger.of(context)
                                                                                      .showSnackBar(const SnackBar(
                                                                                    content: Text(
                                                                                        "Talep Reddedilirken hata oluştu"),
                                                                                    backgroundColor: Colors.orange,
                                                                                  ));
                                                                                  EasyLoading(context).closeLoading();
                                                                                });
                                                                              },
                                                                              child: const Text("Tamam")),
                                                                          TextButton(
                                                                              onPressed: () async {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: const Text("İptal"))
                                                                        ],
                                                                      );
                                                                    });
                                                              },
                                                              child: const Text("Talebi Reddet")),
                                                        ],
                                                      ),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                            buildBildirimDetayDialog(
                                                                bildirimRepository.kuryeBildirimler[index]);
                                                          },
                                                          child: const Text("Detaylar")),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      },
                                      icon: const Icon(Icons.info_outline, color: Colors.white, size: 30),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: bildirimRepository.kuryeBildirimler.isEmpty
                            ? 1
                            : bildirimRepository.kuryeBildirimler.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget bildirimler(
      BildirimRepository bildirimRepository, CustomerViewModel musteriRepository, KuryeViewModel kuryeRepository) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(bildirimprovider).kuryeBildirimlerGetir(widget.uid).then((value) => bildirimSayisi = value);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 8, bottom: 8),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black45, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: [
              Text(
                "Bildirimler",
                style: GoogleFonts.roboto(color: Colors.black45, fontWeight: FontWeight.bold),
              ),
              const Divider(
                height: 10,
                thickness: 1,
                color: Colors.black45,
              ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    //TODO en yakın kuryeleri müşteri için burada bul.
                    return ExpansionTile(
                      title: Text(bildirimRepository.kuryeBildirimler[index].bildirimIcerik.toString()),
                      subtitle: Text("Gönderen: ${bildirimRepository.kuryeBildirimler[index].gonderenRol}",
                          style: GoogleFonts.roboto(color: Colors.black54)),
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton(
                                  style: const ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.red)),
                                  onPressed: () async {
                                    showDialog(
                                        context: _scaffoldKey.currentContext!,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Uyarı"),
                                            content:
                                                const Text("Talep bildirimini reddetmek istediğinize emin misiniz ?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await EasyLoading(context).buildLoading();
                                                    final b = bildirimRepository.kuryeBildirimler[index];
                                                    await talepReddet(kuryeRepository, b, index).then((value) async {
                                                      EasyLoading(context).closeLoading();
                                                      setState(() {
                                                        bildirimRepository.kuryeBildirimler.removeAt(index);
                                                      });
                                                    }).catchError((e) async {
                                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                        content: Text("Talep Reddedilirken hata oluştu"),
                                                        backgroundColor: Colors.orange,
                                                      ));
                                                      EasyLoading(context).closeLoading();
                                                    });
                                                  },
                                                  child: const Text("Tamam")),
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("İptal"))
                                            ],
                                          );
                                        });
                                  },
                                  child: const Row(
                                    children: [Icon(Icons.close_sharp), Text(" Reddet")],
                                  )),
                              const Spacer(),
                              OutlinedButton(
                                  onPressed: () {
                                    buildBildirimDetayDialog(bildirimRepository.kuryeBildirimler[index]);
                                  },
                                  child: const Row(
                                    children: [Icon(Icons.info), Text(" Detaylar")],
                                  )),
                              const Spacer(),
                              OutlinedButton(
                                  style: const ButtonStyle(foregroundColor: MaterialStatePropertyAll(Colors.green)),
                                  onPressed: () async {
                                    showDialog(
                                        context: _scaffoldKey.currentContext!,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Uyarı"),
                                            content: const Text("Talebi eklemek istediğinize emin misiniz ?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await EasyLoading(context).buildLoading();
                                                    final b = bildirimRepository.kuryeBildirimler[index];
                                                    Talep kabulTalep = Talep(
                                                        talepDurum: "Kurye kabul etti. Birazdan yola çıkacak",
                                                        kuryeId: widget.uid,
                                                        customerId: b.gonderenId,
                                                        customerKonum: b.gonderenKonum,
                                                        talepAktif: true);
                                                    Bildirim kabulBildirim = Bildirim(
                                                        gonderenId: widget.uid,
                                                        aliciId: b.gonderenId,
                                                        gonderenRol: "kurye",
                                                        aliciRol: "musteri",
                                                        bildirimIcerik: "Kurye kabul etti. Birazdan yola çıkacak",
                                                        bildirimAktif: true,
                                                        gonderenKonum: b.gonderenKonum);
                                                    await talepKabulEt(kabulTalep, kabulBildirim, index)
                                                        .then((value) async {
                                                      await EasyLoading(context).buildLoading();
                                                      setState(() {
                                                        bildirimRepository.kuryeBildirimler.removeAt(index);
                                                      });
                                                    }).catchError((e) async {
                                                      EasyLoading(context).closeLoading();
                                                    });
                                                  },
                                                  child: const Text("Tamam")),
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("İptal"))
                                            ],
                                          );
                                        });
                                  },
                                  child: const Row(
                                    children: [Icon(Icons.check_circle_sharp), Text(" Kabul Et")],
                                  )),
                            ],
                          ),
                        )
                      ],
                      // trailing: SizedBox(
                      //   width: 130,
                      //   //TODO customer'ın sadece id'si yetiyosa onu o şekil düzelt
                      //   child: Row(children: [
                      //     // TextButton(onPressed: () async{
                      //     //   var kuryeMesafe =await kuryeKonumHesapla(kurye, cust.enlemBoylam!);
                      //     //   kuryeMesafe ??= await kuryeKonumHesapla(kurye, cust.enlemBoylam!);
                      //     //   if(kuryeMesafe==null){
                      //     //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mesafe bilgisi alınamadı.İnternetinizi kontrol eder misiniz ?"),backgroundColor: Colors.orange,behavior: SnackBarBehavior.floating,));
                      //     //     throw Exception("Mesafe bilgisi alınamadı");
                      //     //   }
                      //     //   Future<String>? bildirim = ref.read(kuryeRepositoryprovider).siparisBildirimYazisiOlustur(kurye: kurye, customer: cust);
                      //     //   var stdBildirim = "Kurye yola çıktı.";
                      //     //   ref.read(bildirimprovider).customeraBildirimGonder(Bildirim(bildirimIcerik:await bildirim ?? stdBildirim, bildirimAktif: true,kuryeId: kurye.uid,customerId: cust.uid,gonderenId: kurye.uid));
                      //     //   String id = ref.read(talepprovider).talepIdOlustur();
                      //     //
                      //     //   ref.read(talepprovider).talepEkle(Talep(talepId:id, talepDurum: "Kurye yolda",kuryeId: kurye.uid,customerId: cust.uid,customerKonum:  cust.enlemBoylam!, talepAktif: true));
                      //     //   ref.read(bildirimprovider).bildirimSil(kuryeBildirim);
                      //     //   setState(() {
                      //     //     if(ref.read(talepprovider).kuryeAktifTalepVarMi(kurye)){
                      //     //       // aktifSiparisler = ref.read(talepprovider).kuryeAktifTalepleriGetir(widget.kurye)!;
                      //     //     }
                      //     //   });
                      //     // }, child: const Text("Evet")),
                      //     // TextButton(onPressed: (){
                      //     //   if(enYakinlar!=null){
                      //     //     // if(enYakinlar.length==cust.enYakinKuryeIndex){
                      //     //     //   ref.read(bildirimprovider).customeraBildirimGonder(Bildirim(bildirimIcerik: "Başka kurye olmadığından sipariş oluşturulamıyor", bildirimAktif: false,kuryeId: widget.kurye.kuryeId,customerId: cust.customerId,gonderenId: "000000"));
                      //     //     // }
                      //     //     //TODO redid'lere ekleterek hayır de. En yakın kurye olayını iptal et. En yakın kurye listesi sadece local'de olsun.
                      //     //     // else{
                      //     //     //   ref.read(bildirimprovider).kuryeyeBildirimGonder(
                      //     //     //       Bildirim(bildirimIcerik: "${enYakinlar[cust.enYakinKuryeIndex!].kuryeKonum!.totalDistance} uzaklıkta ${enYakinlar[cust.enYakinKuryeIndex!].kuryeKonum!.totalDuration} süre uzaklıkta bir sipariş var.", bildirimAktif: true,customerId:cust.customerId,gonderenId: cust.customerId,kuryeId: enYakinlar[cust.enYakinKuryeIndex!].kuryeId));
                      //     //     // }
                      //     //   }
                      //     //   // ref.read(bildirimprovider).bildirimSil(kuryeBildirim);
                      //     // }, child: const Text("Hayır"))
                      //   ],),
                      // ),
                    );
                  },
                  itemCount: bildirimRepository.kuryeBildirimler.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void buildBildirimDetayDialog(Bildirim b) {
    String mesafeBilgisi = "";
    bool gercekVeriAktif = false;
    if (kurye.enlemBoylam != null) {
      final m = MesafeMetrik.mesafeKmHesaplama(b.gonderenKonum, kurye.enlemBoylam!);
      mesafeBilgisi =
          "Tahmini ${(m * 1.6).toStringAsFixed(1)} km uzaklıkta ve ${(m <= 10 ? m * 4.5 : m * 3.6).toStringAsFixed(1)} dk mesafede";
    } else {
      mesafeBilgisi =
          "Konumunuz bulunamadı. Mesafe bilgisini görmek istiyorsanız konumunuzu ekleyip uygulamayı yeniden başlatın.";
    }
    showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                child: SizedBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Detaylar",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Column(
                        children: [
                          Text("Gönderen Bilgiler", style: GoogleFonts.roboto(color: Colors.indigo, fontSize: 18)),
                          const SizedBox(height: 5),
                          Text("Gönderen rol: ${b.gonderenRol}",
                              style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 30),
                      FutureBuilder(
                          future: getLocationInfo(b.gonderenKonum),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Adres", style: GoogleFonts.roboto(color: Colors.indigo, fontSize: 18)),
                                  const SizedBox(height: 5),
                                  Text(
                                    snapshot.data!,
                                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            } else {
                              return const Center(
                                child: Column(
                                  children: [
                                    Text("Adres getiriliyor......"),
                                    CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            }
                          }),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 30),
                      Column(
                        children: [
                          Text("Tahmini Mesafe Bilgisi", style: GoogleFonts.roboto(color: Colors.indigo, fontSize: 18)),
                          const SizedBox(height: 5),
                          Text(mesafeBilgisi, style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      gercekVeriAktif
                          ? FutureBuilder(
                              future: kuryeKonumHesapla(kurye, b.gonderenKonum),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Google Konum Bilgileri",
                                          style: GoogleFonts.roboto(color: Colors.indigo, fontSize: 18)),
                                      const SizedBox(height: 5),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              const Text("Mesafe(km): "),
                                              Text(
                                                snapshot.data!.totalDistance,
                                                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          Row(
                                            children: [
                                              const Text("Süre(dk): "),
                                              Text(
                                                snapshot.data!.totalDuration,
                                                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          Text("Adres", style: GoogleFonts.roboto(color: Colors.indigo, fontSize: 18)),
                                          Text(
                                            snapshot.data!.originAddress,
                                            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          const Divider(),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Center(
                                    child: Column(
                                      children: [
                                        Text("Konum bilgisi getiriliyor..."),
                                        CircularProgressIndicator(),
                                      ],
                                    ),
                                  );
                                }
                              })
                          : Column(
                              children: [
                                Center(
                                    child: Text(
                                  "Bu bilgiler yeterli değil mi?",
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w300),
                                )),
                                OutlinedButton(
                                    onPressed: () {
                                      setState(() => gercekVeriAktif = true);
                                    },
                                    child: const Text("Google ile Konum Bilgilerini Getir")),
                              ],
                            ),
                      const SizedBox(height: 30)
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Future<void> talepReddet(KuryeViewModel kuryeRepository, Bildirim b, int bildirimIndex) async {
    await ref.read(kuryeViewModelProvider).yakindakiAktifKuryeleriGetir(
        customerKonum: b.gonderenKonum,
        redIds: [if (b.redIdler != null) ...b.redIdler!, widget.uid]).then((value) async {
      if (value > 0) {
        var ilkKurye = kuryeRepository.yakinKuryeler[0];
        var icerik =
            "Tahmini ${(kuryeRepository.yakinMesafeler[0] * 1.6).toStringAsFixed(1)} km uzaklıkta ${(kuryeRepository.yakinMesafeler[0] <= 10 ? kuryeRepository.yakinMesafeler[0] * 4.5 : kuryeRepository.yakinMesafeler[0] * 3.6).toStringAsFixed(1)} dk uzaklıkta bir sipariş var.";
        var bil = Bildirim(
            gonderenId: b.gonderenId,
            aliciId: ilkKurye.uid,
            gonderenRol: "musteri",
            aliciRol: "kurye",
            bildirimIcerik: icerik,
            bildirimAktif: true,
            gonderenKonum: b.gonderenKonum,
            redIdler: [if (b.redIdler != null) ...b.redIdler!, widget.uid]);
        await ref.read(bildirimprovider).kuryeBildirimPasifle(uid: widget.uid, bildirimIndex: bildirimIndex);
        await ref
            .read(bildirimprovider)
            .bildirimGonder(bil, context)
            .then((value) => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Başarıyla bildirim gönderildi"))))
            .catchError((e) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e"))));
      } else {
        await ref.read(bildirimprovider).kuryeTalepIptalBildirimiGonder(gonderenId: widget.uid, aliciId: b.gonderenId);
      }
    }).catchError((e) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata var: $e")));
    });
  }

  Future<void> talepKabulEt(Talep talep, Bildirim bildirim, int bildirimIndex) async {
    await ref.read(talepprovider).kuryeAktifTalepleriGetir(kuryeId: widget.uid).then((value) async {
      if (value > 0) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text("Uyarı"),
                  content: const Text("Zaten aktif bir talebin var. Önce onu bitirmelisin!"),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam"))],
                ));
        throw Exception("Zaten aktif talebi var");
      } else {
        await ref.read(talepprovider).talepEkle(talep, context).then((value) async {
          try {
            await ref.read(kuryeViewModelProvider).kuryePasiflestir(widget.uid);
            await ref.read(bildirimprovider).kuryeBildirimPasifle(uid: widget.uid, bildirimIndex: bildirimIndex);
          } catch (e) {
            bool gorev = true;
            int sure = 10;
            while (gorev) {
              final b = Future.wait([
                ref.read(kuryeViewModelProvider).kuryePasiflestir(widget.uid),
                ref.read(bildirimprovider).kuryeBildirimPasifle(uid: widget.uid, bildirimIndex: bildirimIndex)
              ]);
              b.then((value) => gorev = false);
              Future.delayed(Duration(seconds: sure));
              sure += 5;
            }
          }
          await ref.read(bildirimprovider).bildirimGonder(bildirim, context).then((value) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Talebi kabul ettiniz. İyi yolculuklar 🙂")));
          }).catchError((e) {
            ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                content: const Text(
                    "Talep eklendi fakat müşteriye bildirim gönderilemedi. Müşteriye haber verin ya da tekrar deneyin."),
                backgroundColor: Colors.orange.shade400,
                actions: [
                  TextButton(
                      onPressed: () async {
                        await EasyLoading(context).buildLoading();
                        final f = await ref.read(bildirimprovider).bildirimGonder(bildirim, context);
                        if (f) {
                          EasyLoading(context).closeLoading();
                          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Müşteriye bildirim başarıyla gönderildi. İyi yolculuklar 🙂"),
                            backgroundColor: Colors.green,
                          ));
                        } else {
                          EasyLoading(context).closeLoading();
                          await ref.read(kuryeViewModelProvider).kuryePasiflestir(widget.uid);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Müşteriye bildirim başarıyla gönderildi. İyi yolculuklar 🙂"),
                            backgroundColor: Colors.green,
                          ));
                        }
                      },
                      child: const Text("Tekrar Dene!")),
                ]));
          });
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Talep kabul edilemedi.İnternetinizi kontrol ettikten sonra tekrar deneyin"),
            backgroundColor: Colors.orange,
          ));
        });
      }
    });
  }

  Widget aktifTalepler(TalepRepository talepRepository, BildirimRepository bildirimRepository) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(talepprovider)
            .kuryeAktifTalepleriGetir(kuryeId: widget.uid)
            .then((value) => setState(() => talepSayisi = value));
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 30.0, left: 30.0, top: 8, bottom: 8),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
              boxShadow: const [BoxShadow(blurRadius: 15, color: Colors.black12, blurStyle: BlurStyle.outer)],
              border: Border.all(color: Colors.black45, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: [
              Text("Aktif Siparişler", style: GoogleFonts.roboto(color: Colors.black45, fontWeight: FontWeight.bold)),
              const Divider(
                height: 10,
                thickness: 1,
                color: Colors.black45,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    if (talepRepository.talepler.isNotEmpty) {
                      print("sipariş aktif");
                      return ExpansionTile(
                        childrenPadding: const EdgeInsets.all(16),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: RichText(
                            text: TextSpan(children: [
                          const TextSpan(text: "Sipariş durumu: ", style: TextStyle(color: Colors.black)),
                          TextSpan(
                              text: talepRepository.talepler[index].talepDurum,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                        ])),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      buildTalepBitirDialog(index, talepRepository.talepler[index], context);
                                    },
                                    icon: const Icon(Icons.local_grocery_store_outlined)),
                                const Text(
                                  "Sipariş Bitir",
                                  style: TextStyle(fontSize: 7),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => KuryeMapScreenPage(
                                              baslangicPosition: CameraPosition(target: kurye.enlemBoylam!, zoom: 14.5),
                                              kurye: kurye)));
                                    },
                                    icon: const Icon(Icons.share_location)),
                                const Text("Yol Tarifi", style: TextStyle(fontSize: 7))
                              ],
                            ),
                          ],
                        ),
                        children: [
                          FutureBuilder(
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  "Adres: ${snapshot.data}",
                                  style: const TextStyle(color: Colors.red),
                                );
                              } else if (snapshot.hasError) {
                                return const Text(
                                  "Adres: ${"İnternet bağlantısında sorun var. Bağlantıdan eminseniz sayfayı yenileyin."}",
                                  style: TextStyle(color: Colors.red),
                                );
                              } else {
                                return const Text(
                                  "Adres: Yükleniyor...",
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                            },
                            future: getLocationInfo(talepRepository.talepler[index].customerKonum),
                            initialData: "Yükleniyor....",
                          )
                        ],
                      );
                    } else {
                      return const ListTile(
                        title: Text("Aktif sipariş yok"),
                      );
                    }
                  },
                  itemCount: talepRepository.talepler.isNotEmpty ? talepRepository.talepler.length : 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void buildTalepBitirDialog(int index, Talep talep, context) {
    showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: const Text("Uyarı"),
            content: const Text("Talebi bitirmek istediğinize emin misiniz ?"),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await EasyLoading(context).buildLoading();
                    await talepBitir(talep, index)
                        .then((value) async => EasyLoading(context).closeLoading())
                        .catchError((e) async => EasyLoading(context).closeLoading());
                  },
                  style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.orange)),
                  child: const Text("Evet")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("İptal"))
            ],
          );
        });
  }

  Future<void> talepBitir(Talep talep, int talepIndex) async {
    try {
      final b = Bildirim(
          gonderenId: talep.kuryeId,
          aliciId: talep.customerId,
          gonderenRol: "kurye",
          aliciRol: "musteri",
          gonderenKonum: talep.customerKonum,
          bildirimIcerik: "Talebiniz tamamlandı. İyi günler dileriz 🙂",
          bildirimAktif: true);
      await ref.read(talepprovider).kuryeTalepPasifle(widget.uid, context, talepIndex);
      await ref.read(bildirimprovider).bildirimGonder(b, context);
      await ref.read(kuryeViewModelProvider).kuryeAktiflestir(widget.uid);
      showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: const Text("Bilgi"),
              content: const Text("Talep başarıyla tamamlandı! Kolay gelsin :)"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Teşekkürler"))
              ],
            );
          });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Talep tamamlandırıldı.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Talep bitirilirken bir hata oluştu. Hata:$e")));
    }
  }

  Future<Distance?> kuryeKonumHesapla(Kurye kurye, LatLng customerKonum) async {
    if (kurye.enlemBoylam == null) return null;
    var konum = await DistanceViewModel.getDistance(
        baslangic: customerKonum, hedef: kurye.enlemBoylam!, arac: KuryeArac.DRIVING);
    return konum;
  }

  Future<Kurye> loadUser() async {
    EasyLoading(context).buildLoading();
    final f = FirebaseFirestore.instance.collection("kuryeler").doc(widget.uid);
    final result = f.get().then((kurye) async {
      final data = kurye.data()!;
      EasyLoading(context).closeLoading();
      return Kurye.fromMap(data);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kayıt getirilirken hata oluştu! Tekrar deneyin, hata:$e"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      EasyLoading(context).closeLoading();
      Future.error("Hata var allooooo");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ));
      return e;
    });
    return result;
  }

  Future<void> bildirimleriHazirla() async {
    await ref.read(bildirimprovider).kuryeBildirimlerGetir(widget.uid).then((value) {
      setState(() {
        bildirimSayisi = value;
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Bildirimler getirilemedi. İnternetinde sorun olabilir."),
        backgroundColor: Colors.orange,
      ));
    });
  }

  Future<bool> locatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum servisi açık değil')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum izni alınamadı')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konum iznini reddettiniz.')));
      return false;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    LatLng latlng = LatLng(position.latitude, position.longitude);
    final res = ref
        .read(kuryeViewModelProvider)
        .kuryeKonumGuncelle(kuryeId: widget.uid, kuryeKonum: latlng)
        .then((value) => true)
        .catchError((e) => false);
    return res;
  }
}
