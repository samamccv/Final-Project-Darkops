import 'package:equatable/equatable.dart';
import '../../models/dashboard/dashboard_stats.dart';

enum DashboardStatus {
  initial,
  loading,
  success,
  failure,
}

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardStats? dashboardStats;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.dashboardStats,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardStats? dashboardStats,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isLoading => status == DashboardStatus.loading;
  bool get hasData => status == DashboardStatus.success && dashboardStats != null;
  bool get hasError => status == DashboardStatus.failure && errorMessage != null;

  @override
  List<Object?> get props => [status, dashboardStats, errorMessage];
}
