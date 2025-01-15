// https://www.npmjs.com/package/json-server-auth

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/service/http_interceptors.dart';
import 'package:teste1/service/webclient.dart';

import '../models/journal.dart';

class JournalService {
  static const String resource = "journals/";

  String url = WebClient.url;
  http.Client client = WebClient().client;

  String getURL() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }

  Future<bool> register(Journal journal) async {
    String journalJSON = json.encode(journal.toMap());

    String token = await getToken();
    http.Response response = await client.post(
      getUri(),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: journalJSON,
    );

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<bool> edit(Journal journal, String token) async {
    String jsonJournal = json.encode(journal.toMap());
    http.Response response = await client.put(
      Uri.parse(getURL() + journal.id),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      }, // Adicionado
      body: jsonJournal,
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<Journal>> getAll(
      {required String id, required String token}) async {
    http.Response response = await client.get(
      Uri.parse("${url}users/$id/journals"),
      headers: {"Authorization": "Bearer $token"},
    );

    List<Journal> result = [];

    if (response.statusCode != 200) {
      //TODO: Criar uma exceção personalizada
      return result;
    }

    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonItem in jsonList) {
      result.add(Journal.fromMap(jsonItem));
    }

    return result;
  }

  Future<bool> remove(String id, String token) async {
    http.Response response = await client.delete(
      Uri.parse("${getURL()}$id"),
      headers: {
      'Authorization': 'Bearer $token'}
      );

    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token != null) {
      return token;
    }
    return '';
  }

}
