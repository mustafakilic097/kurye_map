import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  BaseState() {
    pageController = PageController();
  }
  ThemeData get themeData => Theme.of(context);

  late PageController pageController;
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int itemIndex) {
    this._currentIndex = itemIndex;
  }

  String get uid => FirebaseAuth.instance.currentUser?.uid ?? "-1";

  double dynamicHeight(double value) => MediaQuery.sizeOf(context).height * value;
  double dynamicWidth(double value) => MediaQuery.sizeOf(context).width * value;
}
