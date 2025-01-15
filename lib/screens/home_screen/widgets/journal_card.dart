import 'package:flutter/material.dart';
import 'package:teste1/helpers/weekday.dart';
import 'package:teste1/models/journal.dart';
import 'package:teste1/screens/common/dialog.dart';
import 'package:teste1/service/journal_service.dart';
import 'package:uuid/uuid.dart';


class JournalCard extends StatelessWidget {
  final Journal? journal; // Registro do diário
  final DateTime showedDate; // Data exibida
  final Function refreshFunction; // Função para atualizar a interface
  final int userId; // ID do usuário
  final String token; // Token de autenticação

  const JournalCard({
    super.key,
    this.journal,
    required this.showedDate,
    required this.refreshFunction,
    required this.userId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    if (journal != null) {
      // Card com conteúdo do Journal
      return InkWell(
        child: Container(
          height: 115,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black87,
            ),
          ),
          child: Row(
            children: [
              // Coluna com data e dia da semana
              Column(
                children: [
                  // Data (dia do mês)
                  Container(
                    height: 75,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      border: Border(
                        right: BorderSide(color: Colors.black87),
                        bottom: BorderSide(color: Colors.black87),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      journal!.createdAt.day.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Dia da semana
                  Container(
                    height: 38,
                    width: 75,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.black87),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(WeekDay(journal!.createdAt.weekday).short),
                  ),
                ],
              ),
              // Conteúdo do diário
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    journal!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
              ),
              // Botão de editar
              IconButton(
                onPressed: () {
                  callAddJournalScreen(context, journal: journal);
                },
                icon: const Icon(Icons.edit),
              ),
              // Botão de remover
              IconButton(
                onPressed: () {
                  removeJournal(context);
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      );
    } else {
      // Card vazio para adicionar um novo registro
      return InkWell(
        onTap: () {
          callAddJournalScreen(context);
        },
        child: Container(
          height: 115,
          alignment: Alignment.center,
          child: Text(
            "${WeekDay(showedDate.weekday).short} - ${showedDate.day}",
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  // Navega para a tela de adicionar/editar Journal
  void callAddJournalScreen(BuildContext context, {Journal? journal}) {
    Journal innerJournal = Journal(
      id: const Uuid().v1(),
      content: "",
      createdAt: showedDate,
      updatedAt: showedDate,
      userId: userId,
    );

    bool isEditing = false;

    if (journal != null) {
      innerJournal = journal;
      isEditing = true; // Indica edição
    }

    Navigator.pushNamed(
      context,
      'add-journal',
      arguments: {
        'journal': innerJournal,
        'isEditing': isEditing,
      },
    ).then((value) {
      refreshFunction(); // Atualiza interface
      if (value != null && value == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registro feito com sucesso!"),
          ),
        );
      }
    });
  }

  // Remove o registro de diário
  void removeJournal(BuildContext context) {
    showConfirmationDialog(
      context,
      content:
          "Deseja realmente remover o registro de ${WeekDay(journal!.createdAt.weekday)}?",
      affirmativeOption: "Remover",
    ).then((value) {
      if (value != null && value) {
        JournalService service = JournalService();
        service.remove(journal!.id, token).then((success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? "Removido com sucesso!"
                    : "Houve um erro ao remover",
              ),
            ),
          );
        }).then((_) {
          refreshFunction(); // Atualiza interface após remoção
        });
      }
    });
  }
}