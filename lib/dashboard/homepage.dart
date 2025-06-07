import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:darkops/dashboard/qr_code_scanner.dart';
import 'package:darkops/dashboard/sms_analyzer.dart';
import 'package:darkops/dashboard/email_analyzer.dart';
import 'package:darkops/dashboard/url_scanner.dart';
import 'package:darkops/dashboard/apk_analyzer.dart';
import 'package:darkops/screens/login_options.dart';
import 'package:darkops/dashboard/ScanHistory_screen.dart';

enum FeatureType { sms, email, url, qr, apk }

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Map<FeatureType, int> scanCounts = {
    FeatureType.sms: 2,
    FeatureType.email: 0,
    FeatureType.url: 7,
    FeatureType.qr: 3,
    FeatureType.apk: 1,
  };

  final Map<FeatureType, int> lastWeekScanCounts = {
    FeatureType.sms: 4,
    FeatureType.email: 0,
    FeatureType.url: 10,
    FeatureType.qr: 1,
    FeatureType.apk: 1,
  };

  final Map<FeatureType, IconData> featureIcons = {
    FeatureType.sms: Icons.sms_outlined,
    FeatureType.email: Icons.email_outlined,
    FeatureType.url: Icons.language_outlined,
    FeatureType.qr: Icons.qr_code_2_outlined,
    FeatureType.apk: Icons.android_outlined,
  };

  final Map<FeatureType, String> featureTitles = {
    FeatureType.sms: "SMS Analysis",
    FeatureType.email: "Email Analysis",
    FeatureType.url: "URL Scanner",
    FeatureType.qr: "QR Code Scanner",
    FeatureType.apk: "APK Analyzer",
  };

  final Map<FeatureType, Color> iconColors = {
    FeatureType.sms: const Color.fromARGB(255, 139, 92, 246), // blue-ish
    FeatureType.email: Color.fromARGB(255, 59, 130, 246), // orange-ish
    FeatureType.url: Color.fromARGB(255, 245, 158, 11),
    FeatureType.qr: Color.fromARGB(255, 99, 102, 241),
    FeatureType.apk: Color.fromARGB(255, 15, 185, 129),
  };

  final List<String> recentSMS = [
    "Your OTP is 987654",
    "Thanks for using our service.",
    "Delivery scheduled tomorrow.",
    "Balance: \$32.00",
    "New login alert.",
  ];

  final List<String> recentEmails = [
    "Welcome to Flutter Weekly!",
    "Your invoice is ready.",
    "Reset your password",
    "New job opportunity",
    "Meeting confirmed at 3 PM",
  ];

  double _calculatePercentChange(FeatureType type) {
    int current = scanCounts[type] ?? 0;
    int previous = lastWeekScanCounts[type] ?? 0;
    if (previous == 0) return current == 0 ? 0.0 : 100.0;
    return ((current - previous) / previous) * 100;
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFF101828);
    const Color cardColor = Color(0xFF1D2939);
    const Color primaryBlue = Color(0xFF3B82F6);
    const Color white = Colors.white;
    const Color greyText = Colors.grey;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: _buildAppBarTitle(white, primaryBlue),
        backgroundColor: background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello, Sama 👋',
                style: TextStyle(
                  color: white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildHorizontalFeatureList(cardColor, white),
              const SizedBox(height: 20),

              // Single Recent Activity Headline in grey color
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Recent SMS Card (without "Recent Activity" in title)
              _buildRecentCard(
                FeatureType.sms,
                recentSMS,
                cardColor,
                white,
                removeRecentActivityFromTitle: true,
              ),
              const SizedBox(height: 16),

              // Recent Email Card (without "Recent Activity" in title)
              _buildRecentCard(
                FeatureType.email,
                recentEmails,
                cardColor,
                white,
                removeRecentActivityFromTitle: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10), // moved slightly downward
        child: FloatingActionButton(
          onPressed: () => _showFeatureMenu(context),
          backgroundColor: const Color.fromARGB(255, 20, 41, 74),
          tooltip: "Features",
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(Icons.dashboard_outlined, color: white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHorizontalFeatureList(Color cardColor, Color white) {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            FeatureType.values.map((type) {
              final iconColor = iconColors[type]!;
              final percentChange = _calculatePercentChange(type);
              final isPositive = percentChange >= 0;

              return Container(
                width: 230,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            featureIcons[type],
                            color: iconColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            featureTitles[type]!,
                            style: TextStyle(
                              color: white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${scanCounts[type] ?? 0}',
                      style: TextStyle(
                        color: white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color:
                              isPositive
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${percentChange.toStringAsFixed(1)}% compared to last week',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isPositive
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: ((scanCounts[type] ?? 0) / 10).clamp(
                              0.0,
                              1.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: iconColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                          .animate()
                          .fade(duration: 600.ms)
                          .slideX(begin: -1, end: 0),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildRecentCard(
    FeatureType type,
    List<String> messages,
    Color cardColor,
    Color white, {
    bool removeRecentActivityFromTitle = false,
  }) {
    final icon = featureIcons[type]!;
    final title = featureTitles[type]!;
    final iconColor = iconColors[type]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12,
      ), // reduced padding
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                removeRecentActivityFromTitle
                    ? title
                    : '$title - Recent Activity',
                style: TextStyle(
                  color: white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // smaller spacing
          ...messages.map(
            (msg) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.fiber_manual_record,
                    size: 8,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      msg,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(Color textColor, Color iconColor) {
    return Row(
      children: [
        // Clickable person icon with popup menu
        PopupMenuButton<String>(
  icon: Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: iconColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Icon(Icons.person_outlined, color: iconColor, size: 24),
  ),
  color: const Color(0xFF1D2939),
  onSelected: (value) {
    switch (value) {
      case 'account':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account selected')),
        );
        break;
      case 'light_mode':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Light Mode toggled')),
        );
        break;
      case 'logout':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginOptions()),
        );
        break;
    }
  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'account',
      child: Row(
        children: [
          Icon(Icons.account_circle_outlined, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Text('Account'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'light_mode',
      child: Row(
        children: [
          Icon(Icons.wb_sunny_outlined, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Text('Light Mode'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'logout',
      child: Row(
        children: [
          Icon(Icons.logout, color: Colors.white70, size: 20),
          SizedBox(width: 10),
          Text('Logout'),
        ],
      ),
    ),
  ],
),
        const SizedBox(width: 16),
        const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showFeatureMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF10182A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...FeatureType.values.toList().asMap().entries.map(
              (entry) => _buildAnimatedFeatureTile(entry.key, entry.value),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text(
                'Scan History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                
                
                
              },
            ).animate(delay: (FeatureType.values.length * 100).ms)
             .fade(duration: 300.ms)
             .slideX(begin: 0.3, end: 0),
          ],
        ),
      );
    },
  );
}

  Widget _buildAnimatedFeatureTile(int index, FeatureType type) {
    final iconColor = iconColors[type]!;

    return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(featureIcons[type]!, color: iconColor),
          title: Text(
            featureTitles[type]!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            switch (type) {
              case FeatureType.qr:
                _openQRScanner();
                break;
              case FeatureType.sms:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SMSAnalyzerPage()),
                );
                break;
              case FeatureType.email:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmailAnalysisPage()),
                );
                break;
              case FeatureType.url:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const URLScannerPage()),
                );
                break;
              case FeatureType.apk:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const APKAnalyzerPage()),
                );
                break;
            }
          },
        )
        .animate(delay: (index * 100).ms)
        .fade(duration: 300.ms)
        .slideX(begin: 0.3, end: 0);
  }

  void _openQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (result != null) {
      setState(() {
        scanCounts[FeatureType.qr] = (scanCounts[FeatureType.qr] ?? 0) + 1;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scanned QR: $result')));
    }
  }
}
