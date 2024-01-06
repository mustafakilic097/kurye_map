import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/extension/latlng/location_info_mixin.dart';
import 'package:kurye_map/core/viewmodel/talep_view_model.dart';

import '../../core/components/easyloading/easy_loading.dart';
import '../map/customer_mapscreen.dart';
import '../map/kurye_mapscreen.dart';
import '../../core/model/bildirim.dart';
import '../../core/model/person/customer.dart';
import '../../core/model/person/kurye.dart';
import '../../core/model/talep.dart';
import '../../core/viewmodel/bildirim_view_model.dart';
import '../../core/viewmodel/kurye_view_model.dart';

class TalepScreen extends ConsumerStatefulWidget {
  final String rol;
  final String uid;
  final Kurye? kurye;
  const TalepScreen({Key? key, required this.rol, required this.uid, this.kurye}) : super(key: key);

  @override
  ConsumerState<TalepScreen> createState() => _TalepScreenState();
}

class _TalepScreenState extends ConsumerState<TalepScreen> with GetLocationInfo{
  int talepSayisi = 0;

  @override
  void initState() {
    EasyLoading(context).buildLoading();
    Future.delayed(const Duration(seconds: 0), () {
      talepleriHazirla().then((value) => EasyLoading(context).closeLoading()).catchError((e) => EasyLoading(context).closeLoading());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final talepRepository = ref.watch(talepprovider);
    if (widget.rol == "musteri") {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Taleplerim"),
          actions: [
            IconButton(
                onPressed: () async {
                  await talepleriHazirla();
                },
                icon: const Icon(Icons.refresh))
          ],
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black45,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Text("Şu anda aktif $talepSayisi talebiniz var", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var tb = talepRepository.talepler;
                  if (tb.isEmpty) {
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
                                    child: Text('Durum: ${tb[index].talepDurum}',
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
                                    tb[index].talepAktif == true ? "Aktif" : "Aktif Değil",
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
                                              child: SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: Center(
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      await loadUser().then((customer) async {
                                                        await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => CustomerMapScreenPage(
                                                                      customer: customer,
                                                                      takipId: talepRepository.talepler[index].kuryeId,
                                                                    )));
                                                      }).catchError((e) {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                            content: Text("İnternet bağlantısında sorun var.")));
                                                      });
                                                    },
                                                    child: const Text("Canlı Kurye Takip"),
                                                  ),
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
                itemCount: talepRepository.talepler.isEmpty ? 1 : talepRepository.talepler.length,
              ),
            ),

            // SingleChildScrollView(
            //   child: SizedBox(
            //     height: 250,
            //     child: ListView.builder(
            //       itemBuilder: (context, index) {
            //         return Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: DecoratedBox(
            //             decoration: BoxDecoration(border: Border.all()),
            //             child: ListTile(
            //               title: Text(talepRepository.talepler[index].talepDurum),
            //               subtitle: Text("Talep:${talepRepository.talepler[index].talepAktif==true?"aktif":"geçmiş talep"}",style: GoogleFonts.roboto(fontWeight: FontWeight.bold),),
            //               onTap: (){print("talebe tıkladı");},
            //             ),
            //           ),
            //         );
            //       },
            //       itemCount: talepRepository.talepler.length,
            //     ),
            //   ),
            // )
          ],
        ),
      );
    } else if (widget.rol == "kurye") {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Talepler"),
          actions: [
            IconButton(
                onPressed: () async {
                  await talepleriHazirla();
                },
                icon: const Icon(Icons.refresh))
          ],
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black45,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text("Aktif $talepSayisi talep bulundu."),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var tb = talepRepository.talepler;
                  if (tb.isEmpty) {
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
                                    child: Text('Durum: ${tb[index].talepDurum}',
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
                                    tb[index].talepAktif == true ? "Aktif" : "Aktif Değil",
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
                                                                  0, talepRepository.talepler[index], context);
                                                            },
                                                            child: const Text("Talebi Bitir")),
                                                        const SizedBox(width: 25),
                                                        ElevatedButton(
                                                            onPressed: () {
                                                              if (widget.kurye != null) {
                                                                Navigator.of(context).push(MaterialPageRoute(
                                                                    builder: (context) => KuryeMapScreenPage(
                                                                        baslangicPosition: CameraPosition(
                                                                            target: widget.kurye!.enlemBoylam!,
                                                                            zoom: 14.5),
                                                                        kurye: widget.kurye)));
                                                              }
                                                            },
                                                            child: const Text("Yol Tarifi")),
                                                      ],
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return Dialog(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(15),
                                                                    child: FutureBuilder(
                                                                        future: getLocationInfo(
                                                                            talepRepository.talepler[0].customerKonum),
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
                  );
                },
                itemCount: talepRepository.talepler.isEmpty ? 1 : talepRepository.talepler.length,
              ),
            ),
          ],
        ),
      );
    }
    return const Scaffold();
  }

  Future<void> talepleriHazirla() async {
    if (widget.rol == "musteri") {
      ref
          .read(talepprovider)
          .customerAktifTalepleriGetir(customerId: widget.uid)
          .then((value) => setState(() => talepSayisi = value))
          .catchError((e) =>
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Talepler getirilemedi. hata:$e"))));
    }
    if (widget.rol == "kurye") {
      //TODO kuryenin taleplerini getirt
      ref
          .read(talepprovider)
          .kuryeAktifTalepleriGetir(kuryeId: widget.uid)
          .then((value) => setState(() => talepSayisi = value))
          .catchError((e) =>
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Talepler getirilemedi. hata:$e"))));
    }
  }

  Future<Customer> loadUser() async {
    EasyLoading(context).buildLoading();
    final f = FirebaseFirestore.instance.collection("musteriler").doc(widget.uid);
    final result = f.get().then((musteri) async {
      EasyLoading(context).closeLoading();
      final data = musteri.data()!;
      return Customer.fromMap(data);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Kayıt getirilirken hata oluştu! Tekrar deneyin, hata:$e"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ));
      Future.error("Hata var allooooo");
      return e;
    });
    return result;
  }

  void buildTalepBitirDialog(int index, Talep talep, context) {
    showDialog(
        context: context,
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
          context: context,
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
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Talep bitirilirken bir hata oluştu. Hata:$e")));
    }
  }
}
