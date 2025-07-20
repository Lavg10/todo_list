// features/authentication/presentation/blocs/auth_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  void login(String email, String password) async {
    emit(AuthLoading());
    final result = await authRepository.login(email, password);
    result.fold(
      (failure) => emit(AuthFailure(failure)),
      (_) => emit(AuthLoginSuccess()),
    );
  }

  void register(String email, String password) async {
    emit(AuthLoading());
    try {
      await authRepository.register(email, password);
      emit(AuthRegisterSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
