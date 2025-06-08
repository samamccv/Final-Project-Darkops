import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:darkops/dashboard/qr_code_scanner.dart';
import 'package:darkops/dashboard/sms_analyzer.dart';
import 'package:darkops/dashboard/email_analyzer.dart';
import 'package:darkops/dashboard/url_scanner.dart';
import 'package:darkops/dashboard/apk_analyzer.dart';
import 'package:darkops/screens/login_options.dart';
import 'package:darkops/dashboard/theme_provider.dart';
import 'package:provider/provider.dart';

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
    FeatureType.sms: const Color.fromARGB(255, 139, 92, 246),
    FeatureType.email: const Color.fromARGB(255, 59, 130, 246),
    FeatureType.url: const Color.fromARGB(255, 245, 158, 11),
    FeatureType.qr: const Color.fromARGB(255, 99, 102, 241),
    FeatureType.apk: const Color.fromARGB(255, 15, 185, 129),
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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    const Color primaryBlue = Color(0xFF3B82F6);
    final Color greyText = Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: _buildAppBarTitle(textColor, primaryBlue),
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Sama 👋',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildHorizontalFeatureList(cardColor, textColor),
              const SizedBox(height: 20),
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
              _buildRecentCard(
                FeatureType.sms,
                recentSMS,
                cardColor,
                textColor,
                removeRecentActivityFromTitle: true,
              ),
              const SizedBox(height: 16),
              _buildRecentCard(
                FeatureType.email,
                recentEmails,
                cardColor,
                textColor,
                removeRecentActivityFromTitle: true,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () => _showFeatureMenu(context),
          backgroundColor: const Color.fromARGB(255, 20, 41, 74),
          tooltip: "Features",
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(Icons.dashboard_outlined, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHorizontalFeatureList(Color cardColor, Color textColor) {
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
                              color: textColor,
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
                        color: textColor,
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
                                  ? const Color.fromARGB(255, 38, 214, 129)
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
                                    ? const Color.fromARGB(255, 37, 184, 113)
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
    Color textColor, {
    bool removeRecentActivityFromTitle = false,
  }) {
    final icon = featureIcons[type]!;
    final title = featureTitles[type]!;
    final iconColor = iconColors[type]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
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
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'account',
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Account'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'light_mode',
                  child: Consumer<ThemeProvider>(
                    builder:
                        (context, themeProvider, _) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Text('Toggle Light Mode'),
                              ],
                            ),
                            Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme(value);
                              },
                              activeColor: Colors.white,
                            ),
                          ],
                        ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  void _showFeatureMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
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
    // Implement your feature menu here
  
