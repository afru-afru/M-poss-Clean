import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../core/usecases/usecase.dart';
import '../../../core/errors/failures.dart' as failures;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(_mapFailureToMessage(failure))),
      (user) => user != null ? emit(AuthSuccess(user)) : emit(AuthInitial()),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    emit(AuthInitial());
  }

  String _mapFailureToMessage(failures.Failure failure) {
    switch (failure.runtimeType) {
      case failures.ServerFailure:
        return 'Server error occurred';
      case failures.NetworkFailure:
        return 'No internet connection';
      case failures.AuthFailure:
        return 'Authentication failed';
      default:
        return 'Unexpected error occurred';
    }
  }
} 