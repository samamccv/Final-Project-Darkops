import 'package:flutter/material.dart';

class SMSAnalyzerPage extends StatefulWidget {
  const SMSAnalyzerPage({super.key});

  @override
  State<SMSAnalyzerPage> createState() => _SMSAnalyzerPageState();
}

class _SMSAnalyzerPageState extends State<SMSAnalyzerPage> {
  final TextEditingController _controller = TextEditingController();
  bool _analysisDone = false;
  String? _analyzedText;

  void _analyzeSMS() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an SMS message')),
      );
      return;
    }

    setState(() {
      _analysisDone = true;
      _analyzedText = text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Analyzing: "$text"')),
    );
  }

  void _resetState() {
    setState(() {
      _controller.clear();
      _analysisDone = false;
      _analyzedText = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBackgroundColor = Color(0xFF101828);
    const Color cardBackgroundColor = Color(0xFF1D2939);
    const Color primaryBlue = Color.fromARGB(255, 139, 92, 246);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Color(0xFF98A2B3);

    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryTextColor),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: _buildHeader(primaryTextColor),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Enter SMS message below:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildInputSection(primaryBlue),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _analysisDone
                          ? _buildResultSection(
                              primaryBlue, primaryTextColor, secondaryTextColor)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF121E3E),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.sms_outlined, color: Color.fromARGB(255, 139, 92, 246), size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          'SMS Analysis',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(Color primaryBlue) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Card(
        color: const Color(0xFF0D1117),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _controller,
            maxLines: 6,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Paste the SMS message to analyze...',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _analyzeSMS,
          icon: const Icon(Icons.sms_outlined),
          label: const Text(
            'Analyze SMS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 0,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildResultSection(Color primaryBlue, Color primaryTextColor, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.greenAccent[400], size: 28),
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
        Text('Original SMS:', style: TextStyle(color: secondaryTextColor)),
        const SizedBox(height: 4),
        Text(
          _analyzedText ?? '',
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
            onPressed: _resetState,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Analyze Another SMS',
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
    );
  }
}