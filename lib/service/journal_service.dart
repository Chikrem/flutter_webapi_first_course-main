import 'dart:convert';

import 'package:http/http.dart' as http;

class JournalService{
  static const String url = "http://192.168.0.164:3000/";
  static const String resource = "learnhttp/";

  String getUrl(){
    return "$url$resource";
  }

  void register(String content) async {
    var response = await http.post(
      Uri.parse(getUrl()),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'content': content}),
    );
    if (response.statusCode == 200) {
      print('Registro bem-sucedido: ${response.body}');
    } else {
      print('Falha no registro: ${response.statusCode}');
    }
  }

  Future<String> get () async {
    http.Response response = await http.get(Uri.parse(getUrl()));
    print(response.body);
    return response.body;
  }

}