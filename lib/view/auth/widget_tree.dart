import 'package:flutter/material.dart';
import 'package:kurye_map/core/base/state/base_state.dart';
import 'package:kurye_map/view/auth/loading_screen.dart';
import 'package:kurye_map/view/home/home_screen.dart';

import '../../core/init/auth/auth.dart';
import 'login_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends BaseState<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        if (snapshot.hasData && uid != "-1") {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
