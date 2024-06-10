// ignore_for_file: unnecessary_string_interpolations
// ignore: depend_on_referenced_packages
import 'package:acess_controll/homecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homeqrcode extends StatelessWidget {
  final String nome, matricula;

  const Homeqrcode(
      {super.key,
      required this.nome,
      required this.matricula,
      required HomeController homeController});

  @override
  Widget build(BuildContext context) {
    //pega o tamanho da tela
    var screenSize = MediaQuery.of(context).size;

    //ajusta o tamanho da fonte conforme tamanho da tela
    double fontSize = screenSize.height > 750 ? 20 : 12;
    //ajusta o tamanho da imagem na tela
    double imageSize1 = screenSize.height > 750 ? 220 : 180;
    double imageSize2 = screenSize.height > 750 ? 50 : 30;

    return Scaffold(
      appBar: AppBar(
        // ignore: prefer_const_constructors
        title: Center(
            child: Text(
          'Mini Curso Sistemas IoT - UFC',
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
          ),
        )),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            // ignore: prefer_const_constructors
            GetBuilder<HomeController>(
              init: HomeController(matricula: matricula),
              builder: (controller) => Text(
                //controller.valorCodigoBarras,
                "",
                style: Get.theme.textTheme.headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Image.asset(
                            'assets/ufc.png',
                            width: imageSize1,
                            height: imageSize1,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Seja bem vindo, ',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              TextSpan(
                                text: '$nome',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black, // exemplo de outra cor
                                ),
                              ),
                              TextSpan(
                                text:
                                    '! Demonstração de Sistema IoT - UFC. Para ter acesso a dashboard de controle clique no botão abaixo.',
                                style: TextStyle(
                                    fontSize: fontSize,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: TextButton.icon(
                onPressed: () {
                  //_criarLogs(matricula, "leitor qrcode", "sucesso", 17);
                  Get.find<HomeController>().escanearQrCode();
                },
                icon: Image.asset(
                  'assets/qrcode.png',
                  width: imageSize2,
                  height: imageSize2,
                ),
                label: Text(
                  'QR CODE',
                  style: TextStyle(fontSize: fontSize, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
