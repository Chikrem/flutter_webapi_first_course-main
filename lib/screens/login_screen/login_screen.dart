import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/models/journal.dart';
import 'package:teste1/screens/common/dialog.dart';
import 'package:teste1/service/auth_service.dart';
import 'package:teste1/service/journal_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Controller para capturar dados de TextField de E-mail e Senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instancia de AuthService
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(32),
        decoration:
            BoxDecoration(border: Border.all(width: 8), color: Colors.white),
        child: Form(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.bookmark,
                    size: 64,
                    color: Colors.brown,
                  ),
                  const Text(
                    "Simple Journal",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text("por Alura",
                      style: TextStyle(fontStyle: FontStyle.italic)),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Divider(thickness: 2),
                  ),
                  const Text("Entre ou Registre-se"),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      label: Text("E-mail"),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(label: Text("Senha")),
                    keyboardType: TextInputType.visiblePassword,
                    maxLength: 16,
                    obscureText: true,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        login(context);
                      },
                      child: const Text("Continuar")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

void login(BuildContext context) async {
  String email = _emailController.text;
  String password = _passwordController.text;

  try {
    bool resultLogin = await _authService.login(email: email, password: password);
    if (resultLogin) {
      Navigator.pushReplacementNamed(context, "home");
    }
  } on UserNotFoundException {
    showConfirmationDialog(
      context,
      content:
          "Deseja criar um novo usuário usando o e-mail $email e a senha inserida?",
      affirmativeOption: "CRIAR",
    ).then((value) {
      if (value != null && value) {
        _authService.register(email: email, password: password).then((resultRegister) {
          if (resultRegister) {
            // Após o registro do usuário, cria o journal padrão
            _createDefaultJournal().then((_) {
              Navigator.pushReplacementNamed(context, "home");
            });
          }
        });
      }
    });
  }
}

Future<void> _createDefaultJournal() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt("id");
  String? token = prefs.getString("accessToken");

  if (userId != null && token != null) {
    // Criando um journal padrão com mensagem de boas-vindas
    Journal defaultJournal = Journal.empty(id: userId, welcomeMessage: "Bem-vindo ao seu diário! Hoje é ${DateTime.now().toLocal().toString().split(" ")[0]}");

    JournalService journalService = JournalService();
    bool success = await journalService.register(defaultJournal);
    if (success) {
      print('Journal padrão registrado com sucesso!');
    } else {
      print('Erro ao registrar journal padrão.');
    }
  }
}



}
