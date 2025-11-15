import 'package:flutter_dotenv/flutter_dotenv.dart';


class ServerConfig {
  static final Map<String, dynamic> backendServer = {
    'host': dotenv.env['BACKEND_HOST'] ?? '10.0.2.2',
    'port': int.tryParse(dotenv.env['BACKEND_PORT'] ?? '5000') ?? 7000,
    'protocol': dotenv.env['BACKEND_PROTOCOL'] ?? 'http',
  };

  static const String apiConst = '/api';

  static final String googleClientId =
      dotenv.env['GOOGLE_CLIENT_ID'] ?? '';

  static const Map<String, String> apiList = {
    'loginAPI': '/user/login',
    'themeAPI': '/user/theme',
    'uploadAPI': '/user/upload',
    'getDocumentsAPI': '/user/documents',
    'deleteDocumentAPI': '/user/document',
    'summaryAPI': '/document/summary',
    'citationAPI': '/document/citation',
    'queryAPI': '/document/query'
  };
  static String get backendUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];

    return '$protocol://$host:$port';
  }

  static String get loginApiUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['loginAPI']!;

    return '$protocol://$host:$port$path';
  }

  static String get toggleThemeUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['themeAPI']!;

    return '$protocol://$host:$port$path';
  }

  static String get uploadPDFUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['uploadAPI']!;

    return '$protocol://$host:$port$path';
  }

  static String get getDocumentsUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['getDocumentsAPI']!;

    return '$protocol://$host:$port$path';
  }

  static String get deleteDocumentUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['deleteDocumentAPI']!;

    return '$protocol://$host:$port$path';
  }

  static String get summaryApiUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['summaryAPI']!;

    return '$protocol://$host:$port$path';
  }

    static String get citationsApiUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['citationAPI']!;

    return '$protocol://$host:$port$path';
  }


    static String get queryApiUrl {
    final protocol = backendServer['protocol'];
    final host = backendServer['host'];
    final port = backendServer['port'];
    final path = apiConst + apiList['queryAPI']!;

    return '$protocol://$host:$port$path';
  }
}
