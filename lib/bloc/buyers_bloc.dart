import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'buyers_event.dart';
part 'buyers_state.dart';

class BuyersBloc extends Bloc<BuyersEvent, BuyersState> {
  BuyersBloc() : super(BuyersInitial()) {
    on<LoadBuyers>(_onLoadBuyers);
  }

  Future<void> _onLoadBuyers(
    LoadBuyers event,
    Emitter<BuyersState> emit,
  ) async {
    emit(BuyersLoading());
    try {
      final url = Uri.parse('http://196.190.251.122:8082/api/v1/buyer');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${event.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        emit(BuyersLoaded(buyers: data));
      } else {
        throw Exception('Failed to load buyers from API');
      }
    } catch (e) {
      emit(BuyersError(message: e.toString()));
    }
  }
}
