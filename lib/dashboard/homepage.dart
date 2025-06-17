import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:darkops/dashboard/qr_code_scanner.dart';
import 'package:darkops/dashboard/sms_analyzer.dart';
import 'package:darkops/dashboard/email_analyzer.dart';
import 'package:darkops/dashboard/url_scanner.dart';
import 'package:darkops/dashboard/apk_analyzer.dart';
import 'package:darkops/screens/login_options.dart';
import 'package:darkops/dashboard/theme_provider.dart';
import 'package:darkops/blocs/auth/auth_bloc.dart';
import 'package:darkops/blocs/dashboard/dashboard_bloc.dart';
import 'package:darkops/blocs/dashboard/dashboard_event.dart';
import 'package:darkops/blocs/dashboard/dashboard_state.dart';
import 'package:darkops/models/dashboard/dashboard_stats.dart';
import 'package:provider/provider.dart';

enum FeatureType { sms, email, url, qr, apk }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Request dashboard data when the page loads
    context.read<DashboardBloc>().add(const DashboardDataRequested());
  }

  final Map<FeatureType, IconData> featureIcons = {
    FeatureType.sms: Icons.sms_outlined,
    FeatureType.email: Icons.email_outlined,
    FeatureType.url: Icons.language_outlined,
    FeatureType.qr: Icons.qr_code_2_outlined,
    FeatureType.apk: Icons.android_outlined,
  };

  final Map<FeatureType, String> featureTitles = {
    FeatureType.sms: "SMS Scans",
    FeatureType.email: "Email Scans",
    FeatureType.url: "URL Scans",
    FeatureType.qr: "QR Scans",
    FeatureType.apk: "APK Scans",
  };

  final Map<FeatureType, Color> iconColors = {
    FeatureType.sms: const Color.fromARGB(255, 139, 92, 246),
    FeatureType.email: const Color.fromARGB(255, 59, 130, 246),
    FeatureType.url: const Color.fromARGB(255, 245, 158, 11),
    FeatureType.qr: const Color.fromARGB(255, 99, 102, 241),
    FeatureType.apk: const Color.fromARGB(255, 15, 185, 129),
  };

  final Map<String, FeatureType> scanTypeMapping = {
    'SMS': FeatureType.sms,
    'EMAIL': FeatureType.email,
    'URL': FeatureType.url,
    'QR': FeatureType.qr,
    'APK': FeatureType.apk,
  };

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    const Color primaryBlue = Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: _buildAppBarWithLogo(textColor, primaryBlue),
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, dashboardState) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(
                    const DashboardDataRefreshed(),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Message with User Name
                      _buildWelcomeMessage(authState, textColor),
                      const SizedBox(height: 24),

                      // Dashboard Content
                      if (dashboardState.isLoading &&
                          dashboardState.dashboardStats == null)
                        _buildLoadingState()
                      else if (dashboardState.hasError)
                        _buildErrorState(dashboardState.errorMessage!, context)
                      else
                        _buildDashboardContent(
                          dashboardState,
                          cardColor,
                          textColor,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () => _showFeatureMenu(context),
          backgroundColor: const Color.fromARGB(255, 139, 92, 246),
          tooltip: "Scan Features",
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.security_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // Welcome message with dynamic user name
  Widget _buildWelcomeMessage(AuthState authState, Color textColor) {
    final userName = authState.user?.name ?? 'User';
    return Text(
      'Hello, $userName 👋',
      style: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0);
  }

  // Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(255, 139, 92, 246),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading dashboard data...',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Error state
  Widget _buildErrorState(String errorMessage, BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Failed to load dashboard data',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardDataRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 139, 92, 246),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Main dashboard content
  Widget _buildDashboardContent(
    DashboardState dashboardState,
    Color cardColor,
    Color textColor,
  ) {
    final stats = dashboardState.dashboardStats!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced Total Scans Card with Material Design 3
        _buildEnhancedTotalScansCard(stats, cardColor, textColor),
        const SizedBox(height: 20),

        // Modern Scan Type Cards with Threat Score
        _buildScanCardsWithThreatScore(stats, cardColor, textColor),
        const SizedBox(height: 32),

        // Recent Scans Section with Material Design 3
        Text(
          'Recent Activity',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0),
        const SizedBox(height: 16),
        _buildEnhancedRecentScansSection(stats, cardColor, textColor),
      ],
    );
  }

  // Enhanced Total Scans Card with Material Design 3
  Widget _buildEnhancedTotalScansCard(
    DashboardStats stats,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromARGB(
                255,
                139,
                92,
                246,
              ).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  255,
                  139,
                  92,
                  246,
                ).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(
                            255,
                            139,
                            92,
                            246,
                          ).withValues(alpha: 0.15),
                          const Color.fromARGB(
                            255,
                            139,
                            92,
                            246,
                          ).withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.security_outlined,
                      color: Color.fromARGB(255, 139, 92, 246),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Security Scans',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.totalScans}',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    139,
                    92,
                    246,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: const Color.fromARGB(255, 139, 92, 246),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'All-time security analysis',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 139, 92, 246),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .scale(begin: const Offset(0.95, 0.95));
  }

  // Combined Scan Cards with Threat Score Layout
  Widget _buildScanCardsWithThreatScore(
    DashboardStats stats,
    Color cardColor,
    Color textColor,
  ) {
    return Column(
      children: [
        // First row - SMS and Email
        Row(
          children: [
            Expanded(
              child: _buildCompactScanCard(
                FeatureType.sms,
                stats,
                cardColor,
                textColor,
                0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCompactScanCard(
                FeatureType.email,
                stats,
                cardColor,
                textColor,
                1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Second row - URL and QR
        Row(
          children: [
            Expanded(
              child: _buildCompactScanCard(
                FeatureType.url,
                stats,
                cardColor,
                textColor,
                2,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCompactScanCard(
                FeatureType.qr,
                stats,
                cardColor,
                textColor,
                3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Third row - APK and Threat Score
        Row(
          children: [
            Expanded(
              child: _buildCompactScanCard(
                FeatureType.apk,
                stats,
                cardColor,
                textColor,
                4,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCompactThreatScoreCard(stats, cardColor, textColor),
            ),
          ],
        ),
      ],
    );
  }

  // Compact Scan Card (Fixed Height to Prevent Overflow)
  Widget _buildCompactScanCard(
    FeatureType type,
    DashboardStats stats,
    Color cardColor,
    Color textColor,
    int index,
  ) {
    final scanCount = stats.getScanCountByType(type.name.toUpperCase());
    final iconColor = iconColors[type]!;

    return Container(
          height: 120, // Fixed height to prevent overflow
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor.withValues(alpha: 0.15),
                      iconColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(featureIcons[type], color: iconColor, size: 20),
              ),

              // Content with improved typography
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    featureTitles[type]!,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$scanCount',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: (index * 150).ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .scale(begin: const Offset(0.9, 0.9));
  }

  // Compact Threat Score Card (Fixed Height to Match Scan Cards)
  Widget _buildCompactThreatScoreCard(
    DashboardStats stats,
    Color cardColor,
    Color textColor,
  ) {
    final threatScore = stats.threatScore;
    final scoreColor = _getThreatScoreColor(threatScore.level);

    return Container(
          height: 120, // Fixed height to match scan cards
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 3,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scoreColor.withValues(alpha: 0.15),
                      scoreColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getThreatScoreIcon(threatScore.level),
                  color: scoreColor,
                  size: 20,
                ),
              ),

              // Content with improved typography
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Threat Score',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        threatScore.score.toStringAsFixed(1),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scoreColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          threatScore.level.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: scoreColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(delay: 750.ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .scale(begin: const Offset(0.9, 0.9));
  }

  // Enhanced Recent Scans Section with Material Design 3
  Widget _buildEnhancedRecentScansSection(
    DashboardStats stats,
    Color cardColor,
    Color textColor,
  ) {
    if (stats.recentScans.isEmpty) {
      return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(
                  255,
                  139,
                  92,
                  246,
                ).withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    139,
                    92,
                    246,
                  ).withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(
                          255,
                          139,
                          92,
                          246,
                        ).withValues(alpha: 0.1),
                        const Color.fromARGB(
                          255,
                          139,
                          92,
                          246,
                        ).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.timeline_outlined,
                    size: 48,
                    color: const Color.fromARGB(255, 139, 92, 246),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No recent activity',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start scanning to see your security analysis history',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 14,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 800.ms)
          .scale(begin: const Offset(0.95, 0.95));
    }

    return Column(
      children:
          stats.recentScans.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final scan = entry.value;
            final scanType =
                scanTypeMapping.entries
                    .firstWhere(
                      (entry) =>
                          entry.key.toLowerCase() ==
                          scan.scanType.toLowerCase(),
                      orElse: () => const MapEntry('UNKNOWN', FeatureType.sms),
                    )
                    .value;
            final iconColor = iconColors[scanType]!;
            final threatColor = _getThreatColor(scan.result.threatLevel);

            return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  iconColor.withValues(alpha: 0.15),
                                  iconColor.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              featureIcons[scanType],
                              color: iconColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      scan.scanType.toUpperCase(),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: threatColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        scan.result.threatLevel,
                                        style: TextStyle(
                                          color: threatColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(scan.createdAt),
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: textColor.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target',
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              scan.target.length > 40
                                  ? '${scan.target.substring(0, 40)}...'
                                  : scan.target,
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Threat Score: ',
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  scan.result.threatScore.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: threatColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'SR: ',
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  scan.sr,
                                  style: TextStyle(
                                    color: iconColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: (index * 200).ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0)
                .scale(begin: const Offset(0.95, 0.95));
          }).toList(),
    );
  }

  Color _getThreatColor(String threatLevel) {
    switch (threatLevel.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      case 'CRITICAL':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getThreatScoreColor(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.red;
      case 'CRITICAL':
        return Colors.red[900]!;
      default:
        return const Color.fromARGB(255, 139, 92, 246);
    }
  }

  IconData _getThreatScoreIcon(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return Icons.shield_outlined;
      case 'MEDIUM':
        return Icons.warning_amber_outlined;
      case 'HIGH':
        return Icons.error_outline;
      case 'CRITICAL':
        return Icons.dangerous_outlined;
      default:
        return Icons.security_outlined;
    }
  }

  Widget _buildAppBarWithLogo(Color textColor, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - empty space for balance
        const SizedBox(width: 48),

        // Center - DarkOps Logo
        Expanded(
          child: Center(
            child: Image.asset(
              'images/darkopslogo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Right side - Profile Menu
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.person_outlined, color: iconColor, size: 24),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          onSelected: (value) {
            switch (value) {
              case 'account':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account selected')),
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
                PopupMenuItem(
                  value: 'account',
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        color: textColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text('Account'),
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
                                  color: textColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Text('Dark Mode'),
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
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_outlined, color: textColor, size: 20),
                      const SizedBox(width: 10),
                      const Text('Logout'),
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
              color: Theme.of(context).colorScheme.onSurface,
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
                _openSMSAnalyzer();
                break;
              case FeatureType.email:
                _openEmailAnalyzer();
                break;
              case FeatureType.url:
                _openURLAnalyzer();
                break;
              case FeatureType.apk:
                _openAPKAnalyzer();
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

    if (result != null && mounted) {
      // Refresh dashboard data after scan
      context.read<DashboardBloc>().add(const DashboardDataRefreshed());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scanned QR: $result')));
    }
  }

  void _openSMSAnalyzer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SMSAnalyzerPage()),
    );

    if (result != null && mounted) {
      // Refresh dashboard data after scan
      context.read<DashboardBloc>().add(const DashboardDataRefreshed());
    }
  }

  void _openURLAnalyzer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const URLScannerPage()),
    );

    if (result != null && mounted) {
      // Refresh dashboard data after scan
      context.read<DashboardBloc>().add(const DashboardDataRefreshed());
    }
  }

  void _openAPKAnalyzer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const APKAnalyzerPage()),
    );

    if (result != null && mounted) {
      // Refresh dashboard data after scan
      context.read<DashboardBloc>().add(const DashboardDataRefreshed());
    }
  }

  void _openEmailAnalyzer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmailAnalysisPage()),
    );

    if (result != null && mounted) {
      // Refresh dashboard data after scan
      context.read<DashboardBloc>().add(const DashboardDataRefreshed());
    }
  }
}
