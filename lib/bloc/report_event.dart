// lib/bloc/report_event.dart

part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object> get props => [];
}

class LoadReports extends ReportEvent {}

// Add this event for searching
class SearchReports extends ReportEvent {
  final String query;

  const SearchReports({required this.query});

  @override
  List<Object> get props => [query];
}