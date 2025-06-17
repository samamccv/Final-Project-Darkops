import 'package:equatable/equatable.dart';
import 'scan_stats.dart';
import 'recent_scan.dart';

class DashboardStats extends Equatable {
  final int totalScans;
  final double totalScansPercentageChange;
  final ThreatScore threatScore;
  final List<ScanStats> scansByType;
  final List<RecentScan> recentScans;

  const DashboardStats({
    required this.totalScans,
    required this.totalScansPercentageChange,
    required this.threatScore,
    required this.scansByType,
    required this.recentScans,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalScans: json['totalScans'] as int,
      totalScansPercentageChange: (json['totalScansPercentageChange'] as num).toDouble(),
      threatScore: ThreatScore.fromJson(json['threatScore'] as Map<String, dynamic>),
      scansByType: (json['scansByType'] as List<dynamic>)
          .map((scan) => ScanStats.fromJson(scan as Map<String, dynamic>))
          .toList(),
      recentScans: (json['recentScans'] as List<dynamic>)
          .map((scan) => RecentScan.fromJson(scan as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalScans': totalScans,
      'totalScansPercentageChange': totalScansPercentageChange,
      'threatScore': threatScore.toJson(),
      'scansByType': scansByType.map((scan) => scan.toJson()).toList(),
      'recentScans': recentScans.map((scan) => scan.toJson()).toList(),
    };
  }

  DashboardStats copyWith({
    int? totalScans,
    double? totalScansPercentageChange,
    ThreatScore? threatScore,
    List<ScanStats>? scansByType,
    List<RecentScan>? recentScans,
  }) {
    return DashboardStats(
      totalScans: totalScans ?? this.totalScans,
      totalScansPercentageChange: totalScansPercentageChange ?? this.totalScansPercentageChange,
      threatScore: threatScore ?? this.threatScore,
      scansByType: scansByType ?? this.scansByType,
      recentScans: recentScans ?? this.recentScans,
    );
  }

  // Helper methods to get scan counts by type
  int getScanCountByType(String type) {
    final scanStat = scansByType.firstWhere(
      (scan) => scan.type.toLowerCase() == type.toLowerCase(),
      orElse: () => const ScanStats(type: '', count: 0, percentageChange: 0, previousWeekCount: 0),
    );
    return scanStat.count;
  }

  double getPercentageChangeByType(String type) {
    final scanStat = scansByType.firstWhere(
      (scan) => scan.type.toLowerCase() == type.toLowerCase(),
      orElse: () => const ScanStats(type: '', count: 0, percentageChange: 0, previousWeekCount: 0),
    );
    return scanStat.percentageChange;
  }

  @override
  List<Object?> get props => [totalScans, totalScansPercentageChange, threatScore, scansByType, recentScans];
}

class ThreatScore extends Equatable {
  final double score;
  final String level;
  final double percentageChange;
  final double previousScore;

  const ThreatScore({
    required this.score,
    required this.level,
    required this.percentageChange,
    required this.previousScore,
  });

  factory ThreatScore.fromJson(Map<String, dynamic> json) {
    return ThreatScore(
      score: (json['score'] as num).toDouble(),
      level: json['level'] as String,
      percentageChange: (json['percentageChange'] as num).toDouble(),
      previousScore: (json['previousScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level,
      'percentageChange': percentageChange,
      'previousScore': previousScore,
    };
  }

  ThreatScore copyWith({
    double? score,
    String? level,
    double? percentageChange,
    double? previousScore,
  }) {
    return ThreatScore(
      score: score ?? this.score,
      level: level ?? this.level,
      percentageChange: percentageChange ?? this.percentageChange,
      previousScore: previousScore ?? this.previousScore,
    );
  }

  @override
  List<Object?> get props => [score, level, percentageChange, previousScore];
}
