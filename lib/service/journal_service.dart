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

  Future<bool> edit(Journal journal) async {
    String jsonJournal = json.encode(journal.toMap());
    http.Response response = await client.put(
      Uri.parse(getUrl() + journal.id),
      headers: {'Content-Type': 'application/json'}, // Adicionado
      body: jsonJournal,
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<Journal>> getAll () async {
    http.Response response = await client.get(Uri.parse(getUrl()));

    if(response.statusCode != 200){
      throw Exception();
    }

    List<Journal> list = [];

    List<dynamic> listDynamic = json.decode(response.body);

    for (var jsonMap in listDynamic){
      list.add(Journal.fromMap(jsonMap));
    }

    print(list.length);

    return list;
  }

}