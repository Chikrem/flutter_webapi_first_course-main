import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

// Classe responsável por interceptar e logar requisições e respostas HTTP
class LoggingInterceptor implements InterceptorContract {
  
  // Instância do Logger para registrar logs no console
  Logger logger = Logger();
  
  // Intercepta e loga os detalhes da requisição antes de ser enviada
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    logger.v( // Log de nível "verbose" para requisições
        "Requisição para ${data.baseUrl}\n" // URL base da requisição
        "Cabeçalhos: ${data.headers}\n" // Cabeçalhos da requisição
        "Corpo: ${data.body}"); // Corpo da requisição
    return data; // Retorna os dados da requisição sem modificá-los
  }

  // Intercepta e loga os detalhes da resposta recebida
  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    // Verifica se o código de status HTTP indica sucesso (2xx)
    if (data.statusCode ~/ 100 == 2) {
      logger.i( // Log de nível "info" para respostas bem-sucedidas
          "Resposta de ${data.url}\n" // URL de onde a resposta foi recebida
          "Status da Resposta: ${data.statusCode}\n" // Código de status HTTP
          "Cabeçalhos: ${data.headers}\n" // Cabeçalhos da resposta
          "Corpo: ${data.body}"); // Corpo da resposta
    } else {
      logger.e( // Log de nível "error" para respostas com erro
          "Resposta de ${data.url}\n" // URL de onde a resposta foi recebida
          "Status da Resposta: ${data.statusCode}\n" // Código de status HTTP
          "Cabeçalhos: ${data.headers}\n" // Cabeçalhos da resposta
          "Corpo: ${data.body}"); // Corpo da resposta
    }
    return data; // Retorna os dados da resposta sem modificá-los
  }
}
