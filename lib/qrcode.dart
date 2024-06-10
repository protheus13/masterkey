// ignore_for_file: unused_element, depend_on_referenced_packages, use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:acess_controll/homecontroller.dart';
import 'package:acess_controll/homeqrcode.dart';

class Qrcode extends StatefulWidget {
  final String nome, matricula;
  const Qrcode({Key? key, required this.nome, required this.matricula})
      : super(key: key);

  @override
  State<Qrcode> createState() => _QrcodeState();
}

class _QrcodeState extends State<Qrcode> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
        GetPage(
          name: '/',
          // page: () => Homeqrcode(
          //   nome: widget.nome, matricula: widget.matricula,
          // ),
          page: () {
            final homeController = HomeController(matricula: widget.matricula);
            print('Matricula classe qrcode: ${widget.matricula}');
            return Homeqrcode(
              nome: widget.nome,
              homeController: homeController,
              matricula: widget.matricula,
            );
          },
        ),
      ],
    );
  }
}
