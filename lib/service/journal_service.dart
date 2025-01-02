import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:teste1/service/http_interceptors.dart';

import '../models/journal.dart';

class JournalService{
  static const String url = "http://192.168.0.164:3000/";
  static const String resource = "journals/";

  http.Client client = InterceptedClient.build(interceptors: [LoggingInterceptor()]);

  String getUrl(){
    return "$url$resource";
  }

  Future<bool> register(Journal journal) async {
    String jsonJournal = json.encode(journal.toMap());
    http.Response response = await client.post(
      Uri.parse(getUrl()),
      headers: {'Content-Type': 'application/json'}, // Adicionado
      body: jsonJournal,
    );

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }


  // void register(String content) async {
  //   var response = await client.post(
  //     Uri.parse(getUrl()),
  //     headers: {'Content-Type': 'application/json'},
  //     body: json.encode({'content': content}),
  //   );
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     print('Registro bem-sucedido: ${response.body}');
  //   } else {
  //     print('Falha no registro: ${response.statusCode}');
  //   }
  // }

  Future<String> get () async {
    http.Response response = await client.get(Uri.parse(getUrl()));
    print(response.body);
    return response.body;
  }

}