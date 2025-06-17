import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardDataRequested extends DashboardEvent {
  const DashboardDataRequested();
}

class DashboardDataRefreshed extends DashboardEvent {
  const DashboardDataRefreshed();
}

class DashboardErrorCleared extends DashboardEvent {
  const DashboardErrorCleared();
}
