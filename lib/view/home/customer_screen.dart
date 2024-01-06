import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/base/state/base_state.dart';
import '../../core/base/view/base_view.dart';
import '../../core/components/dialog/dialog_manager.dart';
import '../../core/constants/enum/kurye_arac_enum.dart';
import '../../core/model/bildirim.dart';
import '../../core/model/map/distance_model.dart';
import '../../core/model/person/customer.dart';
import '../../core/model/person/kurye.dart';
import '../../core/viewmodel/bildirim_view_model.dart';
import '../../core/viewmodel/customer_view_model.dart';
import '../../core/viewmodel/distance_view_model.dart';
import '../../core/viewmodel/kurye_view_model.dart';
import '../notification/bildirim_screen.dart';
import '../request/talep_screen.dart';
import '../settings/location_form_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  BaseState<StatefulWidget> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends BaseState<CustomerScreen> {
  late KuryeViewModel kuryeViewModel;
  late CustomerViewModel customerViewModel;
  late WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return BaseView(
      onPageBuilder: (BuildContext context, value) {
        kuryeViewModel = ref.watch(kuryeViewModelProvider);
        customerViewModel = ref.watch(customerViewModelProvider);
        return scaffoldBody;
      },
      viewModel: customerViewModelProvider,
      onModelReady: (model) {
        ref = model;
        init;
      },
    );
  }

  Future<void> get init async {
    await Future.delayed(Duration.zero);
    await ref.read(customerViewModelProvider).getCustomer().then((customer) async {
      if (customer.enlemBoylam != null) {
        await ref
            .read(kuryeViewModelProvider)
            .yakindakiAktifKuryeleriGetir(customerKonum: customer.enlemBoylam!)
            .catchError((e) {
          DialogManager.showErrorSnackbar(context, e);
          return e;
        });
      } else {
        DialogManager.showErrorSnackbar(context, "Kullanıcının konum bilgisi yok");
      }
    }).catchError((e) {
      DialogManager.showErrorSnackbar(context, "Kullanıcının kaydı getirilirken hata oluştu, Hata:$e");
    });
  }

  Widget get scaffoldBody => RefreshIndicator(
        onRefresh: () => refreshYakinKurye,
        child: Column(
          children: [
            buildHeadArea,
            const Divider(),
            Align(
              alignment: const AlignmentDirectional(-0.95, 0),
              child: Text('Yakındaki bazı kuryeler', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return buildCardArea(index);
                },
                itemCount: kuryeViewModel.yakinKuryeler.length > 5 ? 5 : kuryeViewModel.yakinKuryeler.length,
              ),
            ),
          ],
        ),
      );

  Widget get buildHeadArea => SizedBox(
        height: dynamicHeight(0.25),
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildYakinKurye,
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [taleplerNavigateButton, customerProfile, bildirimlerNavigateButton],
            ),
          ],
        ),
      );

  Widget buildCardArea(int index) => Padding(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: dynamicWidth(0.5),
                        child: Text(
                            'Yaklaşık ${(kuryeViewModel.yakinMesafeler[index] <= 10 ? kuryeViewModel.yakinMesafeler[index] * 4 + 0.1 : kuryeViewModel.yakinMesafeler[index] * 3 + 0.1).toStringAsFixed(1)} dakika uzaklıkta',
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
                        'Kurye ${index + 1}',
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF7C8791),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async => await musteriTalepGonder,
                  child: const Text("Talep Oluştur"),
                ),
              ],
            ),
          ),
        ),
      );

  Widget get buildYakinKurye => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Yakınlarda ",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF03A9F4),
            ),
          ),
          AnimatedFlipCounter(
            value: kuryeViewModel.yakinKuryeler.length,
            duration: const Duration(seconds: 1),
            textStyle: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF03A9F4),
            ),
          ),
          Text(
            " kurye aktif",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF03A9F4),
            ),
          ),
        ],
      );

  Widget get taleplerNavigateButton => Column(
        children: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => TalepScreen(rol: 'musteri', uid: uid)));
            },
            icon: const Icon(Icons.history),
            iconSize: 35,
            color: Colors.black,
          ),
          const Text("Talepler")
        ],
      );

  Widget get customerProfile => Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/customer.png',
              fit: BoxFit.cover,
            ),
          ),
          Text(
            "${customerViewModel.currentCustomer.ad} ${customerViewModel.currentCustomer.soyad}",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          )
        ],
      );

  Future<void> get refreshYakinKurye async {
    if (customerViewModel.currentCustomer.enlemBoylam != null) {
      await ref
          .read(kuryeViewModelProvider)
          .yakindakiAktifKuryeleriGetir(customerKonum: customerViewModel.currentCustomer.enlemBoylam!)
          .catchError((e) {
        DialogManager.showErrorSnackbar(context, e);
        return e;
      });
    }
  }

  Widget get bildirimlerNavigateButton => Column(
        children: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => BildirimScreen(rol: 'musteri', uid: uid)));
            },
            icon: const Icon(Icons.notifications_none),
            iconSize: 35,
            color: Colors.black,
          ),
          const Text("Bildirimler")
        ],
      );

  // Burada bulunan bazı appbar gibi kısımlar bir homescreen tarafından gelmeli burası customer screen olacak sadece
  // bu kısmın çoğu sunucu tarafında çözümlenecek. Ondan dolayı burasının sadece kod mantığında düzenlemeler yapmak yetecektir.
  Future<void> get musteriTalepGonder async {
    await ref.read(customerViewModelProvider).getCustomer().then((Customer c) async {
      //KULLANICI ve KURYE bilgisi getirme aşaması
      if (customerViewModel.currentCustomer.enlemBoylam == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: SizedBox(
            height: 75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Konum bilginiz olmadan sipariş oluşturulamaz", overflow: TextOverflow.fade),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LocationFormScreen()));
                      },
                      child: const Text("Konum Ekle")),
                )
              ],
            ),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ));
        throw Exception("Şuanki konumunuzu bulamadım. Konum servisini kontrol edip tekrar deneyin.");
      }
      await ref
          .read(kuryeViewModelProvider)
          .yakindakiAktifKuryeleriGetir(customerKonum: customerViewModel.currentCustomer.enlemBoylam!)
          .catchError((e) => ref
                  .read(kuryeViewModelProvider)
                  .yakindakiAktifKuryeleriGetir(customerKonum: customerViewModel.currentCustomer.enlemBoylam!)
                  .catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Yakındaki kuryeleri bulamıyorum.İnternetini kontrol eder misin?"),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ));
                return e;
              }));
      //Kullanıcı ve kurye bilgilerinin getirilmesinden sonra
      print(kuryeViewModel.yakinKuryeler.length);
      if (!mounted) {
        return;
      }
      await ref
          .read(customerViewModelProvider)
          .tumKuryeYakinlikHesapla(
            customerLoc: customerViewModel.currentCustomer.enlemBoylam!,
            kuryeler: kuryeViewModel.yakinKuryeler,
          )
          .then((List<Kurye>? value) async {
        if (value != null) {
          print("Sipariş oluşturuluyor");
          if (value[0].enlemBoylam == null) throw Exception("Kuryenin konumu ekli değil");
          await kuryeKonumHesapla(value[0].enlemBoylam!, customerViewModel.currentCustomer.enlemBoylam!)
              .then((ilkKuryeMesafe) {
            var icerik =
                "${ilkKuryeMesafe?.totalDistance} uzaklıkta ${ilkKuryeMesafe?.totalDuration} süre uzaklıkta bir sipariş var.";
            var bil = Bildirim(
                gonderenId: customerViewModel.currentCustomer.uid,
                aliciId: value[0].uid,
                gonderenRol: "musteri",
                aliciRol: "kurye",
                bildirimIcerik: icerik,
                bildirimAktif: true,
                gonderenKonum: customerViewModel.currentCustomer.enlemBoylam!);
            ref.read(bildirimprovider).bildirimGonder(bil, context).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(milliseconds: 800),
                content: Text("Kurye isteği gönderildi ✔"),
                dismissDirection: DismissDirection.startToEnd,
                backgroundColor: Colors.green,
              ));
            });
            String icerik2 = "Talebiniz oluşturuldu. Bir kurye onayladığında bildirim alıcaksınız.";
            var bil2 = Bildirim(
                gonderenId: "system",
                aliciId: uid,
                gonderenRol: "system",
                aliciRol: "musteri",
                bildirimIcerik: icerik2,
                bildirimAktif: true,
                gonderenKonum: customerViewModel.currentCustomer.enlemBoylam!);
            ref.read(bildirimprovider).bildirimGonder(bil2, context);
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Bilgi"),
                    content: const Text("Talep Başarıyla Oluşturuldu"),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Teşekkürler"))],
                  );
                });
          }).catchError((e) async {
            if (value[1].enlemBoylam == null) throw Exception("Kuryenin konumu ekli değil");
            await kuryeKonumHesapla(value[1].enlemBoylam!, customerViewModel.currentCustomer.enlemBoylam!)
                .then((ilkKuryeMesafe) {
              var icerik =
                  "${ilkKuryeMesafe?.totalDistance} uzaklıkta ${ilkKuryeMesafe?.totalDuration} süre uzaklıkta bir sipariş var.";
              var bil = Bildirim(
                  gonderenId: customerViewModel.currentCustomer.uid,
                  aliciId: value[1].uid,
                  gonderenRol: "musteri",
                  aliciRol: "kurye",
                  bildirimIcerik: icerik,
                  bildirimAktif: true,
                  gonderenKonum: customerViewModel.currentCustomer.enlemBoylam!);
              ref.read(bildirimprovider).bildirimGonder(bil, context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(milliseconds: 800),
                content: Text("Kurye isteği gönderildi ✔"),
                dismissDirection: DismissDirection.startToEnd,
                backgroundColor: Colors.green,
              ));
              print("${bil.bildirimIcerik} ${bil.aliciId}");
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Kurye mesafesini getiremiyorum.İnternetini kontrol eder misin? hata:$e"),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ));
            });
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Yakındaki kuryleri bulurken bir sorun oluştu.İnternetini kontrol eder misin?"),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Kuryelerle aranızdaki mesafeyi bulamıyorum.İnternetini kontrol eder misin?",
            overflow: TextOverflow.fade,
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ));
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Kullanıcı bilgileri getirilemedi. İnternet bağlantınızı kontrol edin"),
        backgroundColor: Colors.orange,
      ));
    });
  }

  Future<Distance?> kuryeKonumHesapla(LatLng kuryeKonum, LatLng customerKonum) async {
    var konum =
        await DistanceViewModel.getDistance(baslangic: customerKonum, hedef: kuryeKonum, arac: KuryeArac.DRIVING);
    return konum;
  }
}
