part of 'tax_codes_bloc.dart';

abstract class TaxCodesState extends Equatable {
  const TaxCodesState();
  @override
  List<Object> get props => [];
}

class TaxCodesInitial extends TaxCodesState {}
class TaxCodesLoading extends TaxCodesState {}

class TaxCodesLoaded extends TaxCodesState {
  final List<dynamic> taxCodes;
  const TaxCodesLoaded({required this.taxCodes});
  @override
  List<Object> get props => [taxCodes];
}

class TaxCodesError extends TaxCodesState {
  final String message;
  const TaxCodesError({required this.message});
  @override
  List<Object> get props => [message];
}
