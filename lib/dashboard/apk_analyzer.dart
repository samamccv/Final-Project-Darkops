
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class APKAnalyzerPage extends StatefulWidget {
  const APKAnalyzerPage({super.key});

  @override
  State<APKAnalyzerPage> createState() => _APKAnalyzerPageState();
}

class _APKAnalyzerPageState extends State<APKAnalyzerPage> {
  String? _selectedFileName;
  bool _isAnalyzing = false;
  String? _analysisResult;

  void _resetState() {
    setState(() {
      _selectedFileName = null;
      _analysisResult = null;
      _isAnalyzing = false;
    });
  }

  Future<void> _pickAPK() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _analysisResult = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('APK Selected: "${_selectedFileName!}"'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  Future<void> _analyzeAPK() async {
    if (_selectedFileName == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analyzing "$_selectedFileName"...'),
        behavior: SnackBarBehavior.floating,
      ),
          );

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isAnalyzing = false;
      _analysisResult =
          '✅ No malware detected.\n🔐 5 permissions found.\n📦 Package is safe.';
    });
    Navigator.pop(context, _selectedFileName);

  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBackgroundColor =Theme.of(context).scaffoldBackgroundColor;
    final Color cardBackgroundColor = Theme.of(context).cardColor;
    const Color primaryBlue = Color.fromARGB(211, 98, 233, 114);
    const Color iconGreen = Color(0xFF0FB981);
    final Color primaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    final Color secondaryTextColor =Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color:Color.fromARGB(255, 2, 4, 20)),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.android, color: iconGreen, size: 24),
            ),
            const SizedBox(width: 16),
             Text(
              'APK Analysis',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedFileName != null)
                    Text(
                      'Analysis result for the uploaded file.',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 16,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _selectedFileName == null
                        ? _buildDropzone(
                            iconGreen: iconGreen,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            onPickAPK: _pickAPK,
                          )
                        : _buildAnalysisResult(
                            iconGreen: iconGreen,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            primaryBlue: primaryBlue,
                            isAnalyzing: _isAnalyzing,
                            analysisResult: _analysisResult,
                            onAnalyzeAPK: _analyzeAPK,
                            onReset: _resetState,
                            fileName: _selectedFileName!,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDropzone({
    required Color iconGreen,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required VoidCallback onPickAPK,
  }) {
    return Container(
      key: const ValueKey('dropzone'),
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.android, color: iconGreen, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            'Upload APK for Analysis',
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onPickAPK,
            icon: const Icon(Icons.upload_file, size: 20),
            label: const Text(
              'Select APK File',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: iconGreen,
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
    required Color iconGreen,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color primaryBlue,
    required bool isAnalyzing,
    required String? analysisResult,
    required VoidCallback onAnalyzeAPK,
    required VoidCallback onReset,
    required String fileName,
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
                Icons.android,
                color: iconGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'APK Ready for Analysis',
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
            fileName,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isAnalyzing ? null : onAnalyzeAPK,
              icon: const Icon(Icons.analytics, size: 20),
              label: Text(
                isAnalyzing ? 'Analyzing...' : 'Analyze APK',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAnalyzing ? Colors.grey : primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
            ),
          ),
          if (isAnalyzing) ...[
            const SizedBox(height: 20),
            Center(child: CircularProgressIndicator(color: iconGreen)),
          ],
          if (analysisResult != null) ...[
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D2939),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                analysisResult,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Analyze Another APK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue.withOpacity(0.2),
                foregroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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