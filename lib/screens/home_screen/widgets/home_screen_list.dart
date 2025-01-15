import '../../../models/journal.dart';
import 'journal_card.dart';

List<JournalCard> generateListJournalCards({
  required int windowPage,       // Número de dias a serem exibidos na lista
  required DateTime currentDay,  // Data do dia atual
  required Map<String, Journal> database,  // Banco de dados com entradas de diários
  required Function refreshFunction,  // Função para atualização da lista
  required int userId,            // ID do usuário atual
  required String token,          // Token de autenticação do usuário
}) {

  // Cria uma lista de JournalCards vazios para os dias da janela (windowPage)
  List<JournalCard> list = List.generate(
    windowPage + 1,  // +1 para incluir o dia atual
    (index) => JournalCard(
      userId: userId,
      token: token,
      refreshFunction: refreshFunction,
      showedDate: currentDay.subtract(Duration(days: (windowPage) - index)),  // Data para o card de cada dia
    ),
  );

  // Preenche os cards com as entradas do banco de dados, se houver para a data
  database.forEach((key, value) {
    // Verifica se a data de criação do journal é dentro da janela de dias que queremos mostrar
    if (value.createdAt.isAfter(currentDay.subtract(Duration(days: windowPage)))) {
      
      // Calcula a diferença de dias entre o journal e o dia inicial da janela
      int difference = value.createdAt
          .difference(currentDay.subtract(Duration(days: windowPage)))
          .inDays
          .abs();

      // Preenche o JournalCard na posição correspondente à data
      list[difference] = JournalCard(
        userId: userId,
        token: token,
        refreshFunction: refreshFunction,
        showedDate: list[difference].showedDate,
        journal: value,  // Adiciona o journal ao card correspondente
      );
    }
  });

  // Retorna a lista final de JournalCards
  return list;
}
