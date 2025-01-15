// Importa bibliotecas necessárias
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/service/webclient.dart';
import '../models/journal.dart';

// Classe que gerencia as operações relacionadas ao Journal
class JournalService {
  // Recurso base utilizado nas requisições
  static const String resource = "journals/";

  // URL base e cliente HTTP configurado no WebClient
  String url = WebClient.url;
  http.Client client = WebClient().client;

  // Retorna a URL completa para o recurso
  String getURL() {
    return "$url$resource";
  }

  // Retorna uma URI para a URL do recurso
  Uri getUri() {
    return Uri.parse(getURL());
  }

  // Registra um novo Journal no servidor
  Future<bool> register(Journal journal) async {
    // Converte o objeto Journal para JSON
    String journalJSON = json.encode(journal.toMap());

    // Obtém o token de autenticação salvo localmente
    String token = await getToken();

    // Envia a requisição POST para criar o Journal
    http.Response response = await client.post(
      getUri(),
      headers: {
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: journalJSON,
    );

    // Verifica se a criação foi bem-sucedida (código 201)
    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  // Edita um Journal existente
  Future<bool> edit(Journal journal, String token) async {
    // Atualiza a data de modificação do Journal
    journal.updatedAt = DateTime.now();

    // Converte o objeto atualizado para JSON
    String jsonJournal = json.encode(journal.toMap());

    // Envia a requisição PUT para atualizar o Journal
    http.Response response = await client.put(
      Uri.parse(getURL() + journal.id),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token"
      },
      body: jsonJournal,
    );

    // Verifica se a atualização foi bem-sucedida (código 200)
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Retorna uma lista de Journals associados a um usuário
  Future<List<Journal>> getAll(
      {required String id, required String token}) async {
    // Envia a requisição GET para buscar os Journals do usuário
    http.Response response = await client.get(
      Uri.parse("${url}users/$id/journals"),
      headers: {"Authorization": "Bearer $token"},
    );

    List<Journal> result = [];

    // Se a requisição falhar, retorna uma lista vazia
    if (response.statusCode != 200) {
      return result;
    }

    // Converte a resposta JSON para uma lista de objetos Journal
    List<dynamic> jsonList = json.decode(response.body);
    for (var jsonItem in jsonList) {
      result.add(Journal.fromMap(jsonItem));
    }

    return result;
  }

  // Remove um Journal pelo ID
  Future<bool> remove(String id, String token) async {
    // Envia a requisição DELETE para remover o Journal
    http.Response response = await client.delete(
      Uri.parse("${getURL()}$id"),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Verifica se a remoção foi bem-sucedida (código 200)
    if (response.statusCode == 200) {
      return true;
    }

    return false;
  }

  // Obtém o token de autenticação salvo nas preferências locais
  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token != null) {
      return token;
    }
    return '';
  }
}
