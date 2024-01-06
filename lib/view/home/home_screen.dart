import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kurye_map/core/base/state/base_state.dart';
import 'package:kurye_map/view/home/customer_screen.dart';

import '../settings/location_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: PageView.builder(
        controller: pageController,
        itemCount: 2,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return const CustomerScreen();
            case 1:
              return const LocationFormScreen();
            default:
              return const CustomerScreen();
          }
        },
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  PreferredSizeWidget get appBar => AppBar(
          backgroundColor: Colors.indigo.shade500,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black45),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(5),
            child: Divider(
              thickness: 2,
              color: Colors.black45,
              height: 2,
            ),
          ),
          title: Text(
            "Müşteri Paneli",
            style: GoogleFonts.roboto(color: Colors.indigo.shade50, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationFormScreen(),
                      ));
                },
                icon: const Icon(
                  Icons.settings,
                )),
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.exit_to_app))
          ]);

  Widget get bottomNavigationBar => BottomNavigationBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.person_2), label: "Hesabım"),
        ],
        onTap: (value) {
          pageController.jumpToPage(value);
        },
      );
}
