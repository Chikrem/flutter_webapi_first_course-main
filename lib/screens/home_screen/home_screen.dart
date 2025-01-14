import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:teste1/database/database.dart';
import 'package:teste1/screens/home_screen/widgets/home_screen_list.dart';

import '../../models/journal.dart';
import '../../service/journal_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // O último dia apresentado na lista
  DateTime currentDay = DateTime.now();

  // Tamanho da lista
  int windowPage = 10;

  // A base de dados mostrada na lista
  Map<String, Journal> database = {};

  final ScrollController _listScrollController = ScrollController();

  JournalService service = JournalService();

  int? userId;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Título basado no dia atual
        title: Text(
          "${currentDay.day}  |  ${currentDay.month}  |  ${currentDay.year}",
        ),
        actions: [
          IconButton(
            onPressed: () {
              refresh();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: (userId != null) ?
      ListView(
        controller: _listScrollController,
        children: generateListJournalCards(
          refreshFunction: refresh,
          windowPage: windowPage,
          currentDay: currentDay,
          database: database,
          userId: userId!,
        ),
      ) : const Center(child: CircularProgressIndicator()),
    );
  }

  void refresh() {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken");
      String? email = prefs.getString("email");
      int? id = prefs.getInt("id");
      // print("Token armazenado: $token");

      if (token != null && email != null && id != null) {
        setState(() {
          userId = id;
        });
        service
            .getAll(id: id.toString(), token: token)
            .then((List<Journal> listJournal) {
          if (listJournal.isNotEmpty) {
            setState(() {
              database = {};
              for (Journal journal in listJournal) {
                database[journal.id] = journal;
              }

              if (_listScrollController.hasClients) {
                final double position =
                    _listScrollController.position.maxScrollExtent;
                _listScrollController.jumpTo(position);
              }
            });
          } else {
            Navigator.pushReplacementNamed(context, "login");
          }
        });
      } else {
        Navigator.pushReplacementNamed(context, "login");
      }
    });
  }
}
