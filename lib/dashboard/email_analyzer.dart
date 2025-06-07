import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// --- MAIN WIDGET ---
class EmailAnalysisPage extends StatefulWidget {
  const EmailAnalysisPage({super.key});

  @override
  State<EmailAnalysisPage> createState() => _EmailAnalysisPageState();
}

class _EmailAnalysisPageState extends State<EmailAnalysisPage> {
  // --- STATE AND LOGIC ---
  String? _fileContent;
  String? _fileName;

  void _resetState() {
    setState(() {
      _fileContent = null;
      _fileName = null;
    });
  }

  Future<void> _pickEmailFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['eml', 'txt', 'msg'],
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _analyzeEmail(String content) {
    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The selected email file is empty.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _resetState();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analyzing "$_fileName"...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI STRUCTURE ---
  @override
  Widget build(BuildContext context) {
    // --- UPDATED COLOR PALETTE ---
    const Color primaryBackgroundColor = Color(0xFF101828);
    const Color cardBackgroundColor = Color(0xFF10182A);
    const Color primaryBlue = Color(0xFF3B82F6);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Color(0xFF98A2B3);

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryTextColor),
          tooltip: 'Back to Dashboard',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: _buildHeader(primaryTextColor),
        titleSpacing: 0,
      ),
      // Removed the floatingActionButton

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Container(
            padding: const EdgeInsets.all(16.0), // Reduced from 32.0 to 16.0
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName == null
                      ? ''
                      : 'Analysis result for the uploaded file.',
                  style: const TextStyle(
                    color: secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _fileName == null
                      ? _buildDropzone(
                          primaryBlue: primaryBlue,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        )
                      : _buildAnalysisResult(
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          primaryBlue: primaryBlue,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildHeader(Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF121E3E),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(Icons.email_outlined, color: Color(0xFF3B82F6), size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          'Email Analysis',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDropzone({
    required Color primaryBlue,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1D2939),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.email_outlined, color: primaryBlue, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            'Upload Email for Analysis',
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickEmailFile,
            icon: const Icon(Icons.arrow_upward_rounded, size: 20),
            label: const Text(
              'Select EML File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult({
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color primaryBlue,
  }) {
    return Container(
      key: const ValueKey('results'),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF101828).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.greenAccent[400],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Analysis Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('File Name:', style: TextStyle(color: secondaryTextColor)),
          const SizedBox(height: 4),
          Text(
            _fileName ?? 'No file',
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text('Content Preview:', style: TextStyle(color: secondaryTextColor)),
          const SizedBox(height: 4),
          Text(
            _fileContent ?? '',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: primaryTextColor.withOpacity(0.8),
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetState,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Analyze Another File',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue.withOpacity(0.2),
                foregroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}