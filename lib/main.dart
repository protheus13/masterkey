// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:acess_controll/homelogin.dart';

void main() {
  runApp(MaterialApp(
    //tirar o banner de debug do app em flutter
    debugShowCheckedModeBanner: false,
    home: WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: const HomeLogin(),
    ),
  ));
}
