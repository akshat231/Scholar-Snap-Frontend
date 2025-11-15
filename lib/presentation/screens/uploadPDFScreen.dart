import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import '../widgets/header.dart';
import '../widgets/highlightedButton.dart';
import '../../constant.dart';
import '../../providers/themeProvider.dart';
import '../../providers/loginProvider.dart';
import '../../utils/serverConfig.dart';
import 'dart:io';

final logger = Logger();

class UploadPDFScreen extends StatefulWidget {
  const UploadPDFScreen({super.key});

  @override
  State<UploadPDFScreen> createState() => _UploadPDFScreenState();
}

class _UploadPDFScreenState extends State<UploadPDFScreen> {
  double uploadProgress = 0.0; // State field
  bool isUploading = false; // State field

  Future<void> pickAndUploadPDF(id) async {
    try {
      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
      });

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null) {
        // User canceled picker
        setState(() {
          isUploading = false;
        });
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        setState(() {
          isUploading = false;
        });
        return;
      }

      final file = File(filePath);
      final fileName = result.files.single.name;

      final url = ServerConfig.uploadPDFUrl;

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ),
      );
      request.fields['id'] = id.toString();

      // Send request and await response
      final streamedResponse = await request.send();

      // No progress update here because 'http' doesn't support progress out of the box

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF uploaded successfully!')),
        );
      } else {
        throw Exception('Failed to upload PDF');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() {
        isUploading = false;
        uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginProvider>(context).user;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDark
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? const Color(0xFF757575)
        : const Color(0xFFBDBDBD);
    final textColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xDE000000);
    final subtitleTextColor = isDark
        ? const Color(0xB3FFFFFF)
        : const Color(0x8A000000);
    final progressBackgroundColor = isDark
        ? const Color(0xFF424242)
        : const Color(0xFFe0e0e0);
    final progressColor = const Color(0xFF448AFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: Header(value: 'Upload PDF'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dotted container
            Expanded(
              child: Center(
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  dashPattern: const [6, 3],
                  color: borderColor,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Drag and drop or browse',
                          style: Styles.boldText.copyWith(color: textColor),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload your PDF file to start analyzing and interacting with your document.',
                          style: Styles.normalText.copyWith(
                            color: subtitleTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Highlightedbutton(
                          value: 'Browse Files',
                          onPressed: () async {
                            await pickAndUploadPDF(user?['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Show progress ONLY when uploading
            if (isUploading) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Uploading...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: null, // indeterminate progress
                color: progressColor,
                backgroundColor: progressBackgroundColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
