import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../utils/serverConfig.dart';
import '../services/socketService.dart'; // your socket handler

final logger = Logger();

class DocumentsProvider extends ChangeNotifier {
  List<Map<String, String>> _documents = [];
  bool _isLoading = false;
  String? _error;

  final SocketService _socketService = SocketService();
  final Map<String, String> _docStatuses = {}; // {docId: status}

  List<Map<String, String>> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Map<String, String> _summaries = {}; // {docId: summary}
  final Map<String, bool> _summaryLoading = {};

  String getStatus(String docId) => _docStatuses[docId] ?? 'processing';

  String formatDate(String isoDateString) {
    try {
      final date = DateTime.parse(isoDateString).toLocal();
      final formatter = DateFormat('MMM d, y');
      return formatter.format(date);
    } catch (e) {
      logger.e('Invalid date format: $isoDateString');
      return isoDateString;
    }
  }

  Future<void> fetchDocuments(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(ServerConfig.getDocumentsUrl).replace(
        queryParameters: {
          'id': userId,
          'page': '1',
          'limit': '20',
          'sortBy': 'uploaded_at',
          'sortOrder': 'desc',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> docsJson = jsonData['data']['documents'];

        _documents = docsJson.map<Map<String, String>>((doc) {
          final docId = doc['id'].toString();

          // Init status as 'processing' if not already updated
          if (!_docStatuses.containsKey(docId)) {
            _docStatuses[docId] = 'processing';
          }

          return {
            'id': docId,
            'title': doc['title'] ?? '',
            'date': formatDate(doc['uploaded_at'] ?? ''),
            'image': 'https://picsum.photos/seed/${doc['id']}/800/600',
          };
        }).toList();
      } else {
        _error = 'Failed to load documents: ${response.statusCode}';
      }
    } catch (e) {
      logger.e('Error fetching documents: $e');
      _error = 'Something went wrong';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(int userId, String documentId) async {
    final uri = Uri.parse('${ServerConfig.deleteDocumentUrl}/$documentId');

    try {
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        _documents.removeWhere((doc) => doc['id'] == documentId);
        _docStatuses.remove(documentId);
        notifyListeners();
      } else {
        logger.e('Failed to delete document: ${response.statusCode}');
        throw Exception('Failed to delete document');
      }
    } catch (e) {
      logger.e('Delete failed: $e');
      throw Exception('Delete failed');
    }
  }

  String? getSummary(String docId) => _summaries[docId];
  bool isSummaryLoading(String docId) => _summaryLoading[docId] ?? false;

  Future<void> fetchSummary(String docId) async {
    // Don't fetch again if already present
    if (_summaries.containsKey(docId)) return;

    _summaryLoading[docId] = true;
    notifyListeners();

    try {
      final uri = Uri.parse('${ServerConfig.summaryApiUrl}/$docId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['data'];
        final summary = responseData['summary'] ?? 'No summary available.';
        _summaries[docId] = summary;
      } else {
        logger.e('Failed to fetch summary: ${response.statusCode}');
        _summaries[docId] = 'Failed to fetch summary.';
      }
    } catch (e) {
      logger.e('Error fetching summary: $e');
      _summaries[docId] = 'Error fetching summary.';
    } finally {
      _summaryLoading[docId] = false;
      notifyListeners();
    }
  }



final Map<String, String> _citations = {};
final Map<String, bool> _citationsLoading = {};

String? getCitation(String docId) => _citations[docId];

bool isCitationsLoading(String docId) => _citationsLoading[docId] ?? false;

Future<void> fetchCitations(String docId) async {
  if (_citations.containsKey(docId)) return;

  _citationsLoading[docId] = true;
  notifyListeners();

  try {
    final uri = Uri.parse('${ServerConfig.citationsApiUrl}/$docId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final responseData = data['data'];
      final citation = responseData['citation'] ?? 'No citation available.';
      _citations[docId] = citation;
    } else {
      logger.e('Failed to fetch citation: ${response.statusCode}');
      _citations[docId] = 'Failed to fetch citation.';
    }
  } catch (e, stackTrace) {
    logger.e('Error fetching citation: $e \n $stackTrace');
    _citations[docId] = 'Error fetching citation.';
  } finally {
    _citationsLoading[docId] = false;
    notifyListeners();
  }
}

// New Chat Response Cache
final Map<String, List<Map<String, dynamic>>> _chatHistories = {}; // docId => List of messages
final Map<String, bool> _chatLoading = {};

List<Map<String, dynamic>> getChatHistory(String docId) => _chatHistories[docId] ?? [];
bool isChatLoading(String docId) => _chatLoading[docId] ?? false;

// Fetch assistant response from API
Future<void> fetchChatResponse({
  required String docId,
  required String userMessage,
}) async {
  _chatLoading[docId] = true;
  notifyListeners();

  try {
    // Add user message to chat history
    _chatHistories.putIfAbsent(docId, () => []);
    _chatHistories[docId]!.add({'text': userMessage, 'isUser': true});
    notifyListeners();

    final uri = Uri.parse('${ServerConfig.queryApiUrl}/$docId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': userMessage}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final aiResponse = data['data']['response'] ?? 'No response from assistant.';

      _chatHistories[docId]!.add({'text': aiResponse, 'isUser': false});
    } else {
      logger.e('API error: ${response.statusCode}');
      _chatHistories[docId]!.add({'text': 'Failed to get response from assistant.', 'isUser': false});
    }
  } catch (e, stack) {
    logger.e('Error fetching chat response: $e\n$stack');
    _chatHistories[docId]!.add({'text': 'Error contacting assistant.', 'isUser': false});
  } finally {
    _chatLoading[docId] = false;
    notifyListeners();
  }
}



  // ✅ INIT socket connection after login
  void connectSocket(String userId) {
    _socketService.initSocket(
      userId: userId,
      onUpdate: (data) {
        final docId = data['docId'];
        final status = data['updatedField'];
        if (docId != null && status != null) {
          _docStatuses[docId] = status;
          logger.i('🟢 Real-time status update: $docId -> $status');
          notifyListeners();
        } else {
          logger.w('⚠️ Invalid real-time data received: $data');
        }
      },
    );
  }

  void disconnectSocket() {
    _socketService.dispose();
  }

  void clear() {
    _documents = [];
    _docStatuses.clear();
    _error = null;
    notifyListeners();
  }
}
