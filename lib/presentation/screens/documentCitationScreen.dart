import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/documentProvider.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class CitationScreen extends StatefulWidget {
  final String documentId;
  final String documentTitle;

  const CitationScreen({
    super.key,
    required this.documentId,
    required this.documentTitle,
  });

  @override
  State<CitationScreen> createState() => _CitationScreenState();
}

class _CitationScreenState extends State<CitationScreen> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasFetched) {
      final provider = Provider.of<DocumentsProvider>(context, listen: false);
      final citation = provider.getCitation(widget.documentId);
      final isLoading = provider.isCitationsLoading(widget.documentId);

      if (citation == null && !isLoading) {
        logger.i('Scheduling fetchCitation for documentId: ${widget.documentId}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.fetchCitations(widget.documentId);
        });
      }

      _hasFetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentsProvider>(
      builder: (context, provider, child) {
        final citation = provider.getCitation(widget.documentId);
        final isLoading = provider.isCitationsLoading(widget.documentId);

        logger.d('CitationScreen: isLoading=$isLoading, citation=${citation != null ? "Exists" : "Null"}');

        return Scaffold(
          appBar: AppBar(title: Text(widget.documentTitle)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    citation ?? 'No citation found.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
          ),
        );
      },
    );
  }
}
