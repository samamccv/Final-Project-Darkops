import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class URLScannerPage extends StatefulWidget {
  const URLScannerPage({super.key});

  @override
  State<URLScannerPage> createState() => _URLScannerPageState();
}

class _URLScannerPageState extends State<URLScannerPage> {
  final TextEditingController _controller = TextEditingController();
  bool _scanDone = false;
  String? _scannedURL;

  void _scanURL() {
    final url = _controller.text.trim();
    if (url.isEmpty || !Uri.parse(url).isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }

    setState(() {
      _scanDone = true;
      _scannedURL = url;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scanning URL: "$url"')),
    );
      Navigator.pop(context, url);
  }

  void _reset() {
    setState(() {
      _controller.clear();
      _scanDone = false;
      _scannedURL = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = Theme.of(context).cardColor;
    const Color iconColor = Color.fromARGB(255, 245, 158, 11);
    final Color primaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    final Color secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.language_outlined, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
             Text(
              'URL Scanner',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Analyze URLs for phishing, redirection, or security threats',
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  const SizedBox(height: 20),

                  // Input field always visible
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.url,
                    enabled: !_scanDone, // optional: disable input after scan
                    style:  TextStyle(color: primaryTextColor),
                    decoration: InputDecoration(
                      hintText: 'Enter a URL (e.g., https://example.com)',
                      hintStyle:  TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white.withOpacity(0.1)),
                      filled: true,
                      fillColor: backgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: iconColor.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: iconColor),
                      ),
                    ),
                  ).animate().slide(begin: const Offset(-1, 0), curve: Curves.easeOut, duration: 500.ms),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _scanDone ? null : _scanURL,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Analyze URL',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().slide(begin: const Offset(-1, 0), curve: Curves.easeOut, duration: 500.ms),

                  // Results shown below Analyze button
                  if (_scanDone) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.greenAccent[400], size: 28),
                        const SizedBox(width: 12),
                         Text(
                          'Analysis Complete',
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ).animate().slide(begin: const Offset(1, 0), curve: Curves.easeOut, duration: 500.ms),
                    const SizedBox(height: 16),
                    Text('Scanned URL:', style: TextStyle(color: secondaryTextColor)),
                    const SizedBox(height: 4),
                    Text(
                      _scannedURL ?? '',
                      style: TextStyle(
                        color: primaryTextColor.withOpacity(0.8),
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _reset,
                        icon: Icon(Icons.refresh, color: iconColor),
                        label: Text(
                          'Analyze Another URL',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: iconColor),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: iconColor.withOpacity(0.15),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ).animate().slide(begin: const Offset(1, 0), curve: Curves.easeOut, duration: 500.ms),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}