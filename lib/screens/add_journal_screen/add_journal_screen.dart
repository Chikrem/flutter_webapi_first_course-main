import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teste1/helpers/weekday.dart';
import 'package:teste1/models/journal.dart';
import '../../service/journal_service.dart';

// Tela de Adição e Edição de Journal
class AddJournalScreen extends StatelessWidget {
  final Journal journal; // O objeto Journal que será registrado ou editado
  final bool isEditing; // Novo parâmetro para indicar se estamos editando ou criando um novo journal

  AddJournalScreen({
    super.key,
    required this.journal,
    required this.isEditing,
  });

  final TextEditingController _contentController = TextEditingController(); // Controlador para o campo de conteúdo

  @override
  Widget build(BuildContext context) {
    // Preenche o controlador com o conteúdo atual do journal
    _contentController.text = journal.content;

    return Scaffold(
      appBar: AppBar(
        // Exibe a data no título com o formato específico
        title: Text(
          "${WeekDay(journal.createdAt.weekday).long.toLowerCase()}, ${journal.createdAt.day}  |  ${journal.createdAt.month}  |  ${journal.createdAt.year}",
        ),
        actions: [
          // Botão para salvar (editar ou registrar dependendo do estado)
          IconButton(
            onPressed: () {
              if (isEditing) {
                editJournal(context); // Chama a função de edição se estiver editando
              } else {
                registerJournal(context); // Chama a função de registro se estiver criando
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController, // O TextField usa o controlador para capturar o conteúdo
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 24),
          expands: true,
          minLines: null,
          maxLines: null,
        ),
      ),
    );
  }

  // Função para registrar o journal
  void registerJournal(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken"); // Recupera o token do SharedPreferences
      if (token != null) {
        String content = _contentController.text; // Pega o conteúdo do TextField

        journal.content = content; // Atualiza o conteúdo do journal

        JournalService service = JournalService(); // Cria uma instância do serviço

        // Chama o serviço para registrar o journal
        service.register(journal).then((value) {
          Navigator.pop(context, value); // Retorna à tela anterior após o registro
        });
      }
    });
  }

  // Função para editar o journal
  void editJournal(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      String? token = prefs.getString("accessToken"); // Recupera o token do SharedPreferences
      if (token != null) {
        String content = _contentController.text; // Pega o conteúdo do TextField

        journal.content = content; // Atualiza o conteúdo do journal

        JournalService service = JournalService(); // Cria uma instância do serviço

        // Chama o serviço para editar o journal
        service.edit(journal, token).then((value) {
          Navigator.pop(context, value); // Retorna à tela anterior após a edição
        });
      }
    });
  }
}
