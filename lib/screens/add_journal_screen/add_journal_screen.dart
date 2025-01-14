import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/helpers/weekday.dart';
import 'package:teste1/models/journal.dart';

import '../../service/journal_service.dart';

class AddJournalScreen extends StatelessWidget {
  final Journal journal;
  final bool isEditing; // Novo parâmetro para indicar o estado

  AddJournalScreen({
    super.key,
    required this.journal,
    required this.isEditing,
  });

  final TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _contentController.text = journal.content;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${WeekDay(journal.createdAt.weekday).long.toLowerCase()}, ${journal.createdAt.day}  |  ${journal.createdAt.month}  |  ${journal.createdAt.year}",
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (isEditing) {
                editJournal(context); // Chama a função de edição
              } else {
                registerJournal(context); // Chama a função de registro
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          minLines: null,
          maxLines: null,
        ),
      ),
    );
  }

  void registerJournal(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken");
      if (token != null) {
        String content = _contentController.text;

        journal.content = content;

        JournalService service = JournalService();

        service.register(journal).then((value) {
          Navigator.pop(context, value);
        });
      }
    });
  }

  void editJournal(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken");
      if (token != null) {
        String content = _contentController.text;

        journal.content = content;

        JournalService service = JournalService();

        service.edit(journal, token).then((value) {
          Navigator.pop(context, value);
        });
      }
    });
  }
}
