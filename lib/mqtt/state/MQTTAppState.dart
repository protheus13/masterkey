// ignore: file_names
import 'package:flutter/material.dart';

enum MQTTAppConectionState { conectado, disconectado, conectando }

class MQTTAppState with ChangeNotifier {
  // ignore: prefer_final_fields, unused_field
  MQTTAppConectionState _appConectionState = MQTTAppConectionState.disconectado;
  String _receivedText = "";
  String _historyText = "";

//função para receber um texto
  void setReceivedText(String text) {
    _receivedText = text;
    // ignore: prefer_interpolation_to_compose_strings
    _historyText = _historyText + '\n' + _receivedText;
    notifyListeners();
  }

//função para realizar conexão com o mqtt
  void setAppConnectionState(MQTTAppConectionState state) {
    _appConectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTTAppConectionState get getAppConnectionState => _appConectionState;
}
