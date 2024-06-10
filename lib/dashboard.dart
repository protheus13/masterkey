import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatefulWidget {
  final String matricula;
  final Map<String, dynamic> ambiente;
  final String barcodeScanRes;
  // ignore: non_constant_identifier_names
  final int ambiente_id;
  // ignore: non_constant_identifier_names
  const DashBoard(
      {super.key,
      required this.matricula,
      required this.ambiente,
      required this.barcodeScanRes,
      required this.ambiente_id});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool port = false;
  bool ilu = false;
  bool arcond = false;
  bool fec = false;
  String stport = "";
  static const String api = "https://35d5-177-37-198-158.ngrok-free.app/";
  //https://0def-177-37-198-158.ngrok-free.app
// ignore: non_constant_identifier_names
  Future<void> _criarLogs(
      String userMatricula, String acao, String log, int amb_id) async {
    const url = 'https://0def-177-37-198-158.ngrok-free.app/logs';
    // Obter a hora local do dispositivo
    var now = DateTime.now().toLocal();
    // Formatar a hora no fuso horário local
    String datetime = DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);
    // ignore: avoid_print
    print('ambientes_id print: $amb_id');
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

    if (response.statusCode == 200) {
      // ignore: avoid_print
      print('Log criado com sucesso');
    } else {
      // ignore: avoid_print
      print('Erro na criação do log: ${response.statusCode}');
    }
  }

  Future<void> _atualizaStatus(String field, bool value, bool door, bool ligth,
      bool refrigerate, bool fec) async {
    final url = Uri.parse(
        'https://0def-177-37-198-158.ngrok-free.app/ambientes/${widget.ambiente['topico']}/atualizaStatus');

    final Map<String, dynamic> body = {
      field: value,
      'status_port': port,
      'status_ilu': ilu,
      'status_arcond': arcond,
      'status_fec': fec
    };
    // ignore: avoid_print
    print(jsonEncode(body));
    // ignore: avoid_print
    print({widget.ambiente['topico']});

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        if (field == 'status_port') {
          port = value == true;
        } else if (field == 'status_ilu') {
          ilu = value == true;
        } else if (field == 'status_arcond') {
          arcond = value == true;
        }
      });
      // ignore: avoid_print
      print('Status atualizado com sucesso');
    } else {
      // ignore: avoid_print
      print('Erro na atualização do status: ${response.statusCode}');
    }
  }

  void _initializaVariaveis() {
    port = widget.ambiente['status_port'] == 1 ? true : false;
    ilu = widget.ambiente['status_ilu'] == 1 ? true : false;
    arcond = widget.ambiente['status_arcond'] == 1 ? true : false;
    fec = widget.ambiente['status_fec'] == 1 ? true : false;
  }

//função de conexão do protocolo MQTT
  Future<MqttServerClient> _connectToMQTTBroker() async {
    // ignore: prefer_const_declarations
    final String mqttBrokerURL = 'tcp://0.tcp.sa.ngrok.io';
    // ignore: prefer_const_declarations
    final int mqttPort = 19376; // or any other port if required
    // ignore: prefer_const_declarations
    final String clientID = 'FlutterMQTTClient';

    final MqttServerClient client = MqttServerClient(mqttBrokerURL, clientID);
    client.port = mqttPort;
    client.keepAlivePeriod = 20;
    client.onConnected = () {
      // ignore: avoid_print
      print('Conectado ao broker MQTT');
    };
    client.onDisconnected = () {
      // ignore: avoid_print
      print('Disconectado do Broker MQTT');
    };
    client.onUnsubscribed = (String? topic) {
      // ignore: avoid_print
      print('Cancelamento de inscrição no tópico: $topic');
    };
    client.onSubscribed = (String topic) {
      // ignore: avoid_print
      print('Inscrição no tópico: $topic');
    };
    client.onSubscribeFail = (String topic) {
      // ignore: avoid_print
      print('Falha ao se inscrver no tópico: $topic');
    };

    try {
      await client.connect();
    } catch (e) {
      // ignore: avoid_print
      print('Exceção: $e');
      client.disconnect();
    }

    return client;
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }

// ignore: unused_element
  void _publishMessage(MqttServerClient client, String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    final payload = builder.payload;
    if (payload == null) {
      // ignore: avoid_print
      print('Falha ao criar mensagem útil para sistema: $message');
      return;
    }
    client.publishMessage(topic, MqttQos.exactlyOnce, payload);
  }

// ignore: unused_field
  late MqttServerClient _client;

  @override
  void initState() {
    super.initState();
    _initializaVariaveis();
    _connectToMQTTBroker().then((value) => _client = value);
  }

  void _fecEletroima() {
    setState(() {
      port = !port; // inverter o estado atual
      if (port) {
        stport = "aberta";
      } else {
        stport = "fechada";
      }
      final actionTopic1 = '${widget.ambiente['topico']}/port/cmnd/power';
      String message = port ? "OFF" : "ON";
      _publishMessage(_client, actionTopic1, message);
      _criarLogs(widget.matricula, "porta", stport, widget.ambiente_id);
    });
  }

  void _fecFechoEletronic() {
    setState(() {
      port = !port; // inverter o estado atual
      if (!port) {
        stport = "aberta";
      } else {
        stport = "fechada";
      }
      final actionTopic1 = '${widget.ambiente['topico']}/port/cmnd/power';
      String message = port ? "ON" : "OFF";
      _publishMessage(_client, actionTopic1, message);
      _criarLogs(widget.matricula, "porta", stport, widget.ambiente_id);
    });
  }

  void _popupLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tem certeza que quer deslogar do aplicativo?'),
          content: const Text('Logout efetuado com sucesso!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    const String arcon =
        "{\"Protocol\":\"COOLIX\",\"Bits\":24,\"Data\":\"0xB2BF00\",\"DataLSB\":\"0x4DFD00\",\"Repeat\":0,\"IRHVAC\":{\"Vendor\":\"COOLIX\",\"Model\":-1,\"Mode\":\"Cool\",\"Power\":\"On\",\"Celsius\":\"On\",\"Temp\":17,\"FanSpeed\":\"Auto\",\"SwingV\":\"Off\",\"SwingH\":\"Off\",\"Quiet\":\"Off\",\"Turbo\":\"Off\",\"Econo\":\"Off\",\"Light\":\"Off\",\"Filter\":\"Off\",\"Clean\":\"Off\",\"Beep\":\"Off\",\"Sleep\":-1}}";
    const String arcoff =
        "{\"Protocol\":\"COOLIX\",\"Bits\":24,\"Data\":\"0xB27BE0\",\"DataLSB\":\"0x4DDE07\",\"Repeat\":0,\"IRHVAC\":{\"Vendor\":\"COOLIX\",\"Model\":-1,\"Mode\":\"UNKNOWN\",\"Power\":\"Off\",\"Celsius\":\"On\",\"Temp\":2.5,\"FanSpeed\":\"UNKNOWN\",\"SwingV\":\"Off\",\"SwingH\":\"Off\",\"Quiet\":\"Off\",\"Turbo\":\"Off\",\"Econo\":\"Off\",\"Light\":\"Off\",\"Filter\":\"Off\",\"Clean\":\"Off\",\"Beep\":\"Off\",\"Sleep\":-1}}";
    //ajusta o tamanho da fonte conforme tamanho da tela
    double fontSize = screenSize.height > 750 ? 16 : 10;
    double fontSize2 = screenSize.height > 750 ? 20 : 15;

    //ajusta o tamanho da imagem na tela
    double imageSize = screenSize.height > 750 ? 170 : 150;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Mini Curso Sistemas IoT - UFC',
            style: TextStyle(
              fontSize: fontSize2,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          actions: [
            //botão para resetar dados de login no canto superior direito da appBar
            IconButton(
                onPressed: () {
                  _popupLogout(context);
                },
                icon: const Icon(Icons.logout_sharp))
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //mostra na tela o Bloco e o Ambiente logado.
                Text('Bloco: ${widget.ambiente['bloco']}',
                    style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.bold)),
                Text('Ambiente: ${widget.ambiente['ambiente']}',
                    style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () async {
                      //função para alternar botão de abrir a porta
                      if (fec) {
                        _fecEletroima();
                      } else {
                        _fecFechoEletronic();
                        await Future.delayed(const Duration(seconds: 1));
                        _fecFechoEletronic();
                      }
                      //await _atualizaStatus('status_port', port ? true : false);
                      await _atualizaStatus('status_port', port ? true : false,
                          port, ilu, arcond, fec);
                    },
                    child: Image.asset(
                      port ? 'assets/door_closed.png' : 'assets/door_open.png',
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        ilu = !ilu; // inverter o estado atual
                        String message = ilu ? "ON" : "OFF";
                        final actionTopic3 =
                            '${widget.ambiente['topico']}/ilu/cmnd/power';
                        _publishMessage(_client, actionTopic3, message);
                        if (message == "ON") {
                          _criarLogs(widget.matricula, "iluminação", "ligado",
                              widget.ambiente_id);
                          //print(widget.ambiente_id);
                        } else {
                          _criarLogs(widget.matricula, "iluminação",
                              "desligado", widget.ambiente_id);
                        }
                      });
                      //await _atualizaStatus('status_ilu', ilu ? true : false);
                      await _atualizaStatus('status_port', port ? true : false,
                          port, ilu, arcond, fec);
                    },
                    child: Image.asset(
                      ilu ? 'assets/ligth_on.png' : 'assets/ligth_off.png',
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        arcond = !arcond; // inverter o estado atual
                        String message = arcond ? arcon : arcoff;
                        _publishMessage(
                            _client,
                            'cmnd/${widget.ambiente['topico']}/arcond/irsend',
                            message);
                        if (message == arcon) {
                          _criarLogs(widget.matricula, "ar condicionado",
                              "ligado", widget.ambiente_id);
                        } else {
                          _criarLogs(widget.matricula, "ar condicionado",
                              "desligado", widget.ambiente_id);
                        }
                      });
                      //await _atualizaStatus('status_arcond', arcond ? true : false);
                      await _atualizaStatus('status_port', port ? true : false,
                          port, ilu, arcond, fec);
                    },
                    child: Image.asset(
                      arcond ? 'assets/arcond_on.png' : 'assets/arcond_off.png',
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
