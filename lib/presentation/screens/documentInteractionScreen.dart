import 'package:flutter/material.dart';

import './documentChatScreen.dart';
import './documentSummaryScreen.dart';
import './documentCitationScreen.dart';
import '../widgets/header.dart';

class DocumentInteractionScreen extends StatelessWidget {
  final String documentTitle;
  final String docId;

  const DocumentInteractionScreen({super.key, required this.documentTitle, required this.docId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 0, // Default to "Chat with PDF"
      child: Scaffold(
        appBar: Header(
          value: documentTitle,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chat with PDF'),
              Tab(text: 'Summary'),
              Tab(text: 'Citation'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatScreen(documentTitle: documentTitle, documentId: docId),
            SummaryScreen(documentTitle: documentTitle, documentId: docId),
            CitationScreen(documentTitle: documentTitle, documentId: docId),
          ],
        ),
      ),
    );
  }
}
