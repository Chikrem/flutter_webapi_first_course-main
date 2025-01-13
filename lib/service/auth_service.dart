import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:teste1/service/http_interceptors.dart';

class AuthService {
  static const String url = "http://192.168.56.1:3000/";

  http.Client client = InterceptedClient.build(
    interceptors: [LoggingInterceptor()],
  );

  Future<bool> login({required String email, required String password}) async {
    final response = await client.post(
      Uri.parse("${url}login"),
      body: {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode != 200) {
      String content = json.decode(response.body);
      switch (content) {
        case "Cannot find user":
          throw UserNotFoundException();
      }
      throw HttpException(response.body);
    } else {
      print("Erro ao efetuar login");
    }
    return true;
  }

  Future<void> register(String email, String password) async {
    final response = await client.post(
      Uri.parse("${url}register"),
      body: {
        "email": email,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      print("Cadastro efetuado com sucesso");
    } else {
      print("Erro ao efetuar cadastro");
    }
  }
}

class UserNotFoundException implements Exception {}
