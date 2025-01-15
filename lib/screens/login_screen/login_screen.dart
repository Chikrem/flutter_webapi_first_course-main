import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/models/journal.dart';
import 'package:teste1/screens/common/dialog.dart';
import 'package:teste1/screens/common/exception_dialog.dart';
import 'package:teste1/service/auth_service.dart';
import 'package:teste1/service/journal_service.dart';

// Tela de Login
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Controllers para capturar entrada de texto (e-mail e senha)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instância de AuthService para autenticação
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(width: 8),
          color: Colors.white,
        ),
        child: Form(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Ícone e texto de apresentação
                  const Icon(
                    Icons.bookmark,
                    size: 64,
                    color: Colors.brown,
                  ),
                  const Text(
                    "Simple Journal",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "por Alura",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(thickness: 2),
                  ),
                  const Text("Entre ou Registre-se"),
                  // Campo para e-mail
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      label: Text("E-mail"),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  // Campo para senha
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(label: Text("Senha")),
                    keyboardType: TextInputType.visiblePassword,
                    maxLength: 16,
                    obscureText: true,
                  ),
                  // Botão de continuar
                  ElevatedButton(
                    onPressed: () {
                      login(context);
                    },
                    child: const Text("Continuar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Função de login
  login(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Realiza o login
    _authService.login(email: email, password: password).then(
      (resultLogin) {
        if (resultLogin) {
          // Redireciona para a tela inicial após login
          Navigator.pushReplacementNamed(context, "home");
        }
      },
    ).catchError(
      // Trata exceções genéricas
      (error) {
        showExceptionDialog(context, content: error.toString());
      },
      test: (error) => error is Exception,
    ).catchError(
      // Trata usuário não encontrado
      (error) {
        showConfirmationDialog(
          context,
          content:
              "Deseja criar um novo usuário com email $email e a senha $password?",
          affirmativeOption: "CRIAR",
        ).then((value) {
          if (value != null && value) {
            // Realiza o registro de um novo usuário
            _authService
                .register(email: email, password: password)
                .then((resultRegister) {
              if (resultRegister) {
                Navigator.pushReplacementNamed(context, "home");
              }
            });
          }
        });
      },
      test: (error) => error is UserNotFoundException,
    ).catchError(
      // Trata tempo limite de resposta do servidor
      (error) {
        showExceptionDialog(context,
            content:
                "O servidor demorou para responder, tente novamente mais tarde.");
      },
      test: (error) => error is TimeoutException,
    );
  }
}

// Função para criar um Journal padrão com mensagem de boas-vindas
Future<void> _createDefaultJournal() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt("id");
  String? token = prefs.getString("accessToken");

  if (userId != null && token != null) {
    // Criação de um Journal padrão com mensagem de boas-vindas e data atual
    Journal defaultJournal = Journal.empty(
      id: userId,
      welcomeMessage:
          "Bem-vindo ao seu diário! Hoje é ${DateTime.now().toLocal().toString().split(" ")[0]}",
    );

    JournalService journalService = JournalService();
    bool success = await journalService.register(defaultJournal);
    if (success) {
      print('Journal padrão registrado com sucesso!');
    } else {
      print('Erro ao registrar journal padrão.');
    }
  }
}
