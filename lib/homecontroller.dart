// ignore_for_file: avoid_print, unnecessary_import, non_constant_identifier_names

import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:acess_controll/dashboard.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class HomeController extends GetxController {
  var valorqrcode = '';

  final String matricula;

  // ignore: prefer_typing_uninitialized_variables
  var ambiente, item;

  HomeController({required this.matricula});

  Future<List<dynamic>> buscarAmbiente(String topico) async {
    final url = Uri.parse(
        'https://0def-177-37-198-158.ngrok-free.app/ambientes/$topico');
    try {
      final response = await http.get(url);

      // ignore: duplicate_ignore
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        print('responseData: $decodedResponse');
        return decodedResponse;
      } else {
        print('Status code: ${response.statusCode}');
        print('Server response: ${response.body}');
        throw Exception(
            'Erro ao buscar ambiente - Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na conexão com o servidor: $e');
      throw Exception('Erro ao buscar ambiente - Exception: $e');
    }
  }

  Future<void> _criarLogs(
      String userMatricula, String acao, String log, int amb_id) async {
    const url = 'https://0def-177-37-198-158.ngrok-free.app/logs';
    // Obter a hora local do dispositivo
    var now = DateTime.now().toLocal();
    // Formatar a hora no fuso horário local
    String datetime = DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);
    //print('ambientes_id print: $amb_id');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'matricula_id': userMatricula,
        'acao': acao,
        'log': log,
        'data': datetime,
        'ambientes_id': amb_id
      }),
    );

    // ignore: duplicate_ignore
    if (response.statusCode == 200) {
      print('Log criado com sucesso');
    } else {
      print('Erro na criação do log: ${response.statusCode}');
    }
  }

  Future<void> escanearQrCode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.QR);

    if (barcodeScanRes == '-1') {
      Get.snackbar('Cancelado', 'Leitura incorreta!');
    } else {
      valorqrcode = barcodeScanRes;
      try {
        ambiente = await buscarAmbiente(barcodeScanRes);
        print('Valor lido no QRCODE: $barcodeScanRes');
        bool encontrado = false;
        for (item in ambiente) {
          if (item.containsValue(valorqrcode)) {
            encontrado = true;
            break;
          }
        }
        if (encontrado) {
          Get.snackbar('QR Code ok', 'Acesso Autorizado!');
          int ambiente_id = item['id']; //pego o id da tabela ambientes
          _criarLogs(matricula, "leitor qrcode", "sucesso", ambiente_id);
          print("Matricula classe homecontroller: $matricula");
          Get.to(() => DashBoard(
              matricula: matricula,
              ambiente: item,
              barcodeScanRes: barcodeScanRes,
              ambiente_id: ambiente_id));
        } else {
          Get.snackbar('QR Code Nok', 'Acesso Negado!');
        }
        // ignore: duplicate_ignore
      } catch (e) {
        print('Erro ao buscar ambiente: $e');
        print('Valor retornado pela função buscarAmbiente: $ambiente');
        Get.snackbar('QR Cocde não cadastrado', 'Procure a administração!');
      }
      update();
    }
  }
}
