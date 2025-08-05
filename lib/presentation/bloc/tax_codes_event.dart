part of 'tax_codes_bloc.dart';

abstract class TaxCodesEvent extends Equatable {
  const TaxCodesEvent();
  @override
  List<Object> get props => [];
}

class LoadTaxCodes extends TaxCodesEvent {
  final String token;
  const LoadTaxCodes({required this.token});
  @override
  List<Object> get props => [token];
}
