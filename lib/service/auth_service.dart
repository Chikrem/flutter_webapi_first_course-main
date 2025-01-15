import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/service/webclient.dart';

class AuthService {
  // URL base para as requisições, definida na classe WebClient
  String url = WebClient.url;
  // Cliente HTTP configurado com possíveis interceptores (se aplicável)
  http.Client client = WebClient().client;

  // Método para realizar o login do usuário
  Future<bool> login({required String email, required String password}) async {
    // Faz uma requisição POST para a rota de login
    http.Response response = await client.post(
      Uri.parse("${url}login"),
      body: {
        "email": email,
        "password": password,
      },
    );

    // Trata erros de autenticação com base no status HTTP
    if (response.statusCode != 200) {
      // Decodifica o corpo da resposta para identificar o motivo do erro
      String content = json.decode(response.body);
      switch (content) {
        // Caso o usuário não seja encontrado, lança uma exceção específica
        case "Cannot find user":
          throw UserNotFoundException();
      }
      // Para outros erros, lança uma exceção genérica com a mensagem do servidor
      throw HttpException(response.body);
    } else {
      print("Login Efetuado com Sucesso!");
    }

    // Salva as informações do usuário localmente (token, email e ID)
    saveUserInfos(response.body);

    return true; // Retorna true indicando sucesso
  }

  // Método para registrar um novo usuário
  Future<bool> register({required String email, required String password}) async {
    // Faz uma requisição POST para a rota de registro
    final response = await client.post(
      Uri.parse("${url}register"),
      body: {
        "email": email,
        "password": password,
      },
    );

    // Verifica se o status HTTP não é o esperado (201 - Criado)
    if (response.statusCode != 201) {
      // Lança uma exceção com a mensagem do servidor
      throw HttpException(response.body);
    }

    return true; // Retorna true indicando sucesso
  }

  // Método para salvar as informações do usuário localmente usando SharedPreferences
  saveUserInfos(String body) async {
    // Decodifica a resposta JSON para um mapa
    Map<String, dynamic> map = json.decode(body);

    // Extrai o token de acesso, email e ID do usuário
    String token = map["accessToken"];
    String email = map["user"]["email"];
    int id = map["user"]["id"];

    // Salva as informações do usuário no SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("accessToken", token);
    prefs.setString("email", email);
    prefs.setInt("id", id);

    // Log para verificar o token salvo
    String? tokenSalvo = prefs.getString("accessToken");
    print(tokenSalvo);
  }

  // Método para remover as informações do usuário do SharedPreferences
  deleteUserInfos() async {
    // Obtém a instância do SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove o token, ID e email do usuário
    prefs.remove("accessToken");
    prefs.remove("id");
    prefs.remove("email");
  }
}

// Exceção personalizada para quando o usuário não é encontrado
class UserNotFoundException implements Exception {}
