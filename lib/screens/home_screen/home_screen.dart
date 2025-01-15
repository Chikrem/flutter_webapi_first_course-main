import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:teste1/database/database.dart'; // Comentado - talvez você esteja planejando usar no futuro
import 'package:teste1/screens/home_screen/widgets/home_screen_list.dart';

import '../../models/journal.dart';
import '../../service/journal_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data atual que será mostrada na tela
  DateTime currentDay = DateTime.now();

  // Número de entradas de Journal que serão mostradas por vez na tela
  int windowPage = 10;

  // Base de dados que vai ser apresentada (um mapa de journals)
  Map<String, Journal> database = {};

  // Controlador para o scroll da lista
  final ScrollController _listScrollController = ScrollController();

  // Instância do serviço que lida com Journal
  JournalService service = JournalService();

  // Armazenamento do id do usuário e token de autenticação
  int? userId;
  String? userToken;

  @override
  void initState() {
    refresh(); // Chama a função de refresh ao iniciar a tela
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar que exibe a data atual
      appBar: AppBar(
        title: Text(
          "${currentDay.day}  |  ${currentDay.month}  |  ${currentDay.year}",
        ),
        actions: [
          // Botão de atualização
          IconButton(
            onPressed: () {
              refresh(); // Atualiza a lista
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      // Menu lateral com opção de logout
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sair"),
              onTap: () {
                logout(); // Chama a função de logout
              },
            )
          ],
        ),
      ),
      // Corpo da tela com a lista de Journals
      body: (userId != null && userToken != null)
          ? ListView(
              controller: _listScrollController,
              children: generateListJournalCards(
                refreshFunction: refresh,
                windowPage: windowPage,
                currentDay: currentDay,
                database: database,
                userId: userId!,
                token: userToken!,
              ),
            )
          : const Center(child: CircularProgressIndicator()), // Exibe loading até os dados estarem prontos
    );
  }

  // Função de refresh que busca os dados do usuário e journals
  void refresh() async {
    setState(() {
      userId = null;
      userToken = null;
    });

    // Acessa o SharedPreferences para recuperar os dados do usuário
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("accessToken");
    String? email = prefs.getString("email");
    int? id = prefs.getInt("id");

    // Verifica se os dados do usuário existem
    if (token != null && email != null && id != null) {
      setState(() {
        userId = id;
        userToken = token;
      });

      // Chama o serviço para obter todos os journals do usuário
      service.getAll(id: id.toString(), token: token).then((List<Journal> listJournal) {
        if (listJournal.isNotEmpty) {
          setState(() {
            // Preenche a base de dados com os journals recebidos
            database = {};
            for (Journal journal in listJournal) {
              database[journal.id] = journal;
            }

            // Faz o scroll da lista para a última posição
            if (_listScrollController.hasClients) {
              final double position = _listScrollController.position.maxScrollExtent;
              _listScrollController.jumpTo(position);
            }
          });
        } else {
          // Caso não haja journals, redireciona para a tela de login
          Navigator.pushReplacementNamed(context, "login");
        }
      });
    } else {
      // Caso os dados do usuário não sejam encontrados, redireciona para a tela de login
      Navigator.pushReplacementNamed(context, "login");
    }
  }

  // Função de logout que limpa os dados de autenticação e redireciona para o login
  void logout() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear(); // Limpa os dados armazenados no SharedPreferences
      Navigator.pushReplacementNamed(context, "login"); // Redireciona para a tela de login
    });
  }
}
