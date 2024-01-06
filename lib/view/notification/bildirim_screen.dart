import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kurye_map/core/constants/enum/kurye_arac_enum.dart';
import 'package:kurye_map/core/extension/latlng/location_info_mixin.dart';
import 'package:kurye_map/core/viewmodel/bildirim_view_model.dart';

import '../../core/components/easyloading/easy_loading.dart';
import '../../core/model/map/distance_model.dart';
import '../../core/viewmodel/distance_view_model.dart';
import '../../core/model/bildirim.dart';
import '../../core/model/person/kurye.dart';
import '../../core/model/talep.dart';
import '../../core/viewmodel/kurye_view_model.dart';
import '../../core/viewmodel/talep_view_model.dart';
import '../../core/components/mesafe_hesapla.dart';

class BildirimScreen extends ConsumerStatefulWidget {
  final String uid;
  final String rol;
  final Kurye? kurye;
  const BildirimScreen({Key? key, required this.uid, required this.rol, this.kurye}) : super(key: key);

  @override
  ConsumerState<BildirimScreen> createState() => _BildirimScreenState();
}

class _BildirimScreenState extends ConsumerState<BildirimScreen> with GetLocationInfo{
  int bildirimSayisi = 0;

  @override
  void initState() {
    EasyLoading(context).buildLoading();
    Future.delayed(const Duration(seconds: 0), () {
      bildirimleriHazirla()
          .then((value) => EasyLoading(context).closeLoading())
          .catchError((e) => EasyLoading(context).closeLoading());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bildirimRepository = ref.watch(bildirimprovider);
    final kuryeRepository = ref.watch(kuryeViewModelProvider);
    if (widget.rol == "musteri") {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bildirimler"),
          actions: [
            IconButton(
                onPressed: () {
                  bildirimleriHazirla();
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
            Text("Şu anda aktif $bildirimSayisi bildiriminiz var",
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var cb = bildirimRepository.customerBildirimler;
                  if (cb.isEmpty) {
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
                                    child: Text(cb[index].bildirimIcerik,
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
                                    cb[index].gonderenRol,
                                    style: GoogleFonts.roboto(
                                      color: const Color(0xFF7C8791),
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            !(cb.isNotEmpty)
                                ? const Text("")
                                : IconButton(
                                    onPressed: () {
                                      print('Talep oluştur');
                                    },
                                    icon: const Icon(Icons.info_outline, color: Colors.white, size: 30),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount:
                    bildirimRepository.customerBildirimler.isEmpty ? 1 : bildirimRepository.customerBildirimler.length,
              ),
            )
          ],
        ),
      );
    } else if (widget.rol == "kurye") {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bildirimler"),
          actions: [
            IconButton(
                onPressed: () async {
                  await bildirimleriHazirla();
                },
                icon: const Icon(Icons.refresh))
          ],
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black45,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Text("Aktif $bildirimSayisi bildirim var."),
            const SizedBox(height: 20),
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
                            !(kb.isNotEmpty)
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
                                                              Navigator.pop(context);
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return AlertDialog(
                                                                      title: const Text("Uyarı"),
                                                                      content: const Text(
                                                                          "Talebi eklemek istediğinize emin misiniz ?"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed: () async {
                                                                              Navigator.pop(context);
                                                                              await EasyLoading(context).buildLoading();
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
                                                                              await talepKabulEt(
                                                                                      kabulTalep, kabulBildirim, index)
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
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return AlertDialog(
                                                                      title: const Text("Uyarı"),
                                                                      content: const Text(
                                                                          "Talep bildirimini reddetmek istediğinize emin misiniz ?"),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed: () async {
                                                                              Navigator.pop(context);
                                                                              await EasyLoading(context).buildLoading();
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
                itemCount: bildirimRepository.kuryeBildirimler.isEmpty ? 1 : bildirimRepository.kuryeBildirimler.length,
              ),
            )
          ],
        ),
      );
    }
    return const Scaffold();
  }

  Future<void> bildirimleriHazirla() async {
    if (widget.rol == "musteri") {
      await ref.read(bildirimprovider).customerBildirimlerGetir(widget.uid).then((value) {
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
    if (widget.rol == "kurye") {
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

  void buildBildirimDetayDialog(Bildirim b) {
    String mesafeBilgisi = "";
    bool gercekVeriAktif = false;
    if (widget.kurye != null && widget.kurye!.enlemBoylam != null) {
      final m = MesafeMetrik.mesafeKmHesaplama(b.gonderenKonum, widget.kurye!.enlemBoylam!);
      mesafeBilgisi =
          "Tahmini ${(m * 1.6).toStringAsFixed(1)} km uzaklıkta ve ${(m <= 10 ? m * 4.5 : m * 3.6).toStringAsFixed(1)} dk mesafede";
    } else {
      mesafeBilgisi =
          "Konumunuz bulunamadı. Mesafe bilgisini görmek istiyorsanız konumunuzu ekleyip uygulamayı yeniden başlatın.";
    }
    showDialog(
        context: context,
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
                      gercekVeriAktif && widget.kurye != null
                          ? FutureBuilder(
                              future: kuryeKonumHesapla(widget.kurye!, b.gonderenKonum),
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

  Future<Distance?> kuryeKonumHesapla(Kurye kurye, LatLng customerKonum) async {
    //TODO burayı düzelt direk kuryeyi almak yerine onun konumuyla işlem yapsın.
    // if (kurye == null) return null;
    if (kurye.enlemBoylam == null) return null;
    var konum = await DistanceViewModel.getDistance(
        baslangic: customerKonum, hedef: kurye.enlemBoylam!, arac: KuryeArac.DRIVING);
    return konum;
  }
}
