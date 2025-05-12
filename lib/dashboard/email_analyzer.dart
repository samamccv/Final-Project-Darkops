import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EmailAnalyzerPage extends StatefulWidget {
  const EmailAnalyzerPage({super.key});

  @override
  State<EmailAnalyzerPage> createState() => _EmailAnalyzerPageState();
}

class _EmailAnalyzerPageState extends State<EmailAnalyzerPage> {
  String? _fileContent;
  String? _fileName;

  Future<void> _pickEmailFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'eml', 'html'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      setState(() {
        _fileContent = content;
        _fileName = result.files.single.name;
      });

      _analyzeEmail(content);
    } else {
      // Show a dialog if no file is selected
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('No File Selected'),
              content: const Text('Please select a file to analyze.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  void _analyzeEmail(String content) {
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email content is empty')));
      return;
    }

    // TODO: Call your AI model or backend with `content`
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Analyzing: "$_fileName"...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Email Analysis'),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.email, color: Colors.deepPurple),
                        SizedBox(width: 8),
                        Text(
                          'Email Analysis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Browse and analyze email files for phishing attempts and threats',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed:
                          _pickEmailFile, // This method uses FilePicker to browse files
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Browse Email File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_fileContent != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1117),
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _fileContent!,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
