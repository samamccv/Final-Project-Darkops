import 'package:flutter/material.dart';
import 'package:darkops/dashboard/qr_code_scanner.dart';
import 'package:darkops/dashboard/sms_analyzer.dart';
import 'package:darkops/dashboard/email_analyzer.dart';
import 'package:darkops/dashboard/url_scanner.dart';
import 'package:darkops/dashboard/apk_analyzer.dart';

enum FeatureType { sms, email, url, qr, malware }

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Map<FeatureType, List<String>> recentData = {
    FeatureType.sms: [
      "Hey! How are you?",
      "Don't forget the meeting at 3.",
      "Your OTP is 123456.",
      "Happy Birthday 🎉",
      "Call me when you're free.",
    ],
    FeatureType.email: [
      "Welcome to Flutter App!",
      "Reset your password",
      "Interview scheduled for Friday",
      "Invoice for your recent purchase",
      "Weekly digest from Medium",
    ],
  };

  final Map<FeatureType, IconData> featureIcons = {
    FeatureType.sms: Icons.sms,
    FeatureType.email: Icons.email,
    FeatureType.url: Icons.link,
    FeatureType.qr: Icons.qr_code_scanner,
    FeatureType.malware: Icons.warning_amber_rounded,
  };

  final Map<FeatureType, String> featureTitles = {
    FeatureType.sms: "SMS",
    FeatureType.email: "Emails",
    FeatureType.url: "URL",
    FeatureType.qr: "QR Code",
    FeatureType.malware: "Malware",
  };

  final Map<FeatureType, int> scanCounts = {
    FeatureType.sms: 2,
    FeatureType.email: 4,
    FeatureType.url: 7,
    FeatureType.qr: 3,
    FeatureType.malware: 1,
  };

  @override
  void initState() {
    super.initState();
    for (var type in FeatureType.values) {
      featureTitles.putIfAbsent(type, () => type.name);
      featureIcons.putIfAbsent(type, () => Icons.help_outline);
      recentData.putIfAbsent(type, () => []);
      scanCounts.putIfAbsent(type, () => 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
        backgroundColor: const Color.fromARGB(
          255,
          6,
          8,
          27,
        ), // Updated background color
      ),
      backgroundColor: const Color.fromARGB(255, 6, 8, 27),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildScanCountRow(),
            const SizedBox(height: 20),
            _buildInfoCard(FeatureType.sms),
            const SizedBox(height: 20),
            _buildInfoCard(FeatureType.email),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showFeatureMenu(context),
        backgroundColor: const Color.fromARGB(255, 6, 8, 27),
        child: const Icon(Icons.menu),
      ),
    );
  }

  // Horizontal Scan Count Row
  // Horizontal Scan Count Row (Final Scrollable Version)
  Widget _buildScanCountRow() {
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              FeatureType.values.map((type) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _buildScanBox(type),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildScanBox(FeatureType type) {
    final icon = featureIcons[type]!;
    final title = featureTitles[type]!;
    final count = scanCounts[type]!;

    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Color.fromARGB(255, 128, 123, 218)),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Info Cards
  Widget _buildInfoCard(FeatureType type) {
    final title = featureTitles[type] ?? type.name;
    final icon = featureIcons[type] ?? Icons.info;
    final items = recentData[type];

    if (items == null || items.isEmpty) return const SizedBox();

    return Card(
      color: const Color.fromARGB(255, 6, 8, 27),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color.fromARGB(255, 128, 123, 218)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map(
                (text) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "• $text",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Feature Menu Bottom Sheet
  void _showFeatureMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 6, 8, 27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  FeatureType.values.map((type) {
                    return _buildFeatureTile(type);
                  }).toList(),
            ),
          ),
    );
  }

  // Feature Item Tile
  Widget _buildFeatureTile(FeatureType type) {
    final icon = featureIcons[type]!;
    final label = featureTitles[type]!;

    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        if (type == FeatureType.qr) {
          _openQRScanner();
        } else if (type == FeatureType.sms) {
          // Navigate to the SMS Analyzer Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SMSAnalyzerPage()),
          );
        } else if (type == FeatureType.email) {
          // Navigate to the Email Analyzer Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmailAnalyzerPage()),
          );
        } else if (type == FeatureType.url) {
          // Navigate to the URL Scanner Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const URLScannerPage()),
          );
        } else if (type == FeatureType.malware) {
          // Navigate to the APK Analyzer Page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const APKAnalyzerPage()),
          );
        } else {
          setState(() {
            scanCounts[type] = (scanCounts[type] ?? 0) + 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label feature coming soon!')),
          );
        }
      },
    );
  }

  // QR Scanner Navigation
  void _openQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (result != null) {
      setState(() {
        scanCounts[FeatureType.qr] = (scanCounts[FeatureType.qr] ?? 0) + 1;
        recentData[FeatureType.qr] = [
          result.toString(),
          ...?recentData[FeatureType.qr],
        ];
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scanned QR: $result')));
    }
  }
}
