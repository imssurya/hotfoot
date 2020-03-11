import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hotfoot/core/use_cases/use_case.dart';
import 'package:hotfoot/features/authentication/domain/use_cases/sign_in_with_credentials.dart';
import 'package:hotfoot/features/authentication/domain/use_cases/sign_in_with_google.dart';
import 'package:hotfoot/features/authentication/presentation/bloc/authentication_event.dart';
import 'package:hotfoot/features/authentication/presentation/bloc/authentication_state.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:hotfoot/src/utils/validators.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInWithCredentials signInWithCredentials;

  AuthenticationBloc({
    @required this.signInWithGoogle,
    @required this.signInWithCredentials,
  })  : assert(signInWithGoogle != null),
        assert(signInWithCredentials != null);

  @override
  AuthenticationState get initialState => AuthenticationState.empty();

  @override
  Stream<AuthenticationState> transformEvents(
    Stream<AuthenticationEvent> events,
    Stream<AuthenticationState> Function(AuthenticationEvent event) next,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      next,
    );
  }

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<AuthenticationState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<AuthenticationState> _mapPasswordChangedToState(
      String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<AuthenticationState> _mapLoginWithGooglePressedToState() async* {
    final resultEither = await signInWithGoogle(NoParams());
    yield* resultEither.fold(
      (failure) async* {
        yield AuthenticationState.failure();
      },
      (success) async* {
        yield AuthenticationState.success();
      },
    );
  }

  Stream<AuthenticationState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    final resultEither = await signInWithCredentials(
      SignInWithCredentialsParams(
        email: email,
        password: password,
      ),
    );
    yield* resultEither.fold(
      (failure) async* {
        yield AuthenticationState.failure();
      },
      (success) async* {
        yield AuthenticationState.success();
      },
    );
  }
}
