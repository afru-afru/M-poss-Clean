import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'tax_codes_event.dart';
part 'tax_codes_state.dart';

class TaxCodesBloc extends Bloc<TaxCodesEvent, TaxCodesState> {
  TaxCodesBloc() : super(TaxCodesInitial()) {
    on<LoadTaxCodes>(_onLoadTaxCodes);
  }

  Future<void> _onLoadTaxCodes(
    LoadTaxCodes event,
    Emitter<TaxCodesState> emit,
  ) async {
    emit(TaxCodesLoading());
    try {
      final url = Uri.parse('http://196.190.251.122:8086/api/v1/config/tax-codes');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        emit(TaxCodesLoaded(taxCodes: data));
      } else {
        throw Exception('Failed to load tax codes from API');
      }
    } catch (e) {
      emit(TaxCodesError(message: e.toString()));
    }
  }
}
