import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:teste1/service/http_interceptors.dart';

class JournalService{
  static const String url = "http://192.168.0.164:3000/";
  static const String resource = "learnhttp/";

  http.Client client = InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  String getUrl(){
    return "$url$resource";
  }

  void register(String content) async {
    var response = await client.post(
      Uri.parse(getUrl()),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'content': content}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Registro bem-sucedido: ${response.body}');
    } else {
      print('Falha no registro: ${response.statusCode}');
    }
  }

  Future<String> get () async {
    http.Response response = await client.get(Uri.parse(getUrl()));
    print(response.body);
    return response.body;
  }

}