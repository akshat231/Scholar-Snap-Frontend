import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import '../widgets/header.dart';
import '../../constant.dart';
import '../screens/documentInteractionScreen.dart';

import '../../providers/themeProvider.dart';
import '../../providers/loginProvider.dart';
import '../../providers/documentProvider.dart';

final logger = Logger();

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    final user = Provider.of<LoginProvider>(context, listen: false).user;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<DocumentsProvider>(
          context,
          listen: false,
        ).fetchDocuments(user['id'].toString());
      });
    }
  }

  List<String> getRandomImageUrls(String topic, {int count = 1}) {
    final random = Random();

    return List.generate(count, (_) {
      final rand = random.nextInt(10000);
      return 'https://picsum.photos/seed/$topic$rand/800/600';
    });
  }

  String formatDate(String isoDateString) {
    try {
      final date = DateTime.parse(isoDateString);
      final formatter = DateFormat('MMM d, y'); // e.g., Sep 23, 2025
      return formatter.format(date);
    } catch (e) {
      return isoDateString; // fallback if parsing fails
    }
  }

  void _deleteDocument(String id, String title) async {
    final userId = context.read<LoginProvider>().user!['id'];

    try {
      await context.read<DocumentsProvider>().deleteDocument(userId, id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted "$title"')));
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete "$title"')));
    }
  }

  void _confirmDelete(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDocument(id, title);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final backgroundColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    final textColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xDE000000);
    final subtitleColor = isDark
        ? const Color(0xB3FFFFFF)
        : const Color(0x8A000000);
    final fabBackgroundColor = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFFFFFFF);
    final fabIconColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: Header(value: 'My Library'),
      body: Consumer<DocumentsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(provider.error!, style: TextStyle(color: textColor)),
            );
          }

          if (provider.documents.isEmpty) {
            return Center(
              child: Text(
                'No documents found',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final items = provider.documents;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentInteractionScreen(documentTitle: item['title']!, docId: item['id']!),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image']!,
                        width: 70,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              'assets/doc.png',
                              width: 70,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: Styles.boldText.copyWith(color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Uploaded: ${item['date']}',
                            style: Styles.normalText.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          _confirmDelete(context, item['id']!, item['title']!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
