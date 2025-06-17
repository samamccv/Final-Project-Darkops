import 'package:equatable/equatable.dart';

class RecentScan extends Equatable {
  final String id;
  final String userId;
  final String scanType;
  final String target;
  final String sr; // Security Rating field from backend
  final ScanResult result;
  final DateTime createdAt;

  const RecentScan({
    required this.id,
    required this.userId,
    required this.scanType,
    required this.target,
    required this.sr,
    required this.result,
    required this.createdAt,
  });

  /// Robust date parsing that handles multiple date formats
  static DateTime _parseDate(String dateString) {
    try {
      // First try standard ISO 8601 format
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        // Handle the problematic format: "Wed Jun 11 2025 16:28:27 GMT+0300 (Eastern European Summer Time)"
        // Remove the timezone name in parentheses if present
        String cleanedDate = dateString.replaceAll(RegExp(r'\s*\([^)]*\)'), '');

        // Try to extract date components using regex
        // Pattern: "Wed Jun 11 2025 16:28:27 GMT+0300"
        final dateRegex = RegExp(
          r'(\w{3})\s+(\w{3})\s+(\d{1,2})\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})\s*(?:GMT([+-]\d{4}))?',
        );

        final match = dateRegex.firstMatch(cleanedDate);
        if (match != null) {
          final monthNames = {
            'Jan': 1,
            'Feb': 2,
            'Mar': 3,
            'Apr': 4,
            'May': 5,
            'Jun': 6,
            'Jul': 7,
            'Aug': 8,
            'Sep': 9,
            'Oct': 10,
            'Nov': 11,
            'Dec': 12,
          };

          final monthStr = match.group(2)!;
          final month = monthNames[monthStr] ?? 1;
          final day = int.parse(match.group(3)!);
          final year = int.parse(match.group(4)!);
          final hour = int.parse(match.group(5)!);
          final minute = int.parse(match.group(6)!);
          final second = int.parse(match.group(7)!);

          // Create DateTime in UTC and then convert to local if needed
          return DateTime.utc(year, month, day, hour, minute, second);
        }

        // If regex parsing fails, try a simpler approach
        // Look for ISO-like patterns in the string
        final isoRegex = RegExp(
          r'(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})',
        );
        final isoMatch = isoRegex.firstMatch(dateString);
        if (isoMatch != null) {
          return DateTime.parse(isoMatch.group(0)!);
        }

        // If all parsing attempts fail, use current time as fallback
        // In production, this should be logged to a proper logging service
        return DateTime.now();
      } catch (e2) {
        // In production, this should be logged to a proper logging service
        return DateTime.now();
      }
    }
  }

  factory RecentScan.fromJson(Map<String, dynamic> json) {
    return RecentScan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      scanType: json['scanType'] as String,
      target: json['target'] as String,
      sr: json['SR'] as String, // Note: backend uses 'SR' (uppercase)
      result: ScanResult.fromJson(json['result'] as Map<String, dynamic>),
      createdAt: _parseDate(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scanType': scanType,
      'target': target,
      'SR': sr, // Backend expects 'SR' (uppercase)
      'result': result.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RecentScan copyWith({
    String? id,
    String? userId,
    String? scanType,
    String? target,
    String? sr,
    ScanResult? result,
    DateTime? createdAt,
  }) {
    return RecentScan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scanType: scanType ?? this.scanType,
      target: target ?? this.target,
      sr: sr ?? this.sr,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    scanType,
    target,
    sr,
    result,
    createdAt,
  ];
}

class ScanResult extends Equatable {
  final double threatScore;
  final String threatLevel;
  final double confidence;
  final List<Finding> findings;

  const ScanResult({
    required this.threatScore,
    required this.threatLevel,
    required this.confidence,
    required this.findings,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      threatScore: (json['threatScore'] as num).toDouble(),
      threatLevel: json['threatLevel'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      findings:
          (json['findings'] as List<dynamic>)
              .map(
                (finding) => Finding.fromJson(finding as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threatScore': threatScore,
      'threatLevel': threatLevel,
      'confidence': confidence,
      'findings': findings.map((finding) => finding.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [threatScore, threatLevel, confidence, findings];
}

class Finding extends Equatable {
  final String type;
  final String severity;
  final String description;

  const Finding({
    required this.type,
    required this.severity,
    required this.description,
  });

  factory Finding.fromJson(Map<String, dynamic> json) {
    return Finding(
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'severity': severity, 'description': description};
  }

  @override
  List<Object?> get props => [type, severity, description];
}
