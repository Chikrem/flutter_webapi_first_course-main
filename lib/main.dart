// Início Aula-7
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/screens/add_journal_screen/add_journal_screen.dart';
import 'package:teste1/screens/login_screen/login_screen.dart';
import 'screens/home_screen/home_screen.dart';

void main() async {
  // Garantir que os widgets do Flutter sejam inicializados corretamente
  WidgetsFlutterBinding.ensureInitialized();

  // Verificar se o usuário está logado
  bool isLogged = await verifyToken();

  // Executar o aplicativo
  runApp(MyApp(isLogged: isLogged));
}

// Função para verificar se o token de acesso está armazenado nas preferências compartilhadas
Future<bool> verifyToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("accessToken");
  if (token != null) {
    return true;
  }
  return false;
}

class MyApp extends StatelessWidget {
  final bool isLogged;

  // Construtor da classe MyApp
  const MyApp({super.key, required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.white,
          ), // TextStyle
          actionsIconTheme: IconThemeData(color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ), // AppBarTheme
        textTheme: GoogleFonts.bitterTextTheme(),
      ), // ThemeData
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      // Definir a rota inicial com base no estado de login do usuário
      initialRoute: (isLogged) ? "home" : "login",
      routes: {
        "home": (context) => const HomeScreen(),
        "login": (context) => LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == 'add-journal') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return AddJournalScreen(
                journal: args['journal'],
                isEditing: args['isEditing'],
              );
            },
          );
        }
        return null;
      },
    );
  }
}
