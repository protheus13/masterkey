import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchUsuarios() async {
  final response =
      await http.get(Uri.parse('http://192.168.1.102:3000/usuarios'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load users');
  }
}
