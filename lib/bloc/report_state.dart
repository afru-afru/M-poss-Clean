// lib/bloc/report_state.dart

part of 'report_bloc.dart';

abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

// Update this state
class ReportLoaded extends ReportState {
  final List<dynamic> allInvoices;
  final List<dynamic> filteredInvoices;

  const ReportLoaded({required this.allInvoices, required this.filteredInvoices});

  @override
  List<Object> get props => [allInvoices, filteredInvoices];
}

class ReportError extends ReportState {
  final String message;
  const ReportError({required this.message});
  @override
  List<Object> get props => [message];
}