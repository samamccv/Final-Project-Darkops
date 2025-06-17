import 'package:equatable/equatable.dart';

class ScanStats extends Equatable {
  final String type;
  final int count;
  final double percentageChange;
  final int previousWeekCount;

  const ScanStats({
    required this.type,
    required this.count,
    required this.percentageChange,
    required this.previousWeekCount,
  });

  factory ScanStats.fromJson(Map<String, dynamic> json) {
    return ScanStats(
      type: json['type'] as String,
      count: json['count'] as int,
      percentageChange: (json['percentageChange'] as num).toDouble(),
      previousWeekCount: json['previousWeekCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'count': count,
      'percentageChange': percentageChange,
      'previousWeekCount': previousWeekCount,
    };
  }

  ScanStats copyWith({
    String? type,
    int? count,
    double? percentageChange,
    int? previousWeekCount,
  }) {
    return ScanStats(
      type: type ?? this.type,
      count: count ?? this.count,
      percentageChange: percentageChange ?? this.percentageChange,
      previousWeekCount: previousWeekCount ?? this.previousWeekCount,
    );
  }

  @override
  List<Object?> get props => [type, count, percentageChange, previousWeekCount];
}
