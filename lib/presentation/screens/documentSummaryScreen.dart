import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/documentProvider.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class SummaryScreen extends StatefulWidget {
  final String documentId;
  final String documentTitle;

  const SummaryScreen({
    super.key,
    required this.documentId,
    required this.documentTitle,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasFetched) {
      final provider = Provider.of<DocumentsProvider>(context, listen: false);
      final summary = provider.getSummary(widget.documentId);
      final isLoading = provider.isSummaryLoading(widget.documentId);

      if (summary == null && !isLoading) {
        logger.i('Scheduling fetchSummary for documentId: ${widget.documentId}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.fetchSummary(widget.documentId);
        });
      }

      _hasFetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DocumentsProvider>(
      builder: (context, provider, child) {
        final summary = provider.getSummary(widget.documentId);
        final isLoading = provider.isSummaryLoading(widget.documentId);

        logger.d('SummaryScreen: isLoading=$isLoading, summary=${summary != null ? "Exists" : "Null"}');

        return Scaffold(
          appBar: AppBar(title: Text(widget.documentTitle)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      summary ?? 'No summary found.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
            ),
          ),
        );
      },
    );
  }
}
