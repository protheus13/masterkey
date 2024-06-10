// ignore: file_names
// ignore_for_file: depend_on_referenced_packages, use_super_parameters, non_constant_identifier_names, avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:acess_controll/qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeLogin extends StatefulWidget {
  const HomeLogin({key}) : super(key: key);

  @override
  State<HomeLogin> createState() => _HomeLoginState();
}

class _HomeLoginState extends State<HomeLogin> {
  //criadas duas variaveis de controle para pegar os valores de login e senha do usuário
  TextEditingController siape = TextEditingController();
  TextEditingController senha = TextEditingController();
  bool _obscsenha = true;
  static const String api = "https://0def-177-37-198-158.ngrok-free.app";
  //texto de variavel que mostra alguma informação abaixo dos botoes
  String _infoText = "";
  //função que reseta campus da tela de login
  void _resetFields() {
    siape.text = "";
    senha.text = "";
  }

// ignore: unused_element
//função para criar os logs de login ao clicar no botão quando login bem sucedido
  Future<void> _criarLogs(
      String userMatricula, String acao, String log, int amb_id) async {
    const url = 'https://0def-177-37-198-158.ngrok-free.app/logs';
    // Obter a hora local do dispositivo
    var now = DateTime.now().toLocal();
    // Formatar a hora no fuso horário local
    String datetime = DateFormat('yyyy-MM-ddTHH:mm:ss').format(now);
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
      print('Log criado com sucesso');
    } else {
      print('Erro na criação do log: ${response.statusCode}');
    }
  }

//função para realizar login por consulta no BD através de API
// Future<void> _login(String matricula, String cpf) async {
//   const url = 'http://smart.sobral.ifce.edu.br:3000/login/';
//   final response = await http.post(
//     Uri.parse(url),
//     headers: {'Content-Type': 'application/json'},
//     body: jsonEncode({'matricula': matricula, 'cpf': cpf}),
//   );

//   if (response.statusCode == 200) {
//     final responseData = jsonDecode(response.body);
//     // ignore: avoid_print
//     print('responseData: $responseData'); // Adicionado print para verificar a resposta da API
//     if (responseData['success']) {
//       // ignore: avoid_print
//       print('Login bem-sucedido');
//       //chamar função _criarLogs();
//       _criarLogs(matricula, 'login', 'sucesso', 17);
//       setState(() {
//         _infoText = 'Login bem-sucedido';
//       });
//       // ignore: use_build_context_synchronously
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => Qrcode(
//             nome: responseData['nome'] ?? '',
//             matricula: matricula,
//             ),
//       ),
//     );
//     } else {
//       // ignore: avoid_print
//       print('Matrícula ou senha incorretos');
//       setState(() {
//         _infoText = 'Matrícula ou senha incorretos';
//       });
//     }
//   } else {
//     // ignore: avoid_print
//     print('Erro na requisição: ${response.statusCode}');
//     setState(() {
//       _infoText = 'Erro na requisição ${response.statusCode}';
//     });
//   }
// }

//função para realizar login por consulta no BD através de API
  Future<void> _login(String matricula, String cpf) async {
    const url = 'https://0def-177-37-198-158.ngrok-free.app/login/';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'matricula': matricula, 'cpf': cpf}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('responseData: $responseData');

      if (responseData['success']) {
        print('Login bem-sucedido');
        String token = responseData['token'];

        // Decodificar o token
        final jwt = JWT.decode(token);
        print(jwt.payload);
        Map<String, dynamic> payload = jwt.payload;

        final String userMatricula = payload['Matricula'];
        final String userName = payload['Nome'];
        _criarLogs(userMatricula, 'login', 'sucesso', 17);
        setState(() {
          _infoText = 'Login bem-sucedido';
        });

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Qrcode(
              nome: userName,
              matricula: matricula,
            ),
          ),
        );
      } else {
        print('Matrícula ou senha incorretos');
        setState(() {
          _infoText = 'Matrícula ou senha incorretos';
        });
      }
    } else {
      print('Erro na requisição: ${response.statusCode}');
      setState(() {
        _infoText = 'Erro na requisição ${response.statusCode}';
      });
    }
  }

  void loadLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? login = prefs.getString('login');
    String? password = prefs.getString('password');
    siape.text = login ?? '';
    senha.text = password ?? '';
  }

  @override
  void initState() {
    super.initState();
    loadLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    double fontSize = screenSize.height > 750 ? 25 : 20;
    double fontSize2 = screenSize.height > 750 ? 20 : 15;
    double fontSize3 = screenSize.height > 750 ? 20 : 12;
    //ajusta o tamanho da imagem na tela
    double imageSize = screenSize.height > 750 ? 250 : 350;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mini Curso Sistemas IoT - UFC',
          style: TextStyle(fontSize: fontSize2, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: [
          //botão para resetar dados de login no canto superior direito da appBar
          IconButton(
              onPressed: () {
                _resetFields();
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      backgroundColor: Colors.white,
      //centraliza todos os widgets no centro da tela
      body: Center(
        //o SingleChildScrollView é uma função para rolagem de widgets na tela, evitando erros por fundo de escala
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          //usa o widget coluna para dispor melhor os componentes na tela
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageSize,
                width: imageSize,
                child: const Image(image: AssetImage('assets/ufc.png')),
              ),
              // ignore: prefer_const_constructors
              //textfield para inserir os dados de login (siape)
              //como vamos pegar o valor dentro do textfield, n podemos usar o textfield como const
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Matrícula",
                    labelStyle:
                        TextStyle(color: Colors.black, fontSize: fontSize)),
                textAlign: TextAlign.center, //centraliza o texto
                style: TextStyle(color: Colors.black, fontSize: fontSize2),
                controller: siape,
              ),
              // ignore: prefer_const_constructors
              //texfield para parametros de senha, o resttante igual o anterior
              TextField(
                obscureText: _obscsenha,
                decoration: InputDecoration(
                  labelText: "Senha",
                  labelStyle:
                      TextStyle(color: Colors.black, fontSize: fontSize),
                  //botão com formato de olho para visualizar ou não a senha
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Escolha o ícone de acordo com o valor de _obscureText
                      _obscsenha ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      // Inverte o valor de _obscureText
                      setState(() {
                        _obscsenha = !_obscsenha;
                      });
                    },
                  ),
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: fontSize2),
                controller: senha,
              ),
              //o padding dá um espaçamento a gosto do desenvolvedor entre os widgets
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 35.0,
                  width: 250.0,
                  //botao com as funções de login e esqci minha senha abaixo
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        // ignore: deprecated_member_use
                        primary: Colors.black,
                        // ignore: deprecated_member_use
                        onPrimary: Colors.white,
                        backgroundColor: Colors.black),
                    //funcao onpressed, executa o que estiver dentro do botao
                    onPressed: () async {
                      _login(siape.text, senha.text);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('login', siape.text);
                      prefs.setString('password', senha.text);
                    }, //inserindo botao para efetuar login
                    child: Text(
                      'Efetuar login',
                      style: TextStyle(fontSize: fontSize3),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 35.0,
                width: 250.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      // ignore: deprecated_member_use
                      primary: Colors.black,
                      // ignore: deprecated_member_use
                      onPrimary: Colors.black,
                      backgroundColor: Colors.white),
                  onPressed: () {
                    _resetFields();
                    setState(() {
                      _infoText = "Coders Developers";
                    });
                  }, //inserindo botao para efetuar login
                  child: Text(
                    'Sobre',
                    style: TextStyle(fontSize: fontSize3),
                  ),
                ),
              ),
              Padding(
                // ignore: prefer_const_constructors
                padding: EdgeInsets.all(10.0),
                child: Text(
                  _infoText,
                  textAlign: TextAlign.center,
                  // ignore: prefer_const_constructors
                  style: TextStyle(color: Colors.black, fontSize: 15.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
